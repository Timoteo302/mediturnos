package com.mediturnos.service.correo;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Pruebas unitarias para verificar la generación de plantillas de correo y escape de HTML.
 */
class PlantillasCorreoTest {

    private final PlantillasCorreo plantillasCorreo = new PlantillasCorreo();

    @Test
    void testCorreoActivacionContenidoYEscapeHtml() {
        String nombre = "Carlos <b>Perez</b>";
        String codigo = "123456";
        String resumenTurno = "Tu turno con Dr. Gomez el 25/12 a las 10:00 quedó reservado.";

        PlantillasCorreo.ContenidoCorreo resultado = plantillasCorreo.armarCorreoActivacion(nombre, codigo, resumenTurno);

        assertEquals("Activá tu cuenta de MediTurnos", resultado.asunto());

        assertTrue(resultado.textoPlano().contains("Carlos <b>Perez</b>"));
        assertTrue(resultado.textoPlano().contains("123456"));
        assertTrue(resultado.textoPlano().contains(resumenTurno));

        assertFalse(resultado.html().contains("<b>Perez</b>"));
        assertTrue(resultado.html().contains("Carlos &lt;b&gt;Perez&lt;/b&gt;"));
        assertTrue(resultado.html().contains("123456"));
    }

    @Test
    void testCorreoRecuperacionContenidoYEscapeHtml() {
        String nombre = "Maria <script>alert(1)</script>";
        String codigo = "654321";

        PlantillasCorreo.ContenidoCorreo resultado = plantillasCorreo.armarCorreoRecuperacion(nombre, codigo);

        assertEquals("Código para cambiar tu contraseña de MediTurnos", resultado.asunto());

        assertTrue(resultado.textoPlano().contains("Maria <script>alert(1)</script>"));
        assertTrue(resultado.textoPlano().contains("654321"));

        assertFalse(resultado.html().contains("<script>"));
        assertTrue(resultado.html().contains("Maria &lt;script&gt;alert(1)&lt;/script&gt;"));
        assertTrue(resultado.html().contains("654321"));
    }
}
