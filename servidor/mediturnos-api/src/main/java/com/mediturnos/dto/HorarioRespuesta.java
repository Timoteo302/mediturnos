package com.mediturnos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida para los horarios de atención de un médico.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HorarioRespuesta {
    // Identificador único de la franja horaria
    private Integer id;
    // Día de la semana (1 = Lunes, 7 = Domingo)
    private Integer diaSemana;
    // Hora de inicio formateada en formato estricto "HH:mm"
    private String horaInicio;
    // Hora de fin formateada en formato estricto "HH:mm"
    private String horaFin;
    // Duración estimada de cada turno en minutos
    private Integer duracionTurno;
    // Estado de la franja horaria (activo=true)
    private Boolean activo;
}
