package com.mediturnos.dto;

/**
 * Record con los datos estructurados del turno formateados para incluir en las plantillas de correo.
 */
public record DatosTurnoCorreo(
        String medico,
        String especialidad,
        String fecha,
        String hora
) {
}
