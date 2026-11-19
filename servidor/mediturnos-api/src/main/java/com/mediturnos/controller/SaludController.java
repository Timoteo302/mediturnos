package com.mediturnos.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

// Controller simple para verificar el estado de salud de la API (healthcheck).
// No realiza consultas a la base de datos para responder de forma inmediata.
@RestController
@CrossOrigin(origins = "*")
public class SaludController {

    // Endpoint GET /salud para comprobar la disponibilidad del servidor backend.
    @GetMapping("/salud")
    public ResponseEntity<Map<String, String>> obtenerSalud() {
        return ResponseEntity.ok(Collections.singletonMap("estado", "ok"));
    }
}
