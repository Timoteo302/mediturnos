package com.mediturnos.service.correo;

import com.mediturnos.dto.DatosTurnoCorreo;

/**
 * Interfaz para el envío de correos electrónicos.
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

    /**
     * Envía un correo de recordatorio de asistencia con botones de respuesta.
     */
    void enviarRecordatorioAsistencia(String email, String nombre, DatosTurnoCorreo turno, String urlSi, String urlNo);

    /**
     * Envía un correo notificando la confirmación de un turno por parte del centro.
     */
    void enviarTurnoConfirmado(String email, String nombre, DatosTurnoCorreo turno);

    /**
     * Envía un correo notificando la cancelación de un turno por parte del centro.
     */
    void enviarTurnoCanceladoCentro(String email, String nombre, DatosTurnoCorreo turno);
}
