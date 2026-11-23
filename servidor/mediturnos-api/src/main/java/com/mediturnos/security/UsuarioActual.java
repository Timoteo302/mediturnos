package com.mediturnos.security;

import com.mediturnos.model.Usuario;

/**
 * Record que representa la identidad y rol del usuario autenticado extraído del token JWT.
 */
public record UsuarioActual(
        Integer id,
        String email,
        Usuario.Rol rol,
        Integer pacienteId
) {
    /**
     * Indica si el usuario autenticado tiene el rol de administrador.
     */
    public boolean esAdmin() {
        return rol == Usuario.Rol.ADMIN;
    }
}
