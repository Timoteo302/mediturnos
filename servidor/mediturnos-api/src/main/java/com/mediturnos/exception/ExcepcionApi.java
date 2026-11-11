package com.mediturnos.exception;

import org.springframework.http.HttpStatus;

import java.util.Map;

public class ExcepcionApi extends RuntimeException {
    private final HttpStatus status;
    private final String codigo;
    private final String mensaje;
    private final String campo;
    private final Map<String, Object> extras;

    public ExcepcionApi(HttpStatus status, String codigo, String mensaje, String campo, Map<String, Object> extras) {
        super(mensaje);
        this.status = status;
        this.codigo = codigo;
        this.mensaje = mensaje;
        this.campo = campo;
        this.extras = extras;
    }

    public ExcepcionApi(HttpStatus status, String codigo, String mensaje) {
        this(status, codigo, mensaje, null, null);
    }

    public ExcepcionApi(HttpStatus status, String codigo, String mensaje, String campo) {
        this(status, codigo, mensaje, campo, null);
    }

    public ExcepcionApi(HttpStatus status, String codigo, String mensaje, Map<String, Object> extras) {
        this(status, codigo, mensaje, null, extras);
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getCodigo() {
        return codigo;
    }

    public String getMensaje() {
        return mensaje;
    }

    public String getCampo() {
        return campo;
    }

    public Map<String, Object> getExtras() {
        return extras;
    }
}
