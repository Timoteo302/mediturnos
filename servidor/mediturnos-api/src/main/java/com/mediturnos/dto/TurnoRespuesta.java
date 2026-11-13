package com.mediturnos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida para representar un turno completo sin información sensible.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TurnoRespuesta {
    private Integer id;
    private String estado;
    private String fecha;
    private String hora;
    private String claveSolicitud;
    private String fechaCreacion;
    private PacienteResumen paciente;
    private MedicoResumen medico;
}
