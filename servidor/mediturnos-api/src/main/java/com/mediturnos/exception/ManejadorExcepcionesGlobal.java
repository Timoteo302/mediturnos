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

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> manejarGeneral(Exception ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("error", ex.getMessage() != null ? ex.getMessage() : "Error interno del servidor");
        body.put("codigo", "ERROR_INTERNO");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
