package com.mediturnos.service.correo;

import com.mediturnos.dto.DatosTurnoCorreo;
import org.springframework.stereotype.Component;
import org.springframework.web.util.HtmlUtils;

/**
 * Plantillas para armar el asunto y cuerpo (texto plano y HTML) de los correos electrónicos.
 */
@Component
public class PlantillasCorreo {

    public record ContenidoCorreo(String asunto, String textoPlano, String html) {}

    /**
     * Arma el contenido del correo para activación de cuenta.
     */
    public ContenidoCorreo armarCorreoActivacion(String nombre, String codigo, String resumenTurno) {
        String asunto = "Activá tu cuenta de MediTurnos";
        
        String parteResumenTexto = (resumenTurno != null && !resumenTurno.isBlank()) ? " " + resumenTurno : "";
        String textoPlano = "Hola " + nombre + "," + parteResumenTexto + "\n" +
                "Tu código para crear tu contraseña es: " + codigo + "\n" +
                "Vence en 7 días. Ingresalo en la app, en 'Activar mi cuenta'.\n" +
                "Si no fuiste vos, ignorá este correo.";

        String nombreEscaped = HtmlUtils.htmlEscape(nombre);
        String parteResumenHtml = (resumenTurno != null && !resumenTurno.isBlank()) ? "<p>" + HtmlUtils.htmlEscape(resumenTurno) + "</p>" : "";
        String html = "<p>Hola " + nombreEscaped + ",</p>" +
                parteResumenHtml +
                "<p>Tu código para crear tu contraseña es:</p>" +
                "<p style=\"font-size: 24px; font-weight: bold;\">" + codigo + "</p>" +
                "<p>Vence en 7 días. Ingresalo en la app, en 'Activar mi cuenta'.</p>" +
                "<p>Si no fuiste vos, ignorá este correo.</p>";

        return new ContenidoCorreo(asunto, textoPlano, html);
    }

    /**
     * Arma el contenido del correo para recuperación de contraseña.
     */
    public ContenidoCorreo armarCorreoRecuperacion(String nombre, String codigo) {
        String asunto = "Código para cambiar tu contraseña de MediTurnos";

        String textoPlano = "Hola " + nombre + ",\n" +
                "tu código es: " + codigo + "\n" +
                "Vence en 10 minutos.\n" +
                "Si no pediste cambiar tu contraseña, ignorá este correo.";

        String nombreEscaped = HtmlUtils.htmlEscape(nombre);
        String html = "<p>Hola " + nombreEscaped + ",</p>" +
                "<p>tu código es:</p>" +
                "<p style=\"font-size: 24px; font-weight: bold;\">" + codigo + "</p>" +
                "<p>Vence en 10 minutos.</p>" +
                "<p>Si no pediste cambiar tu contraseña, ignorá este correo.</p>";

        return new ContenidoCorreo(asunto, textoPlano, html);
    }

    /**
     * Arma el contenido del correo para recordatorio de asistencia a un turno.
     */
    public ContenidoCorreo armarRecordatorioAsistencia(String nombre, DatosTurnoCorreo turno, String urlSi, String urlNo) {
        String asunto = "¿Vas a asistir a tu turno?";

        String textoPlano = "Hola " + nombre + ", tenés turno:\n" +
                armarTablaTexto(turno) + "\n" +
                "Confirmá si vas a asistir:\n" +
                "Sí, voy a asistir: " + urlSi + "\n" +
                "No puedo ir: " + urlNo + "\n\n" +
                "También podés responder desde la app, en la campanita.";

        String nombreEscaped = HtmlUtils.htmlEscape(nombre);
        String html = "<p>Hola " + nombreEscaped + ", tenés turno:</p>" +
                armarTablaHtml(turno) +
                "<div style=\"margin: 20px 0;\">" +
                "<a href=\"" + urlSi + "\" style=\"background-color: #0d6efd; color: #ffffff; padding: 12px 20px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block; margin-right: 10px;\">Sí, voy a asistir</a>" +
                "<a href=\"" + urlNo + "\" style=\"background-color: #6c757d; color: #ffffff; padding: 12px 20px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;\">No puedo ir</a>" +
                "</div>" +
                "<p>También podés responder desde la app, en la campanita.</p>";

        return new ContenidoCorreo(asunto, textoPlano, html);
    }

    /**
     * Arma el contenido del correo para notificación de turno confirmado por el centro.
     */
    public ContenidoCorreo armarTurnoConfirmado(String nombre, DatosTurnoCorreo turno) {
        String asunto = "Tu turno está confirmado";

        String textoPlano = "Hola " + nombre + ", el centro confirmó tu turno:\n" +
                armarTablaTexto(turno) + "\n" +
                "Si no podés ir, cancelalo desde la app para liberar el horario.";

        String nombreEscaped = HtmlUtils.htmlEscape(nombre);
        String html = "<p>Hola " + nombreEscaped + ", el centro confirmó tu turno:</p>" +
                armarTablaHtml(turno) +
                "<p>Si no podés ir, cancelalo desde la app para liberar el horario.</p>";

        return new ContenidoCorreo(asunto, textoPlano, html);
    }

    /**
     * Arma el contenido del correo para notificación de turno cancelado por el centro.
     */
    public ContenidoCorreo armarTurnoCanceladoCentro(String nombre, DatosTurnoCorreo turno) {
        String asunto = "Tu turno fue cancelado";

        String textoPlano = "Hola " + nombre + ", el centro canceló tu turno:\n" +
                armarTablaTexto(turno) + "\n" +
                "Podés pedir uno nuevo desde la app.";

        String nombreEscaped = HtmlUtils.htmlEscape(nombre);
        String html = "<p>Hola " + nombreEscaped + ", el centro canceló tu turno:</p>" +
                armarTablaHtml(turno) +
                "<p>Podés pedir uno nuevo desde la app.</p>";

        return new ContenidoCorreo(asunto, textoPlano, html);
    }

    private String armarTablaTexto(DatosTurnoCorreo turno) {
        if (turno == null) return "";
        return "Médico: " + turno.medico() + "\n" +
                "Especialidad: " + turno.especialidad() + "\n" +
                "Fecha: " + turno.fecha() + "\n" +
                "Hora: " + turno.hora();
    }

    private String armarTablaHtml(DatosTurnoCorreo turno) {
        if (turno == null) return "";
        String medico = HtmlUtils.htmlEscape(turno.medico() != null ? turno.medico() : "");
        String especialidad = HtmlUtils.htmlEscape(turno.especialidad() != null ? turno.especialidad() : "");
        String fecha = HtmlUtils.htmlEscape(turno.fecha() != null ? turno.fecha() : "");
        String hora = HtmlUtils.htmlEscape(turno.hora() != null ? turno.hora() : "");

        return "<table style=\"border-collapse: collapse; margin: 15px 0; font-family: sans-serif;\">" +
                "<tr><td style=\"padding: 6px 12px; font-weight: bold; border-bottom: 1px solid #ddd;\">Médico:</td><td style=\"padding: 6px 12px; border-bottom: 1px solid #ddd;\">" + medico + "</td></tr>" +
                "<tr><td style=\"padding: 6px 12px; font-weight: bold; border-bottom: 1px solid #ddd;\">Especialidad:</td><td style=\"padding: 6px 12px; border-bottom: 1px solid #ddd;\">" + especialidad + "</td></tr>" +
                "<tr><td style=\"padding: 6px 12px; font-weight: bold; border-bottom: 1px solid #ddd;\">Fecha:</td><td style=\"padding: 6px 12px; border-bottom: 1px solid #ddd;\">" + fecha + "</td></tr>" +
                "<tr><td style=\"padding: 6px 12px; font-weight: bold;\">Hora:</td><td style=\"padding: 6px 12px;\">" + hora + "</td></tr>" +
                "</table>";
    }
}
