package com.mediturnos.service;

import com.mediturnos.dto.*;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.*;

import com.mediturnos.repository.HorarioAtencionRepository;
import com.mediturnos.repository.MedicoRepository;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.TurnoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Servicio encargado de gestionar el ciclo de vida completo de los turnos médicos.
 */
@Service
public class TurnoService {

    @Autowired
    private TurnoRepository turnoRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    @Autowired
    private MedicoRepository medicoRepository;

    @Autowired
    private HorarioAtencionRepository horarioAtencionRepository;

    private static final ZoneId ZONA_BUENOS_AIRES = ZoneId.of("America/Argentina/Buenos_Aires");
    private static final DateTimeFormatter FORMATO_HORA = DateTimeFormatter.ofPattern("HH:mm");
    private static final List<String> ESTADOS_VALIDOS = List.of("PENDIENTE", "CONFIRMADO", "CANCELADO", "ATENDIDO");

    /**
     * Lista los turnos aplicando filtros opcionales (pacienteId, medicoId, fecha, estado) ordenados por fecha y hora.
     */
    @Transactional(readOnly = true)
    public List<TurnoRespuesta> listarConFiltros(Integer pacienteId, Integer medicoId, String fechaStr, String estadoStr) {
        LocalDate fecha = null;
        if (fechaStr != null && !fechaStr.trim().isEmpty()) {
            try {
                fecha = LocalDate.parse(fechaStr.trim());
            } catch (DateTimeParseException e) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Formato de fecha inválido (debe ser YYYY-MM-DD).", "fecha");
            }
        }

        String estado = null;
        if (estadoStr != null && !estadoStr.trim().isEmpty()) {
            estado = estadoStr.trim().toUpperCase();
            if (!ESTADOS_VALIDOS.contains(estado)) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El estado especificado no es válido.", "estado");
            }
        }

        List<Turno> turnos = turnoRepository.buscarConFiltros(pacienteId, medicoId, fecha, estado);
        return turnos.stream()
                .map(this::convertirADto)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene un turno por su ID.
     */
    @Transactional(readOnly = true)
    public TurnoRespuesta obtenerPorId(Integer id) {
        Turno turno = turnoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado."));
        return convertirADto(turno);
    }

    /**
     * Resultado de la operación de creación de turno (incluye indicación de si fue por idempotencia).
     */
    public record ResultadoCreacion(TurnoRespuesta respuesta, boolean yaExistia) {}

    /**
     * Crea un nuevo turno validando la idempotencia por claveSolicitud y la disponibilidad de horarios.
     */
    @Transactional
    public ResultadoCreacion crear(TurnoCreacionSolicitud solicitud) {
        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La solicitud no puede ser nula.", "paciente");
        }

        // 1. Idempotencia: si ya existe por claveSolicitud, se devuelve 200 OK inmediatamente sin validar nada más
        String claveSolicitud = solicitud.getClaveSolicitud();
        if (claveSolicitud != null && !claveSolicitud.trim().isEmpty()) {
            Optional<Turno> existente = turnoRepository.findByClaveSolicitud(claveSolicitud.trim());
            if (existente.isPresent()) {
                return new ResultadoCreacion(convertirADto(existente.get()), true);
            }
            claveSolicitud = claveSolicitud.trim();
        } else {
            claveSolicitud = UUID.randomUUID().toString();
        }

        // 2. Validar paciente
        Integer pacienteId = solicitud.getPacienteIdEfectivo();
        if (pacienteId == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El paciente es obligatorio.", "paciente");
        }
        Paciente paciente = pacienteRepository.findById(pacienteId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "PACIENTE_NO_ENCONTRADO", "Paciente no encontrado."));

        // 3. Validar médico y estado de actividad
        Integer medicoId = solicitud.getMedicoIdEfectivo();
        if (medicoId == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El médico es obligatorio.", "medico");
        }
        Medico medico = medicoRepository.findById(medicoId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado."));

        if (!Boolean.TRUE.equals(medico.getActivo())) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "MEDICO_INACTIVO", "El médico se encuentra inactivo.");
        }

        // 4. Validar estado (debe ser PENDIENTE o no especificarse)
        String estado = solicitud.getEstado();
        if (estado == null || estado.trim().isEmpty()) {
            estado = "PENDIENTE";
        } else {
            estado = estado.trim().toUpperCase();
            if (!"PENDIENTE".equals(estado)) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Al crear un turno solo se permite el estado PENDIENTE.", "estado");
            }
        }

        // 5. Parsear fecha y hora
        LocalDate fecha = parsearFecha(solicitud.getFecha());
        LocalTime hora = parsearHora(solicitud.getHora());

        // 6. Validar disponibilidad de horario (agenda, franja, fecha/hora futura)
        validarHorarioDisponible(medico, fecha, hora);

        // 7. Validar si el horario ya está ocupado por otro turno no cancelado del médico
        if (turnoRepository.existsByMedicoIdAndFechaAndHoraAndEstadoNot(medico.getId(), fecha, hora, "CANCELADO")) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_OCUPADO", "El médico ya tiene un turno reservado en ese horario.");
        }

        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(fecha);
        turno.setHora(hora);
        turno.setEstado("PENDIENTE");
        turno.setClaveSolicitud(claveSolicitud);

        try {
            Turno guardado = turnoRepository.save(turno);
            return new ResultadoCreacion(convertirADto(guardado), false);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_OCUPADO", "El médico ya tiene un turno reservado en ese horario.");
        }
    }

    /**
     * Reprograma la fecha y hora de un turno existente en estado PENDIENTE o CONFIRMADO.
     */
    @Transactional
    public TurnoRespuesta reprogramar(Integer id, TurnoReprogramarSolicitud solicitud) {
        Turno turno = turnoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado."));

        // Solo se permite reprogramar si está PENDIENTE o CONFIRMADO
        if (!"PENDIENTE".equals(turno.getEstado()) && !"CONFIRMADO".equals(turno.getEstado())) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "TURNO_NO_MODIFICABLE", "El turno no se puede modificar en su estado actual.");
        }

        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La solicitud no puede ser nula.", "fecha");
        }

        LocalDate nuevaFecha = parsearFecha(solicitud.getFecha());
        LocalTime nuevaHora = parsearHora(solicitud.getHora());

        Medico medico = turno.getMedico();
        if (!Boolean.TRUE.equals(medico.getActivo())) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "MEDICO_INACTIVO", "El médico se encuentra inactivo.");
        }

        // Validar que la nueva fecha/hora coincida con la agenda del médico y no haya pasado
        validarHorarioDisponible(medico, nuevaFecha, nuevaHora);

        // Validar que el horario no esté ocupado por OTRO turno no cancelado del mismo médico
        if (turnoRepository.existsByMedicoIdAndFechaAndHoraAndEstadoNotAndIdNot(medico.getId(), nuevaFecha, nuevaHora, "CANCELADO", id)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_OCUPADO", "El médico ya tiene un turno reservado en ese horario.");
        }

        turno.setFecha(nuevaFecha);
        turno.setHora(nuevaHora);
        // El estado NO cambia según la especificación

        try {
            Turno guardado = turnoRepository.save(turno);
            return convertirADto(guardado);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_OCUPADO", "El médico ya tiene un turno reservado en ese horario.");
        }
    }

    /**
     * Modifica el estado de un turno respetando la máquina de estados permitida.
     */
    @Transactional
    public TurnoRespuesta cambiarEstado(Integer id, TurnoEstadoSolicitud solicitud) {
        Turno turno = turnoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado."));

        if (solicitud == null || solicitud.getEstado() == null || solicitud.getEstado().trim().isEmpty()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El estado es obligatorio.", "estado");
        }

        String nuevoEstado = solicitud.getEstado().trim().toUpperCase();
        if (!ESTADOS_VALIDOS.contains(nuevoEstado)) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El estado especificado no es válido.", "estado");
        }

        String estadoActual = turno.getEstado();

        // Si se pide el mismo estado que ya tiene, se responde 200 sin cambios
        if (nuevoEstado.equals(estadoActual)) {
            return convertirADto(turno);
        }

        // Validaciones de transición de estado
        boolean esValida = false;
        if ("PENDIENTE".equals(estadoActual)) {
            esValida = "CONFIRMADO".equals(nuevoEstado) || "CANCELADO".equals(nuevoEstado);
        } else if ("CONFIRMADO".equals(estadoActual)) {
            esValida = "ATENDIDO".equals(nuevoEstado) || "CANCELADO".equals(nuevoEstado);
        }

        if (!esValida) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "TRANSICION_INVALIDA", "No se permite cambiar el estado de " + estadoActual + " a " + nuevoEstado + ".");
        }

        // Regla especial: ATENDIDO solo si la fecha del turno es hoy o anterior en Buenos Aires
        if ("ATENDIDO".equals(nuevoEstado)) {
            LocalDate hoy = LocalDate.now(ZONA_BUENOS_AIRES);
            if (turno.getFecha().isAfter(hoy)) {
                throw new ExcepcionApi(HttpStatus.CONFLICT, "TRANSICION_INVALIDA", "No se puede marcar como ATENDIDO un turno con fecha futura.");
            }
        }

        turno.setEstado(nuevoEstado);
        Turno guardado = turnoRepository.save(turno);
        return convertirADto(guardado);
    }

    /**
     * Mantiene compatibilidad con el método de eliminación previa.
     */
    @Transactional
    public void eliminar(Integer id) {
        if (!turnoRepository.existsById(id)) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado.");
        }
        turnoRepository.deleteById(id);
    }

    /**
     * Parsea una fecha en formato YYYY-MM-DD.
     */
    private LocalDate parsearFecha(String fechaStr) {
        if (fechaStr == null || fechaStr.trim().isEmpty()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La fecha es obligatoria.", "fecha");
        }
        try {
            return LocalDate.parse(fechaStr.trim());
        } catch (DateTimeParseException e) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Formato de fecha inválido (debe ser YYYY-MM-DD).", "fecha");
        }
    }

    /**
     * Parsea una hora en formato HH:mm o HH:mm:ss.
     */
    private LocalTime parsearHora(String horaStr) {
        if (horaStr == null || horaStr.trim().isEmpty()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La hora es obligatoria.", "hora");
        }
        String h = horaStr.trim();
        try {
            if (h.length() == 5) {
                return LocalTime.parse(h, FORMATO_HORA);
            } else {
                return LocalTime.parse(h);
            }
        } catch (DateTimeParseException e) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Formato de hora inválido.", "hora");
        }
    }

    /**
     * Valida que la fecha y hora sean futuras en Buenos Aires y correspondan a un turno válido de la agenda del médico.
     */
    private void validarHorarioDisponible(Medico medico, LocalDate fecha, LocalTime hora) {
        LocalDateTime ahora = LocalDateTime.now(ZONA_BUENOS_AIRES);
        LocalDateTime fechaHoraTurno = LocalDateTime.of(fecha, hora);

        // Regla: la fecha y hora no deben haber pasado
        if (fechaHoraTurno.isBefore(ahora)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_NO_DISPONIBLE", "La fecha y hora especificadas ya han pasado.");
        }

        // Día de la semana (1 = Lunes ... 7 = Domingo)
        int diaSemana = fecha.getDayOfWeek().getValue();

        List<HorarioAtencion> franjas = horarioAtencionRepository.findByMedicoIdAndDiaSemanaAndActivoTrueOrderByHoraInicioAsc(medico.getId(), diaSemana);
        if (franjas.isEmpty()) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_NO_DISPONIBLE", "El médico no atiende el día de la semana correspondiente a la fecha.");
        }

        // Verificar que la hora coincida exactamente con el inicio de un slot dentro de alguna franja activa
        boolean coincideConSlot = false;
        for (HorarioAtencion f : franjas) {
            LocalTime t = f.getHoraInicio();
            int duracion = f.getDuracionTurno();
            LocalTime fin = f.getHoraFin();

            while (!t.plusMinutes(duracion).isAfter(fin)) {
                if (t.equals(hora)) {
                    coincideConSlot = true;
                    break;
                }
                t = t.plusMinutes(duracion);
            }
            if (coincideConSlot) break;
        }

        if (!coincideConSlot) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_NO_DISPONIBLE", "La hora indicada no coincide con una franja de atención disponible del médico.");
        }
    }

    /**
     * Convierte la entidad Turno a su DTO de salida TurnoRespuesta.
     */
    public TurnoRespuesta convertirADto(Turno turno) {
        Paciente p = turno.getPaciente();
        PacienteResumen pacienteDto = null;
        if (p != null) {
            String nombre = p.getUsuario() != null ? p.getUsuario().getNombre() : null;
            String apellido = p.getUsuario() != null ? p.getUsuario().getApellido() : null;
            pacienteDto = new PacienteResumen(p.getId(), nombre, apellido, p.getDni(), p.getTelefono());
        }

        Medico m = turno.getMedico();
        MedicoResumen medicoDto = null;
        if (m != null) {
            EspecialidadResumen espDto = null;
            if (m.getEspecialidad() != null) {
                espDto = new EspecialidadResumen(m.getEspecialidad().getId(), m.getEspecialidad().getNombre());
            }
            medicoDto = new MedicoResumen(m.getId(), m.getNombre(), m.getApellido(), m.getMatricula(), espDto);
        }

        String fechaStr = turno.getFecha() != null ? turno.getFecha().toString() : null;
        String horaStr = turno.getHora() != null ? turno.getHora().format(FORMATO_HORA) : null;
        String fechaCreacionStr = turno.getFechaCreacion() != null ? turno.getFechaCreacion().toString() : null;

        return new TurnoRespuesta(
                turno.getId(),
                turno.getEstado(),
                fechaStr,
                horaStr,
                turno.getClaveSolicitud(),
                fechaCreacionStr,
                pacienteDto,
                medicoDto
        );
    }
}
