package com.mediturnos.controller;

import com.mediturnos.dto.DispositivoSolicitud;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.security.ProveedorUsuarioActual;
import com.mediturnos.security.UsuarioActual;
import com.mediturnos.service.push.ServicioPush;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.regex.Pattern;

/**
 * Endpoints para registrar y eliminar los celulares (tokens FCM) del usuario autenticado para notificaciones push.
 */
@RestController
@RequestMapping("/dispositivos")
@CrossOrigin(origins = "*")
public class DispositivoController {

    private static final Pattern PATRON_INSTALLATION_ID = Pattern.compile("^[A-Za-z0-9-]{8,64}$");

    @Autowired
    private ServicioPush servicioPush;

    @Autowired
    private ProveedorUsuarioActual proveedorUsuarioActual;

    /**
     * Registra el token FCM de un celular asociándolo al ID y rol del usuario autenticado por JWT.
     */
    @PutMapping("/{installationId}")
    public ResponseEntity<Void> registrar(
            @PathVariable String installationId,
            @RequestBody(required = false) DispositivoSolicitud solicitud) {

        validarInstallationId(installationId);

        if (solicitud == null || solicitud.tokenFcm() == null || solicitud.tokenFcm().isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El token FCM es obligatorio", "tokenFcm");
        }

        UsuarioActual usuarioActual = proveedorUsuarioActual.obtenerActual()
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.UNAUTHORIZED, "NO_AUTENTICADO", "Se requiere autenticación"));

        servicioPush.registrarDispositivo(installationId, solicitud.tokenFcm().trim(), (long) usuarioActual.id(), usuarioActual.rol().name());

        return ResponseEntity.noContent().build();
    }

    /**
     * Elimina el registro de un celular si pertenece al usuario autenticado.
     */
    @DeleteMapping("/{installationId}")
    public ResponseEntity<Void> eliminar(@PathVariable String installationId) {
        validarInstallationId(installationId);

        UsuarioActual usuarioActual = proveedorUsuarioActual.obtenerActual()
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.UNAUTHORIZED, "NO_AUTENTICADO", "Se requiere autenticación"));

        servicioPush.eliminarDispositivo(installationId, (long) usuarioActual.id());

        return ResponseEntity.noContent().build();
    }

    private void validarInstallationId(String installationId) {
        if (installationId == null || !PATRON_INSTALLATION_ID.matcher(installationId).matches()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS",
                    "El ID de instalación debe tener entre 8 y 64 caracteres alfanuméricos o guiones", "installationId");
        }
    }
}
