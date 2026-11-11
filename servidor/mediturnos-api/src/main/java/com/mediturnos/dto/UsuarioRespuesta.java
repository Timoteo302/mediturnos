package com.mediturnos.dto;

import java.time.LocalDateTime;

public record UsuarioRespuesta(
    Integer id,
    String nombre,
    String apellido,
    String email,
    String rol,
    Boolean activo,
    LocalDateTime fechaCreacion,
    PacienteResumen paciente
) {}
