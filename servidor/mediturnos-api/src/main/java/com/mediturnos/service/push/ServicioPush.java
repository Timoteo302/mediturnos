package com.mediturnos.service.push;

import java.util.Map;

/**
 * Interfaz para el registro de dispositivos móviles y el envío de notificaciones push.
 */
public interface ServicioPush {

    /**
     * Registra la instalación de un dispositivo con su token FCM en la plataforma push.
     */
    void registrarDispositivo(String installationId, String tokenFcm, Long usuarioId, String rol);

    /**
     * Elimina el registro de una instalación si pertenece al usuario solicitante.
     */
    void eliminarDispositivo(String installationId, Long usuarioId);

    /**
     * Envía una notificación push a todos los dispositivos registrados del usuario.
     */
    void enviarAUsuario(Long usuarioId, String titulo, String cuerpo, Map<String, String> datos);
}
