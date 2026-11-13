package com.mediturnos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida para los horarios de disponibilidad de un médico.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HorarioDisponibilidadRespuesta {
    private String hora;
    private Boolean disponible;
}
