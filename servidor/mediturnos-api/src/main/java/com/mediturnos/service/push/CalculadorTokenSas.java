package com.mediturnos.service.push;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * Utilidad para parsear cadenas de conexión de Azure Notification Hubs y calcular tokens SAS.
 */
public class CalculadorTokenSas {

    /**
     * Parsea la cadena de conexión de Azure y extrae Endpoint, SharedAccessKeyName y SharedAccessKey.
     */
    public static Map<String, String> parsearCadenaConexion(String cadenaConexion) {
        Map<String, String> mapa = new HashMap<>();
        if (cadenaConexion == null || cadenaConexion.isBlank()) {
            return mapa;
        }
        String[] partes = cadenaConexion.split(";");
        for (String parte : partes) {
            int idx = parte.indexOf('=');
            if (idx > 0) {
                String clave = parte.substring(0, idx).trim();
                String valor = parte.substring(idx + 1).trim();
                mapa.put(clave, valor);
            }
        }
        return mapa;
    }

    /**
     * Genera un token SharedAccessSignature (SAS) válido con firma HMAC-SHA256.
     */
    public static String generarTokenSas(String targetUri, String nombreClave, String claveSecreta, long expiracionSegundos) {
        try {
            String uriCodificada = URLEncoder.encode(targetUri, StandardCharsets.UTF_8).toLowerCase();
            String stringToSign = uriCodificada + "\n" + expiracionSegundos;

            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(claveSecreta.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKey);

            byte[] hmacRaw = mac.doFinal(stringToSign.getBytes(StandardCharsets.UTF_8));
            String firmaCodificada = URLEncoder.encode(Base64.getEncoder().encodeToString(hmacRaw), StandardCharsets.UTF_8);

            return "SharedAccessSignature sr=" + uriCodificada + "&sig=" + firmaCodificada + "&se=" + expiracionSegundos + "&skn=" + nombreClave;
        } catch (Exception e) {
            throw new RuntimeException("Error al generar el token SAS para Azure Notification Hubs", e);
        }
    }
}
