package com.mediturnos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida para representar los detalles completos de una especialidad médica.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class EspecialidadRespuesta {
    // Identificador único de la especialidad
    private Integer id;
    // Nombre de la especialidad
    private String nombre;
    // Descripción opcional de la especialidad (puede ser null)
    private String descripcion;
    // Estado de actividad de la especialidad
    private Boolean activo;
}
