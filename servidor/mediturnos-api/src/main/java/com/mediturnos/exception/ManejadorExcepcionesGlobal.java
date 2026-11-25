package com.mediturnos.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.HashMap;
import java.util.Map;

// Manejador global de excepciones para traducir errores no capturados en respuestas JSON con formato estándar.
@RestControllerAdvice
public class ManejadorExcepcionesGlobal {

    @ExceptionHandler(ExcepcionApi.class)
    public ResponseEntity<Map<String, Object>> manejarExcepcionApi(ExcepcionApi ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("error", ex.getMensaje());
        body.put("codigo", ex.getCodigo());
        if (ex.getCampo() != null) {
            body.put("campo", ex.getCampo());
        }
        if (ex.getExtras() != null) {
            body.putAll(ex.getExtras());
        }
        return ResponseEntity.status(ex.getStatus()).body(body);
    }

    // Captura rutas inexistentes (404) para evitar que caigan en el handler genérico de 500.
    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<Map<String, Object>> manejarRutaNoEncontrada(NoResourceFoundException ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("error", "La ruta solicitada no existe");
        body.put("codigo", "RUTA_NO_ENCONTRADA");
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(body);
    }

    // Traduce violaciones de integridad de la BD que no sean duplicados a HTTP 400 DATOS_INVALIDOS
    @ExceptionHandler(org.springframework.dao.DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, Object>> manejarIntegridadDatos(org.springframework.dao.DataIntegrityViolationException ex) {
        String msg = ex.getMessage() != null ? ex.getMessage().toLowerCase() : "";
        Throwable rootCause = ex.getRootCause();
        if (rootCause != null && rootCause.getMessage() != null) {
            msg += " " + rootCause.getMessage().toLowerCase();
        }

        if (msg.contains("duplicate") || msg.contains("unique")) {
            Map<String, Object> body = new HashMap<>();
            body.put("error", "Conflicto de duplicación de datos.");
            body.put("codigo", "DATO_DUPLICADO");
            return ResponseEntity.status(HttpStatus.CONFLICT).body(body);
        }

        Map<String, Object> body = new HashMap<>();
        body.put("error", "Algún dato no es válido.");
        body.put("codigo", "DATOS_INVALIDOS");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> manejarGeneral(Exception ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("error", ex.getMessage() != null ? ex.getMessage() : "Error interno del servidor");
        body.put("codigo", "ERROR_INTERNO");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
