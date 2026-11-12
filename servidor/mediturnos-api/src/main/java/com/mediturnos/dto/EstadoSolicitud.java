package com.mediturnos.dto;

import lombok.Data;

/**
 * DTO de entrada para las peticiones PATCH que modifican el estado de activación.
 */
@Data
public class EstadoSolicitud {
    // Nuevo estado de activación (true = activo, false = inactivo)
    private Boolean activo;
}
