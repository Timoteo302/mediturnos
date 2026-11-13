package com.mediturnos.dto;

import lombok.Data;

/**
 * DTO de entrada para reprogramar la fecha y hora de un turno.
 */
@Data
public class TurnoReprogramarSolicitud {
    private String fecha;
    private String hora;
}
