package com.mediturnos.dto;

import lombok.Data;

/**
 * DTO de entrada para una franja horaria dentro de la agenda de atención.
 */
@Data
public class HorarioSolicitud {
    // Día de la semana (1 = Lunes a 7 = Domingo)
    private Integer diaSemana;
    // Hora de inicio en formato "HH:mm"
    private String horaInicio;
    // Hora de fin en formato "HH:mm"
    private String horaFin;
    // Duración de cada turno en minutos (entre 5 y 240)
    private Integer duracionTurno;
}
