package com.mediturnos.service.correo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

/**
 * Implementación falsa (mock) del envío de correos para entornos de desarrollo.
 * Solo imprime en el log el destino, asunto y código.
 */
@Service
@ConditionalOnProperty(name = "mediturnos.correo.proveedor", havingValue = "demostracion", matchIfMissing = true)
public class ServicioCorreoDemostracion implements ServicioCorreo {

    private static final Logger log = LoggerFactory.getLogger(ServicioCorreoDemostracion.class);

    @Override
    public void enviarCodigoActivacion(String email, String nombre, String codigo, String resumenTurno) {
        log.info("Simulando envío de correo a: {}", email);
        log.info("Asunto: Activá tu cuenta en MediTurnos");
        log.info("Hola {}, {} Tu código de activación es: {}", nombre, resumenTurno != null ? resumenTurno + " " : "", codigo);
    }

    @Override
    public void enviarCodigoRecuperacion(String email, String nombre, String codigo) {
        log.info("Simulando envío de correo a: {}", email);
        log.info("Asunto: Recuperación de contraseña - MediTurnos");
        log.info("Hola {}, tu código de recuperación es: {}", nombre, codigo);
    }
}
