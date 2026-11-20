package com.mediturnos.service.correo;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/**
 * Prueba de integración del contexto Spring para verificar que con proveedor=demostracion
 * se inyecta la implementación ServicioCorreoDemostracion.
 */
@SpringBootTest
@TestPropertySource(properties = "mediturnos.correo.proveedor=demostracion")
class ServicioCorreoProveedorTest {

    @Autowired
    private ServicioCorreo servicioCorreo;

    @Test
    void testProveedorDemostracionActivo() {
        assertNotNull(servicioCorreo);
        assertInstanceOf(ServicioCorreoDemostracion.class, servicioCorreo);
    }
}
