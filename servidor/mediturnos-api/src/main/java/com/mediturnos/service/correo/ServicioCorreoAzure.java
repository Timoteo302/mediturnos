package com.mediturnos.service.correo;

import com.azure.communication.email.EmailClient;
import com.azure.communication.email.EmailClientBuilder;
import com.azure.communication.email.models.EmailMessage;
import com.azure.communication.email.models.EmailSendResult;
import com.azure.core.util.polling.SyncPoller;
import com.mediturnos.dto.DatosTurnoCorreo;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * Implementación real de envío de correos utilizando Azure Communication Services Email.
 */
@Service
@ConditionalOnProperty(name = "mediturnos.correo.proveedor", havingValue = "azure")
public class ServicioCorreoAzure implements ServicioCorreo {

    private static final Logger log = LoggerFactory.getLogger(ServicioCorreoAzure.class);

    @Value("${mediturnos.correo.azure.cadena-conexion:}")
    private String cadenaConexion;

    @Value("${mediturnos.correo.remitente:}")
    private String remitente;

    @Autowired
    private PlantillasCorreo plantillasCorreo;

    private EmailClient emailClient;

    @PostConstruct
    public void init() {
        if (cadenaConexion == null || cadenaConexion.isBlank() || remitente == null || remitente.isBlank()) {
            throw new IllegalStateException("Falta configurar MEDITURNOS_CORREO_AZURE_CADENACONEXION / MEDITURNOS_CORREO_REMITENTE");
        }
        this.emailClient = new EmailClientBuilder()
                .connectionString(cadenaConexion)
                .buildClient();
    }

    @Override
    @Async
    public void enviarCodigoActivacion(String email, String nombre, String codigo, String resumenTurno) {
        PlantillasCorreo.ContenidoCorreo contenido = plantillasCorreo.armarCorreoActivacion(nombre, codigo, resumenTurno);
        enviarCorreo(email, contenido.asunto(), contenido.textoPlano(), contenido.html());
    }

    @Override
    @Async
    public void enviarCodigoRecuperacion(String email, String nombre, String codigo) {
        PlantillasCorreo.ContenidoCorreo contenido = plantillasCorreo.armarCorreoRecuperacion(nombre, codigo);
        enviarCorreo(email, contenido.asunto(), contenido.textoPlano(), contenido.html());
    }

    @Override
    @Async
    public void enviarRecordatorioAsistencia(String email, String nombre, DatosTurnoCorreo turno, String urlSi, String urlNo) {
        PlantillasCorreo.ContenidoCorreo contenido = plantillasCorreo.armarRecordatorioAsistencia(nombre, turno, urlSi, urlNo);
        enviarCorreo(email, contenido.asunto(), contenido.textoPlano(), contenido.html());
    }

    @Override
    @Async
    public void enviarTurnoConfirmado(String email, String nombre, DatosTurnoCorreo turno) {
        PlantillasCorreo.ContenidoCorreo contenido = plantillasCorreo.armarTurnoConfirmado(nombre, turno);
        enviarCorreo(email, contenido.asunto(), contenido.textoPlano(), contenido.html());
    }

    @Override
    @Async
    public void enviarTurnoCanceladoCentro(String email, String nombre, DatosTurnoCorreo turno) {
        PlantillasCorreo.ContenidoCorreo contenido = plantillasCorreo.armarTurnoCanceladoCentro(nombre, turno);
        enviarCorreo(email, contenido.asunto(), contenido.textoPlano(), contenido.html());
    }

    private void enviarCorreo(String destinatario, String asunto, String textoPlano, String html) {
        try {
            EmailMessage message = new EmailMessage()
                    .setSenderAddress(remitente)
                    .setToRecipients(destinatario)
                    .setSubject(asunto)
                    .setBodyPlainText(textoPlano)
                    .setBodyHtml(html);

            SyncPoller<EmailSendResult, EmailSendResult> poller = emailClient.beginSend(message);
            poller.waitForCompletion();
            EmailSendResult result = poller.getFinalResult();

            log.info("Correo enviado exitosamente a {}. ID de operación: {}", destinatario, result.getId());
        } catch (Exception e) {
            log.error("Error al enviar correo a {}: {}", destinatario, e.getMessage());
        }
    }
}
