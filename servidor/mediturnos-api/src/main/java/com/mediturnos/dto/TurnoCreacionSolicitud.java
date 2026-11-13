package com.mediturnos.dto;

import lombok.Data;

/**
 * DTO de entrada para la creación de un turno.
 * Compatible con la estructura enviada por la app Flutter ({paciente:{id}, medico:{id}, fecha, hora, estado, claveSolicitud})
 * así como id directos (pacienteId, medicoId).
 */
@Data
public class TurnoCreacionSolicitud {
    private IdReferencia paciente;
    private Integer pacienteId;

    private IdReferencia medico;
    private Integer medicoId;

    private String fecha;
    private String hora;
    private String estado;
    private String claveSolicitud;

    @Data
    public static class IdReferencia {
        private Integer id;
    }

    public Integer getPacienteIdEfectivo() {
        if (pacienteId != null) return pacienteId;
        if (paciente != null) return paciente.getId();
        return null;
    }

    public Integer getMedicoIdEfectivo() {
        if (medicoId != null) return medicoId;
        if (medico != null) return medico.getId();
        return null;
    }
}
