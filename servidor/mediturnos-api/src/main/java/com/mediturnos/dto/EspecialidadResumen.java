package com.mediturnos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida simplificado para incluir la especialidad dentro de la respuesta de un médico.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class EspecialidadResumen {
    // Identificador único de la especialidad
    private Integer id;
    // Nombre de la especialidad
    private String nombre;
}
