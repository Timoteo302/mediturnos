package com.mediturnos.dto;

import lombok.Data;
import java.util.List;

/**
 * DTO de entrada para la solicitud de reemplazo completo de la agenda de un médico.
 */
@Data
public class AgendaSolicitud {
    // Lista de franjas horarias que compondrán la nueva agenda del médico
    private List<HorarioSolicitud> horarios;
}
