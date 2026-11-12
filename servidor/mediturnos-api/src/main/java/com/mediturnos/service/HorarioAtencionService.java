package com.mediturnos.service;

import com.mediturnos.dto.AgendaSolicitud;
import com.mediturnos.dto.HorarioRespuesta;
import com.mediturnos.dto.HorarioSolicitud;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.HorarioAtencion;
import com.mediturnos.model.Medico;
import com.mediturnos.repository.HorarioAtencionRepository;
import com.mediturnos.repository.MedicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Servicio para gestionar la lógica de los horarios de atención médica.
 */
@Service
public class HorarioAtencionService {

    @Autowired
    private HorarioAtencionRepository horarioAtencionRepository;

    @Autowired
    private MedicoRepository medicoRepository;

    private static final DateTimeFormatter FORMATO_HORA = DateTimeFormatter.ofPattern("HH:mm");
    private static final Pattern PATRON_HHMM = Pattern.compile("^([01]\\d|2[0-3]):[0-5]\\d$");

    /**
     * Obtiene los horarios activos de un médico ordenados por día de semana y hora de inicio.
     * @param medicoId ID del médico.
     * @return Lista de HorarioRespuesta.
     */
    @Transactional(readOnly = true)
    public List<HorarioRespuesta> obtenerHorariosPorMedico(Integer medicoId) {
        if (!medicoRepository.existsById(medicoId)) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado.");
        }
        List<HorarioAtencion> horarios = horarioAtencionRepository.findByMedicoIdAndActivoTrueOrderByDiaSemanaAscHoraInicioAsc(medicoId);
        return horarios.stream()
                .map(this::convertirADto)
                .collect(Collectors.toList());
    }

    /**
     * Reemplaza de forma atómica toda la agenda de atención de un médico.
     * @param medicoId ID del médico.
     * @param solicitud DTO con la lista de franjas horarias.
     * @return Lista completa de la nueva agenda guardada.
     */
    @Transactional
    public List<HorarioRespuesta> reemplazarAgenda(Integer medicoId, AgendaSolicitud solicitud) {
        Medico medico = medicoRepository.findById(medicoId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado."));

        if (solicitud == null || solicitud.getHorarios() == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La lista de horarios es obligatoria.", "horarios");
        }

        List<HorarioSolicitud> listaHorarios = solicitud.getHorarios();

        // Estructura temporal para almacenar las franjas procesadas
        class FranjaProcesada {
            int dia;
            LocalTime inicio;
            LocalTime fin;
            int duracion;

            FranjaProcesada(int dia, LocalTime inicio, LocalTime fin, int duracion) {
                this.dia = dia;
                this.inicio = inicio;
                this.fin = fin;
                this.duracion = duracion;
            }
        }

        List<FranjaProcesada> procesadas = new ArrayList<>();

        // 1. Validar cada franja individualmente
        for (HorarioSolicitud item : listaHorarios) {
            if (item == null) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "No se permiten elementos nulos en los horarios.", "horarios");
            }

            // Validar día de la semana (1 a 7)
            if (item.getDiaSemana() == null || item.getDiaSemana() < 1 || item.getDiaSemana() > 7) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El día de la semana debe estar entre 1 y 7.", "horarios");
            }

            // Validar formato estricto de horaInicio (HH:mm)
            if (item.getHoraInicio() == null || !PATRON_HHMM.matcher(item.getHoraInicio().trim()).matches()) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La hora de inicio debe tener formato estricto HH:mm.", "horarios");
            }
            LocalTime inicio;
            try {
                inicio = LocalTime.parse(item.getHoraInicio().trim(), FORMATO_HORA);
            } catch (DateTimeParseException e) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La hora de inicio es inválida.", "horarios");
            }

            // Validar formato estricto de horaFin (HH:mm)
            if (item.getHoraFin() == null || !PATRON_HHMM.matcher(item.getHoraFin().trim()).matches()) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La hora de fin debe tener formato estricto HH:mm.", "horarios");
            }
            LocalTime fin;
            try {
                fin = LocalTime.parse(item.getHoraFin().trim(), FORMATO_HORA);
            } catch (DateTimeParseException e) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La hora de fin es inválida.", "horarios");
            }

            // Validar horaInicio < horaFin
            if (!inicio.isBefore(fin)) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La hora de inicio debe ser anterior a la hora de fin.", "horarios");
            }

            // Validar duración del turno (entre 5 y 240 minutos)
            if (item.getDuracionTurno() == null || item.getDuracionTurno() < 5 || item.getDuracionTurno() > 240) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La duración del turno debe estar entre 5 y 240 minutos.", "horarios");
            }

            // Validar que la franja dure al menos la duración del turno
            long minutosFranja = Duration.between(inicio, fin).toMinutes();
            if (minutosFranja < item.getDuracionTurno()) {
                throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La franja horaria debe durar al menos la duración del turno.", "horarios");
            }

            procesadas.add(new FranjaProcesada(item.getDiaSemana(), inicio, fin, item.getDuracionTurno()));
        }

        // 2. Validar duplicados y superposiciones por día
        Map<Integer, List<FranjaProcesada>> porDia = procesadas.stream()
                .collect(Collectors.groupingBy(f -> f.dia));

        for (Map.Entry<Integer, List<FranjaProcesada>> entry : porDia.entrySet()) {
            int dia = entry.getKey();
            List<FranjaProcesada> franjasDelDia = entry.getValue();

            // Verificar franjas con la misma horaInicio
            Set<LocalTime> iniciosVistos = new HashSet<>();
            for (FranjaProcesada f : franjasDelDia) {
                if (!iniciosVistos.add(f.inicio)) {
                    throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "No pueden existir dos franjas el mismo día con la misma hora de inicio.", "horarios");
                }
            }

            // Verificar superposiciones entre franjas del mismo día
            int count = franjasDelDia.size();
            for (int i = 0; i < count; i++) {
                for (int j = i + 1; j < count; j++) {
                    FranjaProcesada f1 = franjasDelDia.get(i);
                    FranjaProcesada f2 = franjasDelDia.get(j);
                    // Dos franjas [A, B) y [C, D) se superponen si A < D y C < B
                    if (f1.inicio.isBefore(f2.fin) && f2.inicio.isBefore(f1.fin)) {
                        String nombreDia = obtenerNombreDia(dia);
                        throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Las franjas del " + nombreDia + " se superponen.", "horarios");
                    }
                }
            }
        }

        // 3. Reemplazo atómico en base de datos
        try {
            // Borrar masivamente todas las filas anteriores del médico (activas e inactivas)
            horarioAtencionRepository.deleteByMedicoId(medicoId);
            horarioAtencionRepository.flush();

            // Insertar la nueva lista de franjas
            for (FranjaProcesada fp : procesadas) {
                HorarioAtencion nuevo = new HorarioAtencion();
                nuevo.setMedico(medico);
                nuevo.setDiaSemana(fp.dia);
                nuevo.setHoraInicio(fp.inicio);
                nuevo.setHoraFin(fp.fin);
                nuevo.setDuracionTurno(fp.duracion);
                nuevo.setActivo(true);
                horarioAtencionRepository.save(nuevo);
            }

            horarioAtencionRepository.flush();
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Error de integridad de datos al guardar horarios.", "horarios");
        }

        // Devolver la nueva agenda guardada ordenada
        return obtenerHorariosPorMedico(medicoId);
    }

    /**
     * Retorna el nombre en español del día de la semana.
     */
    private String obtenerNombreDia(int diaSemana) {
        switch (diaSemana) {
            case 1: return "lunes";
            case 2: return "martes";
            case 3: return "miércoles";
            case 4: return "jueves";
            case 5: return "viernes";
            case 6: return "sábado";
            case 7: return "domingo";
            default: return "día";
        }
    }

    /**
     * Convierte la entidad HorarioAtencion a su DTO HorarioRespuesta.
     */
    private HorarioRespuesta convertirADto(HorarioAtencion horario) {
        return new HorarioRespuesta(
                horario.getId(),
                horario.getDiaSemana(),
                horario.getHoraInicio().format(FORMATO_HORA),
                horario.getHoraFin().format(FORMATO_HORA),
                horario.getDuracionTurno(),
                horario.getActivo()
        );
    }
}
