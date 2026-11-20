package com.mediturnos.controller;

import com.mediturnos.service.ReservaInvitadoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Endpoints para reservas de turnos por usuarios invitados.
 */
@RestController
@RequestMapping("/reservas")
@CrossOrigin(origins = "*")
public class ReservaInvitadoController {

    @Autowired
    private ReservaInvitadoService reservaInvitadoService;

    @PostMapping("/invitado")
    public ResponseEntity<Map<String, Object>> reservar(@RequestBody Map<String, String> body) {
        Map<String, Object> respuesta = reservaInvitadoService.reservar(body);
        return ResponseEntity.status(HttpStatus.CREATED).body(respuesta);
    }
}
