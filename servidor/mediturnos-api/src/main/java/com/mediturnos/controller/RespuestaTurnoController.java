package com.mediturnos.controller;

import com.mediturnos.model.Turno;
import com.mediturnos.repository.TurnoRepository;
import com.mediturnos.service.TurnoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.HtmlUtils;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Optional;

/**
 * Controller de Spring MVC que maneja la respuesta a turnos desde los enlaces de correo electrónico.
 * TODO: Cuando se agregue JWT, la ruta /respuesta-turno debe quedar excluida de la autenticación porque se protege con el token del turno.
 */
@Controller
@RequestMapping("/respuesta-turno")
public class RespuestaTurnoController {

    private static final ZoneId ZONA_BUENOS_AIRES = ZoneId.of("America/Argentina/Buenos_Aires");
    private static final DateTimeFormatter FMT_HORA = DateTimeFormatter.ofPattern("HH:mm");

    @Autowired
    private TurnoRepository turnoRepository;

    @Autowired
    private TurnoService turnoService;

    /**
     * Muestra la página de confirmación previa para responder al turno sin modificar la base de datos.
     */
    @GetMapping(produces = "text/html;charset=UTF-8")
    public ResponseEntity<String> mostrarFormulario(
            @RequestParam(required = false) String token,
            @RequestParam(required = false) Boolean asistira) {

        if (token == null || token.isBlank()) {
            return responderError("Este enlace no es válido.", HttpStatus.NOT_FOUND);
        }

        Optional<Turno> turnoOpt = turnoRepository.findByTokenRespuesta(token.trim());
        if (turnoOpt.isEmpty()) {
            return responderError("Este enlace no es válido.", HttpStatus.NOT_FOUND);
        }

        Turno turno = turnoOpt.get();
        ResponseEntity<String> errorEstado = verificarEstadoYVencimiento(turno);
        if (errorEstado != null) {
            return errorEstado;
        }

        boolean vaAAsistir = Boolean.TRUE.equals(asistira);
        String titulo = vaAAsistir ? "¿Confirmás que vas a asistir?" : "¿Seguro que no podés ir?";
        String subtitulo = vaAAsistir ? "Por favor confirma tu presencia para informar a la clínica." : "Tu turno se va a cancelar y el horario queda libre.";

        String botonTexto = vaAAsistir ? "Sí, confirmo" : "Sí, cancelar mi turno";
        String botonColor = vaAAsistir ? "#198754" : "#dc3545";

        String resumen = armarResumenTurnoHtml(turno);

        String formHtml = """
                <form method="post" action="/respuesta-turno" style="margin-top: 20px;">
                    <input type="hidden" name="token" value="%s" />
                    <input type="hidden" name="asistira" value="%s" />
                    <button type="submit" style="background-color: %s; color: white; border: none; padding: 12px 24px; font-size: 16px; font-weight: bold; border-radius: 8px; cursor: pointer; width: 100%%;">
                        %s
                    </button>
                </form>
                """.formatted(HtmlUtils.htmlEscape(token.trim()), vaAAsistir, botonColor, botonTexto);

        return responderPagina(titulo, subtitulo, resumen + formHtml, HttpStatus.OK);
    }

    /**
     * Procesa la respuesta de asistencia enviada por el formulario del correo.
     */
    @PostMapping(consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE, produces = "text/html;charset=UTF-8")
    public ResponseEntity<String> procesarRespuesta(
            @RequestParam(required = false) String token,
            @RequestParam(required = false) Boolean asistira) {

        if (token == null || token.isBlank()) {
            return responderError("Este enlace no es válido.", HttpStatus.NOT_FOUND);
        }

        Optional<Turno> turnoOpt = turnoRepository.findByTokenRespuesta(token.trim());
        if (turnoOpt.isEmpty()) {
            return responderError("Este enlace no es válido.", HttpStatus.NOT_FOUND);
        }

        Turno turno = turnoOpt.get();
        ResponseEntity<String> errorEstado = verificarEstadoYVencimiento(turno);
        if (errorEstado != null) {
            return errorEstado;
        }

        boolean vaAAsistir = Boolean.TRUE.equals(asistira);
        turnoService.responderAsistencia(turno.getId(), vaAAsistir);

        String titulo = vaAAsistir ? "¡Gracias!" : "Turno cancelado";
        String mensaje = vaAAsistir
                ? "¡Gracias! Avisamos al centro que vas a asistir."
                : "Listo, cancelamos tu turno. Podés pedir otro desde la app.";

        return responderPagina(titulo, mensaje, "", HttpStatus.OK);
    }

    private ResponseEntity<String> verificarEstadoYVencimiento(Turno turno) {
        if ("ASISTIRA".equals(turno.getRespuestaPaciente())) {
            return responderPagina("Información", "Ya nos avisaste que vas a asistir.", "", HttpStatus.OK);
        }
        if ("NO_ASISTIRA".equals(turno.getRespuestaPaciente()) || "CANCELADO".equals(turno.getEstado())) {
            return responderPagina("Información", "Este turno ya está cancelado.", "", HttpStatus.OK);
        }
        if ("ATENDIDO".equals(turno.getEstado())) {
            return responderError("Este turno ya no se puede responder.", HttpStatus.GONE);
        }

        LocalDateTime ahora = LocalDateTime.now(ZONA_BUENOS_AIRES);
        if (turno.getFecha() != null && turno.getHora() != null) {
            LocalDateTime inicio = LocalDateTime.of(turno.getFecha(), turno.getHora());
            if (inicio.isBefore(ahora)) {
                return responderError("Este turno ya no se puede responder.", HttpStatus.GONE);
            }
        }

        return null;
    }

    private ResponseEntity<String> responderError(String mensaje, HttpStatus status) {
        return responderPagina("Atención", mensaje, "", status);
    }

    private ResponseEntity<String> responderPagina(String titulo, String mensaje, String contenidoExtra, HttpStatus status) {
        String html = """
                <!DOCTYPE html>
                <html lang="es">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>%s - MediTurnos</title>
                    <style>
                        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background-color: #f8f9fa; color: #212529; margin: 0; padding: 20px; display: flex; justify-content: center; align-items: center; min-height: 90vh; }
                        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); max-width: 480px; width: 100%%; text-align: center; border: 1px solid #e9ecef; }
                        .logo { font-size: 24px; font-weight: bold; color: #0d6efd; margin-bottom: 20px; }
                        h1 { font-size: 20px; margin-bottom: 12px; color: #1e293b; }
                        p { font-size: 15px; color: #64748b; line-height: 1.5; margin-bottom: 20px; }
                        table { width: 100%%; border-collapse: collapse; margin: 20px 0; text-align: left; font-size: 14px; }
                        td { padding: 8px 12px; border-bottom: 1px solid #edf2f7; }
                        td.label { font-weight: bold; color: #475569; width: 35%%; }
                    </style>
                </head>
                <body>
                    <div class="card">
                        <div class="logo">🏥 MediTurnos</div>
                        <h1>%s</h1>
                        %s
                        %s
                    </div>
                </body>
                </html>
                """.formatted(
                titulo,
                titulo,
                mensaje != null && !mensaje.isBlank() ? "<p>" + mensaje + "</p>" : "",
                contenidoExtra != null ? contenidoExtra : ""
        );

        return ResponseEntity.status(status).contentType(MediaType.parseMediaType("text/html;charset=UTF-8")).body(html);
    }

    private String armarResumenTurnoHtml(Turno turno) {
        String medico = HtmlUtils.htmlEscape(turno.getMedico() != null ? (turno.getMedico().getNombre() + " " + turno.getMedico().getApellido()).trim() : "");
        String especialidad = HtmlUtils.htmlEscape(turno.getMedico() != null && turno.getMedico().getEspecialidad() != null ? turno.getMedico().getEspecialidad().getNombre() : "");
        String fecha = "";
        if (turno.getFecha() != null) {
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("EEEE dd/MM/yyyy", Locale.forLanguageTag("es"));
            fecha = HtmlUtils.htmlEscape(turno.getFecha().format(fmt));
        }
        String hora = HtmlUtils.htmlEscape(turno.getHora() != null ? turno.getHora().format(FMT_HORA) : "");

        return """
                <table>
                    <tr><td class="label">Médico:</td><td>%s</td></tr>
                    <tr><td class="label">Especialidad:</td><td>%s</td></tr>
                    <tr><td class="label">Fecha:</td><td>%s</td></tr>
                    <tr><td class="label">Hora:</td><td>%s</td></tr>
                </table>
                """.formatted(medico, especialidad, fecha, hora);
    }
}
