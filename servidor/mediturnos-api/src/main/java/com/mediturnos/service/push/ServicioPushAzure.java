package com.mediturnos.service.push;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Implementación real de envío de notificaciones push utilizando la API REST de Azure Notification Hubs.
 */
@Service
@ConditionalOnProperty(name = "mediturnos.push.proveedor", havingValue = "azure")
public class ServicioPushAzure implements ServicioPush {

    private static final Logger log = LoggerFactory.getLogger(ServicioPushAzure.class);

    @Value("${mediturnos.push.azure.cadena-conexion:}")
    private String cadenaConexion;

    @Value("${mediturnos.push.azure.nombre-hub:mediturnos-hub}")
    private String nombreHub;

    private String endpointHost;
    private String claveNombre;
    private String claveSecreta;
    private String targetUri;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostConstruct
    public void init() {
        if (cadenaConexion == null || cadenaConexion.isBlank()) {
            throw new IllegalStateException("Falta configurar la propiedad mediturnos.push.azure.cadena-conexion para el proveedor 'azure'.");
        }

        Map<String, String> parsed = CalculadorTokenSas.parsearCadenaConexion(cadenaConexion);
        String endpointRaw = parsed.get("Endpoint");
        this.claveNombre = parsed.get("SharedAccessKeyName");
        this.claveSecreta = parsed.get("SharedAccessKey");

        if (endpointRaw == null || claveNombre == null || claveSecreta == null) {
            throw new IllegalStateException("La cadena de conexión de Azure Push es inválida. Debe contener Endpoint, SharedAccessKeyName y SharedAccessKey.");
        }

        this.endpointHost = endpointRaw.replace("sb://", "").replace("https://", "").replace("/", "").trim();
        this.targetUri = "https://" + endpointHost + "/" + nombreHub;
    }

    @Override
    @Async
    public void registrarDispositivo(String installationId, String tokenFcm, Long usuarioId, String rol) {
        try {
            String tokenSas = obtenerTokenSas();
            String urlStr = targetUri + "/installations/" + installationId + "?api-version=2015-01";

            Map<String, Object> bodyMap = new HashMap<>();
            bodyMap.put("installationId", installationId);
            bodyMap.put("platform", "fcmv1");
            bodyMap.put("pushChannel", tokenFcm);

            List<String> tags = new ArrayList<>();
            tags.add("usuario:" + usuarioId);
            if (rol != null && !rol.isBlank()) {
                tags.add("rol:" + rol.toUpperCase());
            }
            bodyMap.put("tags", tags);

            String bodyJson = objectMapper.writeValueAsString(bodyMap);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(urlStr))
                    .header("Authorization", tokenSas)
                    .header("Content-Type", "application/json;charset=utf-8")
                    .PUT(HttpRequest.BodyPublishers.ofString(bodyJson))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                log.info("Dispositivo registrado exitosamente en Azure Notification Hub. InstallationId: {}, UsuarioId: {}", installationId, usuarioId);
            } else {
                log.warn("Error HTTP {} al registrar dispositivo en Azure Notification Hub: {}", response.statusCode(), response.body());
            }
        } catch (Exception e) {
            log.warn("Error al registrar dispositivo en Azure Notification Hub: {}", e.getMessage());
        }
    }

    @Override
    @Async
    public void eliminarDispositivo(String installationId, Long usuarioId) {
        try {
            String tokenSas = obtenerTokenSas();
            String urlStr = targetUri + "/installations/" + installationId + "?api-version=2015-01";

            HttpRequest getRequest = HttpRequest.newBuilder()
                    .uri(URI.create(urlStr))
                    .header("Authorization", tokenSas)
                    .GET()
                    .build();

            HttpResponse<String> getResponse = httpClient.send(getRequest, HttpResponse.BodyHandlers.ofString());

            if (getResponse.statusCode() == 200) {
                JsonNode root = objectMapper.readTree(getResponse.body());
                JsonNode tagsNode = root.get("tags");
                boolean esDeUsuario = false;
                if (tagsNode != null && tagsNode.isArray()) {
                    String tagBuscado = "usuario:" + usuarioId;
                    for (JsonNode tag : tagsNode) {
                        if (tagBuscado.equals(tag.asText())) {
                            esDeUsuario = true;
                            break;
                        }
                    }
                }

                if (!esDeUsuario) {
                    log.warn("El dispositivo {} no pertenece al usuario {}. No se elimina.", installationId, usuarioId);
                    return;
                }

                HttpRequest deleteRequest = HttpRequest.newBuilder()
                        .uri(URI.create(urlStr))
                        .header("Authorization", tokenSas)
                        .DELETE()
                        .build();

                HttpResponse<String> deleteResponse = httpClient.send(deleteRequest, HttpResponse.BodyHandlers.ofString());
                if (deleteResponse.statusCode() >= 200 && deleteResponse.statusCode() < 300) {
                    log.info("Dispositivo {} eliminado exitosamente de Azure Notification Hub.", installationId);
                } else {
                    log.warn("Error HTTP {} al eliminar dispositivo de Azure Notification Hub: {}", deleteResponse.statusCode(), deleteResponse.body());
                }
            } else {
                log.info("No se encontró la instalación {} en Azure Notification Hub al intentar eliminar (HTTP {}).", installationId, getResponse.statusCode());
            }
        } catch (Exception e) {
            log.warn("Error al eliminar dispositivo de Azure Notification Hub: {}", e.getMessage());
        }
    }

    @Override
    @Async
    public void enviarAUsuario(Long usuarioId, String titulo, String cuerpo, Map<String, String> datos) {
        try {
            String tokenSas = obtenerTokenSas();
            String urlStr = targetUri + "/messages/?api-version=2015-01";

            Map<String, Object> notificationMap = new HashMap<>();
            notificationMap.put("title", titulo);
            notificationMap.put("body", cuerpo);

            Map<String, Object> androidMap = new HashMap<>();
            androidMap.put("priority", "high");

            Map<String, Object> messageContent = new HashMap<>();
            messageContent.put("notification", notificationMap);
            messageContent.put("data", datos != null ? datos : new HashMap<String, String>());
            messageContent.put("android", androidMap);

            Map<String, Object> payloadMap = new HashMap<>();
            payloadMap.put("message", messageContent);

            String bodyJson = objectMapper.writeValueAsString(payloadMap);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(urlStr))
                    .header("Authorization", tokenSas)
                    .header("Content-Type", "application/json;charset=utf-8")
                    .header("ServiceBusNotification-Format", "fcmv1")
                    .header("ServiceBusNotification-Tags", "usuario:" + usuarioId)
                    .POST(HttpRequest.BodyPublishers.ofString(bodyJson))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                log.info("Notificación push enviada exitosamente en Azure Notification Hub a usuario: {}", usuarioId);
            } else {
                log.warn("Error HTTP {} al enviar notificación push en Azure Notification Hub: {}", response.statusCode(), response.body());
            }
        } catch (Exception e) {
            log.warn("Error al enviar notificación push en Azure Notification Hub: {}", e.getMessage());
        }
    }

    private String obtenerTokenSas() {
        long expiracion = (System.currentTimeMillis() / 1000L) + 3600L;
        return CalculadorTokenSas.generarTokenSas(targetUri, claveNombre, claveSecreta, expiracion);
    }
}
