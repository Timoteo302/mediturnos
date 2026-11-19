package com.mediturnos.dto;

import java.time.LocalDateTime;

/**
 * DTO para la respuesta de una notificación.
 */
public record NotificacionRespuesta(
        Integer id,
        String tipo,
        String titulo,
        String mensaje,
        Boolean leida,
        LocalDateTime fechaCreacion,
        Integer turnoId,
        String turnoFecha,
        String turnoHora,
        String turnoEstado,
        String respuestaPaciente
) {
}
