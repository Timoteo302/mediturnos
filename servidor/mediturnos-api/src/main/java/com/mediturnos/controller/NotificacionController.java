package com.mediturnos.controller;

import com.mediturnos.dto.NotificacionRespuesta;
import com.mediturnos.service.NotificacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Endpoints para consulta de notificaciones en la app.
 * TODO: Agregar autenticación vía JWT en la próxima etapa.
 */
@RestController
@CrossOrigin(origins = "*")
public class NotificacionController {

    @Autowired
    private NotificacionService notificacionService;

    /**
     * Devuelve las últimas 50 notificaciones del usuario.
     */
    @GetMapping("/notificaciones")
    public ResponseEntity<List<NotificacionRespuesta>> listar(@RequestParam Integer usuarioId) {
        List<NotificacionRespuesta> notificaciones = notificacionService.listar(usuarioId);
        return ResponseEntity.ok(notificaciones);
    }

    /**
     * Devuelve la cantidad de notificaciones no leídas de un usuario.
     */
    @GetMapping("/notificaciones/no-leidas")
    public ResponseEntity<Map<String, Long>> contarNoLeidas(@RequestParam Integer usuarioId) {
        long cantidad = notificacionService.contarNoLeidas(usuarioId);
        return ResponseEntity.ok(Map.of("cantidad", cantidad));
    }

    /**
     * Marca una notificación específica como leída.
     */
    @PatchMapping("/notificaciones/{id}/leida")
    public ResponseEntity<Void> marcarLeida(@PathVariable Integer id) {
        notificacionService.marcarLeida(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Marca todas las notificaciones de un usuario como leídas.
     */
    @PatchMapping("/notificaciones/leidas")
    public ResponseEntity<Void> marcarTodasLeidas(@RequestParam Integer usuarioId) {
        notificacionService.marcarTodasLeidas(usuarioId);
        return ResponseEntity.noContent().build();
    }
}
