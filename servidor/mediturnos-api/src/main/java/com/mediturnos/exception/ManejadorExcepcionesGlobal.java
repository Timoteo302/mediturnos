package com.mediturnos.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

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

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> manejarGeneral(Exception ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("error", ex.getMessage() != null ? ex.getMessage() : "Error interno del servidor");
        body.put("codigo", "ERROR_INTERNO");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
