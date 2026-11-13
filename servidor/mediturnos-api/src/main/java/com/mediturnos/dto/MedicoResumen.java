package com.mediturnos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida con los datos resumidos del médico y su especialidad.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MedicoResumen {
    private Integer id;
    private String nombre;
    private String apellido;
    private String matricula;
    private EspecialidadResumen especialidad;
}
