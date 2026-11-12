package com.mediturnos.dto;

import lombok.Data;

/**
 * DTO de entrada para crear o actualizar los datos de un médico.
 */
@Data
public class MedicoSolicitud {
    // Nombre del médico (obligatorio, 2 a 100 caracteres)
    private String nombre;
    // Apellido del médico (obligatorio, 2 a 100 caracteres)
    private String apellido;
    // ID de la especialidad asociada
    private Integer especialidadId;
    // Matrícula profesional (obligatoria, solo dígitos, entre 3 y 10 caracteres)
    private String matricula;
    // Estado activo/inactivo (opcional en POST por defecto true, obligatorio en PUT)
    private Boolean activo;
}
