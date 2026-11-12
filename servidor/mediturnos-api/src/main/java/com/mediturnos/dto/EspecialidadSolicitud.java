package com.mediturnos.dto;

import lombok.Data;

/**
 * DTO de entrada para crear o actualizar una especialidad médica.
 */
@Data
public class EspecialidadSolicitud {
    // Nombre de la especialidad (obligatorio, 2 a 100 caracteres)
    private String nombre;
    // Descripción opcional de la especialidad (máximo 255 caracteres)
    private String descripcion;
}
