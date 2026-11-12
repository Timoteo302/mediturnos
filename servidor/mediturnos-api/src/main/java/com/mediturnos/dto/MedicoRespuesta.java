package com.mediturnos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida para representar la información de un médico.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MedicoRespuesta {
    // Identificador único del médico
    private Integer id;
    // Nombre del médico
    private String nombre;
    // Apellido del médico
    private String apellido;
    // Matrícula profesional del médico (puede ser null)
    private String matricula;
    // Estado activo o inactivo del médico
    private Boolean activo;
    // Resumen de la especialidad asociada al médico
    private EspecialidadResumen especialidad;
}
