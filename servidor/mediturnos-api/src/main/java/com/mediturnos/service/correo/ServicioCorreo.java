package com.mediturnos.service.correo;

/**
 * Interfaz para el envío de correos electrónicos.
 * En la etapa de Azure se agregará una implementación real (ej: Azure Communication Services Email o SendGrid).
 */
public interface ServicioCorreo {

    /**
     * Envía un código de activación a un invitado.
     */
    void enviarCodigoActivacion(String email, String nombre, String codigo, String resumenTurno);

    /**
     * Envía un código de recuperación de contraseña.
     */
    void enviarCodigoRecuperacion(String email, String nombre, String codigo);
}
