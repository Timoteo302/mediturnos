package com.mediturnos.service.push;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Pruebas unitarias para el parser de cadena de conexión y el generador de tokens SAS de Azure Notification Hubs.
 */
class CalculadorTokenSasTest {

    @Test
    void testParsearCadenaConexionExitoso() {
        String cadena = "Endpoint=sb-demo://mediturnos-ns.servicebus.windows.net/;SharedAccessKeyName=KeyPrueba;SharedAccessKey=Secreto123=";
        Map<String, String> resultado = CalculadorTokenSas.parsearCadenaConexion(cadena);

        assertEquals("sb-demo://mediturnos-ns.servicebus.windows.net/", resultado.get("Endpoint"));
        assertEquals("KeyPrueba", resultado.get("SharedAccessKeyName"));
        assertEquals("Secreto123=", resultado.get("SharedAccessKey"));
    }

    @Test
    void testParsearCadenaConexionVaciaORetornaMapaVacio() {
        assertTrue(CalculadorTokenSas.parsearCadenaConexion("").isEmpty());
        assertTrue(CalculadorTokenSas.parsearCadenaConexion(null).isEmpty());
    }

    @Test
    void testGenerarTokenSasFormatoCorrecto() {
        String targetUri = "https://mediturnos-ns.servicebus.windows.net/mediturnos-hub";
        String nombreClave = "DefaultFullSharedAccessSignature";
        String claveSecreta = "miClaveSecretaPrueba123=";
        long expiracion = 1800000000L;

        String token = CalculadorTokenSas.generarTokenSas(targetUri, nombreClave, claveSecreta, expiracion);

        assertNotNull(token);
        assertTrue(token.startsWith("SharedAccessSignature sr="));
        assertTrue(token.contains("&sig="));
        assertTrue(token.contains("&se=1800000000"));
        assertTrue(token.contains("&skn=DefaultFullSharedAccessSignature"));
    }
}
