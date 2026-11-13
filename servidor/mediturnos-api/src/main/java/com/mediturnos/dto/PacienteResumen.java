package com.mediturnos.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de salida con los datos resumidos del paciente.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PacienteResumen {
    private Integer id;
    private String nombre;
    private String apellido;
    private String dni;
    private String telefono;

    /**
     * Constructor de 3 argumentos para mantener compatibilidad con UsuarioService.
     */
    public PacienteResumen(Integer id, String dni, String telefono) {
        this.id = id;
        this.dni = dni;
        this.telefono = telefono;
    }
}
