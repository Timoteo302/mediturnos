package com.mediturnos.security;

import com.mediturnos.model.Usuario;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Componente que obtiene los datos del usuario autenticado actual a partir del token JWT del SecurityContext.
 */
@Component
public class ProveedorUsuarioActual {

    /**
     * Obtiene el UsuarioActual a partir del token JWT autenticado si existe.
     */
    public Optional<UsuarioActual> obtenerActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || !(auth.getPrincipal() instanceof Jwt jwt)) {
            return Optional.empty();
        }

        try {
            Integer id = Integer.valueOf(jwt.getSubject());
            String email = jwt.getClaimAsString("email");
            String rolStr = jwt.getClaimAsString("rol");
            Usuario.Rol rol = rolStr != null ? Usuario.Rol.valueOf(rolStr) : Usuario.Rol.PACIENTE;

            Object pacClaim = jwt.getClaim("pacienteId");
            Integer pacienteId = null;
            if (pacClaim instanceof Number num) {
                pacienteId = num.intValue();
            }

            return Optional.of(new UsuarioActual(id, email, rol, pacienteId));
        } catch (Exception e) {
            return Optional.empty();
        }
    }
}
