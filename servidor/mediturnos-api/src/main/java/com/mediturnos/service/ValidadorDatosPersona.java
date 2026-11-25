package com.mediturnos.service;

import com.mediturnos.exception.ExcepcionApi;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import java.util.regex.Pattern;

/**
 * Validador compartido para datos de personas (usuarios y pacientes).
 */
@Component
public class ValidadorDatosPersona {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern DNI_PATTERN = Pattern.compile("^[1-9]\\d{6,7}$");

    public void validarNombre(String nombre) {
        if (nombre == null || nombre.trim().length() < 2 || nombre.trim().length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre es obligatorio y debe tener entre 2 y 100 caracteres", "nombre");
        }
    }

    public void validarApellido(String apellido) {
        if (apellido == null || apellido.trim().length() < 2 || apellido.trim().length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El apellido es obligatorio y debe tener entre 2 y 100 caracteres", "apellido");
        }
    }

    public void validarEmail(String email) {
        if (email == null || email.length() > 150) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El email es obligatorio y no puede superar los 150 caracteres", "email");
        }
        String emailNorm = email.trim().toLowerCase();
        if (!EMAIL_PATTERN.matcher(emailNorm).matches()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Formato de email inválido", "email");
        }
    }

    public void validarDni(String dni) {
        if (dni == null || !DNI_PATTERN.matcher(dni.trim()).matches()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El DNI debe tener 7 u 8 dígitos y no puede empezar con 0.", "dni");
        }
    }

    public void validarTelefono(String telefono) {
        if (telefono == null || telefono.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El teléfono debe tener entre 8 y 15 dígitos", "telefono");
        }
        String tel = telefono.trim();
        if (!tel.matches("^\\+?[0-9\\s\\-()]{8,30}$")) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El teléfono debe tener entre 8 y 15 dígitos", "telefono");
        }
        long digitos = tel.chars().filter(Character::isDigit).count();
        if (digitos < 8 || digitos > 15) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El teléfono debe tener entre 8 y 15 dígitos", "telefono");
        }
    }
}
