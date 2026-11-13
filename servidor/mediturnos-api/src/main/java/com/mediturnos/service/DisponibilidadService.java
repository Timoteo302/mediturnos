package com.mediturnos.service;

import com.mediturnos.dto.HorarioDisponibilidadRespuesta;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.HorarioAtencion;
import com.mediturnos.model.Medico;

import com.mediturnos.model.Turno;
import com.mediturnos.repository.HorarioAtencionRepository;
import com.mediturnos.repository.MedicoRepository;
import com.mediturnos.repository.TurnoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Servicio encargado de calcular la disponibilidad horaria de los médicos.
 */
@Service
public class DisponibilidadService {

    @Autowired
    private MedicoRepository medicoRepository;

    @Autowired
    private HorarioAtencionRepository horarioAtencionRepository;

    @Autowired
    private TurnoRepository turnoRepository;

    private static final ZoneId ZONA_BUENOS_AIRES = ZoneId.of("America/Argentina/Buenos_Aires");
    private static final DateTimeFormatter FORMATO_HHMM = DateTimeFormatter.ofPattern("HH:mm");

    /**
     * Calcula los horarios disponibles de un médico para una fecha específica.
     * @param medicoId ID del médico.
     * @param fechaStr Fecha en formato YYYY-MM-DD.
     * @return Lista de HorarioDisponibilidadRespuesta ordenada por hora.
     */
    @Transactional(readOnly = true)
    public List<HorarioDisponibilidadRespuesta> obtenerDisponibilidad(Integer medicoId, String fechaStr) {
        // Verificar existencia del médico
        Medico medico = medicoRepository.findById(medicoId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado."));

        // Validar formato de fecha
        if (fechaStr == null || fechaStr.trim().isEmpty()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La fecha es obligatoria.", "fecha");
        }

        LocalDate fecha;
        try {
            fecha = LocalDate.parse(fechaStr.trim());
        } catch (DateTimeParseException e) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Formato de fecha inválido (debe ser YYYY-MM-DD).", "fecha");
        }

        // Si el médico está inactivo, no tiene disponibilidad
        if (!Boolean.TRUE.equals(medico.getActivo())) {
            return Collections.emptyList();
        }

        // Contexto de fecha y hora actual en Buenos Aires
        LocalDate hoy = LocalDate.now(ZONA_BUENOS_AIRES);
        LocalTime ahora = LocalTime.now(ZONA_BUENOS_AIRES);

        // Día de la semana (1 = Lunes, 7 = Domingo)
        int diaSemana = fecha.getDayOfWeek().getValue();

        // Buscar las franjas de atención activas del médico para ese día
        List<HorarioAtencion> franjas = horarioAtencionRepository.findByMedicoIdAndDiaSemanaAndActivoTrueOrderByHoraInicioAsc(medicoId, diaSemana);
        if (franjas.isEmpty()) {
            return Collections.emptyList();
        }

        // Obtener turnos no cancelados del médico para esa fecha
        List<Turno> turnosReservados = turnoRepository.findByMedicoIdAndFechaAndEstadoNot(medicoId, fecha, "CANCELADO");
        Set<LocalTime> horasOcupadas = turnosReservados.stream()
                .map(Turno::getHora)
                .collect(Collectors.toSet());

        // Generar los slots de cada franja usando un Map para ordenar por hora
        Map<LocalTime, Boolean> slotsDisponibilidad = new TreeMap<>();

        for (HorarioAtencion f : franjas) {
            LocalTime t = f.getHoraInicio();
            int duracion = f.getDuracionTurno();
            LocalTime fin = f.getHoraFin();

            while (!t.plusMinutes(duracion).isAfter(fin)) {
                boolean disponible = true;

                // Regla: fecha anterior a hoy -> todo inhabilitado
                if (fecha.isBefore(hoy)) {
                    disponible = false;
                }
                // Regla: fecha de hoy y hora pasada o presente -> inhabilitado
                else if (fecha.isEqual(hoy) && !t.isAfter(ahora)) {
                    disponible = false;
                }
                // Regla: ya existe un turno reservado no cancelado
                else if (horasOcupadas.contains(t)) {
                    disponible = false;
                }

                // Guardar la disponibilidad calculada
                slotsDisponibilidad.putIfAbsent(t, disponible);

                t = t.plusMinutes(duracion);
            }
        }

        // Mapear el mapa a la lista DTO de salida
        return slotsDisponibilidad.entrySet().stream()
                .map(entry -> new HorarioDisponibilidadRespuesta(
                        entry.getKey().format(FORMATO_HHMM),
                        entry.getValue()
                ))
                .collect(Collectors.toList());
    }
}
