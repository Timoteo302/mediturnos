package com.mediturnos.service;

import com.mediturnos.dto.*;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.*;

import com.mediturnos.repository.HorarioAtencionRepository;
import com.mediturnos.repository.MedicoRepository;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.TurnoRepository;
import com.mediturnos.security.ProveedorUsuarioActual;
import com.mediturnos.security.UsuarioActual;
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
 * Servicio encargado de gestionar el ciclo de vida completo de los turnos médicos y la autorización por dueño.
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

    @Autowired
    private NotificacionService notificacionService;

    @Autowired(required = false)
    private RecordatorioTurnosService recordatorioTurnosService;

    @Autowired
    private ProveedorUsuarioActual proveedorUsuarioActual;

    private static final ZoneId ZONA_BUENOS_AIRES = ZoneId.of("America/Argentina/Buenos_Aires");
    private static final DateTimeFormatter FORMATO_HORA = DateTimeFormatter.ofPattern("HH:mm");
    private static final List<String> ESTADOS_VALIDOS = List.of("PENDIENTE", "CONFIRMADO", "CANCELADO", "ATENDIDO");

    /**
     * Lista los turnos aplicando filtros opcionales ordenados por fecha y hora, forzando pacienteId si es un paciente.
     */
    @Transactional(readOnly = true)
    public List<TurnoRespuesta> listarConFiltros(Integer pacienteId, Integer medicoId, String fechaStr, String estadoStr) {
        UsuarioActual actual = proveedorUsuarioActual.obtenerActual().orElse(null);
        if (actual != null && !actual.esAdmin()) {
            if (pacienteId != null && !pacienteId.equals(actual.pacienteId())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para consultar turnos de otro paciente.");
            }
            pacienteId = actual.pacienteId();
        }

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
     * Obtiene un turno por su ID garantizando que pertenezca al paciente si no es admin.
     */
    @Transactional(readOnly = true)
    public TurnoRespuesta obtenerPorId(Integer id) {
        Turno turno = turnoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado."));

        UsuarioActual actual = proveedorUsuarioActual.obtenerActual().orElse(null);
        if (actual != null && !actual.esAdmin()) {
            if (actual.pacienteId() == null || !actual.pacienteId().equals(turno.getPaciente().getId())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para acceder a este turno.");
            }
        }

        return convertirADto(turno);
    }

    /**
     * Resultado de la operación de creación de turno.
     */
    public record ResultadoCreacion(TurnoRespuesta respuesta, boolean yaExistia) {}

    /**
     * Crea un nuevo turno validando que el pacienteId pertenezca al usuario autenticado si es un paciente.
     */
    @Transactional
    public ResultadoCreacion crear(TurnoCreacionSolicitud solicitud) {
        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La solicitud no puede ser nula.", "paciente");
        }

        Integer pacienteId = solicitud.getPacienteIdEfectivo();
        UsuarioActual actual = proveedorUsuarioActual.obtenerActual().orElse(null);
        if (actual != null && !actual.esAdmin()) {
            if (pacienteId != null && !pacienteId.equals(actual.pacienteId())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para solicitar turnos para otro paciente.");
            }
            if (pacienteId == null) {
                pacienteId = actual.pacienteId();
            }
        }

        // 1. Idempotencia
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
        if (pacienteId == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El paciente es obligatorio.", "paciente");
        }
        Paciente paciente = pacienteRepository.findById(pacienteId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "PACIENTE_NO_ENCONTRADO", "Paciente no encontrado."));

        // 3. Validar médico y estado
        Integer medicoId = solicitud.getMedicoIdEfectivo();
        if (medicoId == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El médico es obligatorio.", "medico");
        }
        Medico medico = medicoRepository.findById(medicoId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado."));

        if (!Boolean.TRUE.equals(medico.getActivo())) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "MEDICO_INACTIVO", "El médico se encuentra inactivo.");
        }

        // 4. Validar estado
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

        // 6. Validar disponibilidad
        validarHorarioDisponible(medico, fecha, hora);

        // 7. Ocupación de horario
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
            
            if (recordatorioTurnosService != null) {
                recordatorioTurnosService.procesarAhora();
            }
            return new ResultadoCreacion(convertirADto(guardado), false);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_OCUPADO", "El médico ya tiene un turno reservado en ese horario.");
        }
    }

    /**
     * Reprograma un turno validando que pertenezca al paciente en sesión si no es admin.
     */
    @Transactional
    public TurnoRespuesta reprogramar(Integer id, TurnoReprogramarSolicitud solicitud) {
        Turno turno = turnoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado."));

        UsuarioActual actual = proveedorUsuarioActual.obtenerActual().orElse(null);
        if (actual != null && !actual.esAdmin()) {
            if (actual.pacienteId() == null || !actual.pacienteId().equals(turno.getPaciente().getId())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para acceder a este turno.");
            }
        }

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

        validarHorarioDisponible(medico, nuevaFecha, nuevaHora);

        if (turnoRepository.existsByMedicoIdAndFechaAndHoraAndEstadoNotAndIdNot(medico.getId(), nuevaFecha, nuevaHora, "CANCELADO", id)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_OCUPADO", "El médico ya tiene un turno reservado en ese horario.");
        }

        if ("CONFIRMADO".equals(turno.getEstado())) {
            turno.setEstado("PENDIENTE");
        }
        turno.setFecha(nuevaFecha);
        turno.setHora(nuevaHora);
        turno.setRecordatorioEnviado(false);
        turno.setRespuestaPaciente("SIN_RESPUESTA");
        turno.setTokenRespuesta(null);

        try {
            Turno guardado = turnoRepository.save(turno);
            
            String msg = String.format("%s %s cambió su turno con Dr/a. %s al %02d/%02d a las %s. Queda pendiente de confirmación.", 
                guardado.getPaciente().getUsuario().getNombre(), guardado.getPaciente().getUsuario().getApellido(),
                guardado.getMedico().getApellido(), guardado.getFecha().getDayOfMonth(), guardado.getFecha().getMonthValue(),
                guardado.getHora().format(FORMATO_HORA));
            notificacionService.crearParaAdmins(guardado, "TURNO_REPROGRAMADO", "Turno reprogramado", msg);
            
            return convertirADto(guardado);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_OCUPADO", "El médico ya tiene un turno reservado en ese horario.");
        }
    }

    /**
     * Modifica el estado del turno aplicando autorización estricta por rol (PACIENTE solo CANCELADO, ADMIN cualquiera).
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

        String origen = solicitud.getOrigen();
        UsuarioActual actual = proveedorUsuarioActual.obtenerActual().orElse(null);
        if (actual != null && !actual.esAdmin()) {
            if (actual.pacienteId() == null || !actual.pacienteId().equals(turno.getPaciente().getId())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para acceder a este turno.");
            }
            if (!"CANCELADO".equals(nuevoEstado)) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para realizar esta transición de estado.");
            }
            origen = "PACIENTE";
        } else if (actual != null && actual.esAdmin()) {
            if (origen == null || origen.isBlank()) {
                origen = "CENTRO";
            }
        }

        String estadoActual = turno.getEstado();

        // Mismo estado
        if (nuevoEstado.equals(estadoActual)) {
            return convertirADto(turno);
        }

        // Transiciones
        boolean esValida = false;
        if ("PENDIENTE".equals(estadoActual)) {
            esValida = "CONFIRMADO".equals(nuevoEstado) || "CANCELADO".equals(nuevoEstado);
        } else if ("CONFIRMADO".equals(estadoActual)) {
            esValida = "ATENDIDO".equals(nuevoEstado) || "CANCELADO".equals(nuevoEstado);
        }

        if (!esValida) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "TRANSICION_INVALIDA", "No se permite cambiar el estado de " + estadoActual + " a " + nuevoEstado + ".");
        }

        if ("ATENDIDO".equals(nuevoEstado)) {
            LocalDate hoy = LocalDate.now(ZONA_BUENOS_AIRES);
            if (turno.getFecha().isAfter(hoy)) {
                throw new ExcepcionApi(HttpStatus.CONFLICT, "TRANSICION_INVALIDA", "No se puede marcar como ATENDIDO un turno con fecha futura.");
            }
        }

        if ("CONFIRMADO".equals(nuevoEstado)) {
            LocalDateTime inicio = LocalDateTime.of(turno.getFecha(), turno.getHora());
            LocalDateTime ahora = LocalDateTime.now(ZONA_BUENOS_AIRES);
            if (inicio.minusHours(24).isAfter(ahora)) {
                throw new ExcepcionApi(HttpStatus.CONFLICT, "CONFIRMACION_ANTICIPADA", "Solo se pueden confirmar turnos que empiezan en las próximas 24 horas.");
            }
        }

        turno.setEstado(nuevoEstado);
        Turno guardado = turnoRepository.save(turno);

        if ("CONFIRMADO".equals(nuevoEstado)) {
            String msg = String.format("Te esperamos el %02d/%02d a las %s con %s.", guardado.getFecha().getDayOfMonth(), guardado.getFecha().getMonthValue(), guardado.getHora().format(FORMATO_HORA), guardado.getMedico().getNombre() + " " + guardado.getMedico().getApellido());
            notificacionService.crearParaPaciente(guardado, "TURNO_CONFIRMADO", "Tu turno fue confirmado", msg);
        }
        
        if ("CANCELADO".equals(nuevoEstado)) {
            if ("CENTRO".equals(origen)) {
                String msg = String.format("El centro canceló tu turno del %02d/%02d a las %s. Podés pedir uno nuevo desde la app.", guardado.getFecha().getDayOfMonth(), guardado.getFecha().getMonthValue(), guardado.getHora().format(FORMATO_HORA));
                notificacionService.crearParaPaciente(guardado, "TURNO_CANCELADO_CENTRO", "Tu turno fue cancelado", msg);
            } else if ("PACIENTE".equals(origen)) {
                // Notificación para los administradores cuando el paciente cancela su turno.
                // Como el tipo en la BD es ENUM, reutilizamos PACIENTE_NO_ASISTIRA con título y mensaje personalizados.
                String msg = String.format("%s %s canceló su turno del %02d/%02d a las %s con Dr/a. %s. El horario quedó libre.",
                        guardado.getPaciente().getUsuario().getNombre(),
                        guardado.getPaciente().getUsuario().getApellido(),
                        guardado.getFecha().getDayOfMonth(),
                        guardado.getFecha().getMonthValue(),
                        guardado.getHora().format(FORMATO_HORA),
                        guardado.getMedico().getApellido());
                notificacionService.crearParaAdmins(guardado, "PACIENTE_NO_ASISTIRA", "Turno cancelado por el paciente", msg);
            }
        }

        return convertirADto(guardado);
    }

    /**
     * Mantiene la eliminación del turno.
     */
    @Transactional
    public void eliminar(Integer id) {
        if (!turnoRepository.existsById(id)) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado.");
        }
        turnoRepository.deleteById(id);
    }

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

    private void validarHorarioDisponible(Medico medico, LocalDate fecha, LocalTime hora) {
        LocalDateTime ahora = LocalDateTime.now(ZONA_BUENOS_AIRES);
        LocalDateTime fechaHoraTurno = LocalDateTime.of(fecha, hora);

        if (fechaHoraTurno.isBefore(ahora)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_NO_DISPONIBLE", "La fecha y hora especificadas ya han pasado.");
        }

        int diaSemana = fecha.getDayOfWeek().getValue();

        List<HorarioAtencion> franjas = horarioAtencionRepository.findByMedicoIdAndDiaSemanaAndActivoTrueOrderByHoraInicioAsc(medico.getId(), diaSemana);
        if (franjas.isEmpty()) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "HORARIO_NO_DISPONIBLE", "El médico no atiende el día de la semana correspondiente a la fecha.");
        }

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

        boolean puedeConfirmarse = false;
        if ("PENDIENTE".equals(turno.getEstado()) && turno.getFecha() != null && turno.getHora() != null) {
            LocalDateTime inicio = LocalDateTime.of(turno.getFecha(), turno.getHora());
            puedeConfirmarse = !inicio.minusHours(24).isAfter(LocalDateTime.now(ZONA_BUENOS_AIRES));
        }

        return new TurnoRespuesta(
                turno.getId(),
                turno.getEstado(),
                fechaStr,
                horaStr,
                turno.getClaveSolicitud(),
                fechaCreacionStr,
                turno.getRespuestaPaciente(),
                puedeConfirmarse,
                Boolean.TRUE.equals(turno.getPaciente().getUsuario().getContrasenaPendiente()),
                pacienteDto,
                medicoDto
        );
    }

    /**
     * Procesa la respuesta del paciente validando la propiedad del turno.
     */
    @Transactional
    public TurnoRespuesta responderAsistencia(Integer id, Boolean asistira) {
        Turno turno = turnoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "TURNO_NO_ENCONTRADO", "Turno no encontrado."));

        UsuarioActual actual = proveedorUsuarioActual.obtenerActual().orElse(null);
        if (actual != null && !actual.esAdmin()) {
            if (actual.pacienteId() == null || !actual.pacienteId().equals(turno.getPaciente().getId())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para acceder a este turno.");
            }
        }

        if (!"PENDIENTE".equals(turno.getEstado()) && !"CONFIRMADO".equals(turno.getEstado())) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "TURNO_NO_MODIFICABLE", "Solo se puede responder asistencia para turnos PENDIENTES o CONFIRMADOS.");
        }

        String tituloNotif;
        String msgNotif;
        if (Boolean.TRUE.equals(asistira)) {
            turno.setRespuestaPaciente("ASISTIRA");
            tituloNotif = "Confirmó asistencia";
            msgNotif = String.format("%s %s confirmó que asiste el %02d/%02d a las %s. Ya podés confirmar el turno.", turno.getPaciente().getUsuario().getNombre(), turno.getPaciente().getUsuario().getApellido(), turno.getFecha().getDayOfMonth(), turno.getFecha().getMonthValue(), turno.getHora().format(FORMATO_HORA));
            notificacionService.crearParaAdmins(turno, "PACIENTE_ASISTIRA", tituloNotif, msgNotif);
        } else {
            turno.setRespuestaPaciente("NO_ASISTIRA");
            turno.setEstado("CANCELADO");
            tituloNotif = "Canceló su turno";
            msgNotif = String.format("%s %s avisó que no asiste el %02d/%02d a las %s. El horario quedó libre.", turno.getPaciente().getUsuario().getNombre(), turno.getPaciente().getUsuario().getApellido(), turno.getFecha().getDayOfMonth(), turno.getFecha().getMonthValue(), turno.getHora().format(FORMATO_HORA));
            notificacionService.crearParaAdmins(turno, "PACIENTE_NO_ASISTIRA", tituloNotif, msgNotif);
        }
        
        Turno guardado = turnoRepository.save(turno);
        
        notificacionService.marcarRecordatorioLeido(id);
        
        return convertirADto(guardado);
    }
}
