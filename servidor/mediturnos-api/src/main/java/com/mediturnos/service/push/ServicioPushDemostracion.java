package com.mediturnos.service.push;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * Implementación de demostración para desarrollo local que simula el envío de notificaciones push.
 */
@Service
@ConditionalOnProperty(name = "mediturnos.push.proveedor", havingValue = "demostracion", matchIfMissing = true)
public class ServicioPushDemostracion implements ServicioPush {

    private static final Logger log = LoggerFactory.getLogger(ServicioPushDemostracion.class);

    @Override
    @Async
    public void registrarDispositivo(String installationId, String tokenFcm, Long usuarioId, String rol) {
        try {
            String tokenParcial = (tokenFcm != null && tokenFcm.length() >= 8) ? tokenFcm.substring(0, 8) + "..." : "...";
            log.info("Simulando registro de dispositivo. InstallationId: {}, FCM Token: {}, UsuarioId: {}, Rol: {}",
                    installationId, tokenParcial, usuarioId, rol);
        } catch (Exception e) {
            log.warn("Error inesperado en simulación de registro de dispositivo: {}", e.getMessage());
        }
    }

    @Override
    @Async
    public void eliminarDispositivo(String installationId, Long usuarioId) {
        try {
            log.info("Simulando eliminación de dispositivo. InstallationId: {}, UsuarioId: {}", installationId, usuarioId);
        } catch (Exception e) {
            log.warn("Error inesperado en simulación de eliminación de dispositivo: {}", e.getMessage());
        }
    }

    @Override
    @Async
    public void enviarAUsuario(Long usuarioId, String titulo, String cuerpo, Map<String, String> datos) {
        try {
            log.info("Simulando envío de notificación push a UsuarioId: {}. Título: '{}', Cuerpo: '{}', Datos: {}",
                    usuarioId, titulo, cuerpo, datos);
        } catch (Exception e) {
            log.warn("Error inesperado en simulación de envío de notificación push: {}", e.getMessage());
        }
    }
}
