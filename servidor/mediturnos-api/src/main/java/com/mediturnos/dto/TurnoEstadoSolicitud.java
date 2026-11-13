package com.mediturnos.dto;

import lombok.Data;

/**
 * DTO de entrada para actualizar el estado de un turno via PATCH.
 */
@Data
public class TurnoEstadoSolicitud {
    private String estado;
}
