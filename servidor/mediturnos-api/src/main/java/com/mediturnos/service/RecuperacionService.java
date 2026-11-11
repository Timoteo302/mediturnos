package com.mediturnos.service;

import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class RecuperacionService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final SecureRandom secureRandom = new SecureRandom();
    private final ConcurrentHashMap<String, SolicitudRecuperacion> solicitudes = new ConcurrentHashMap<>();

    public static class SolicitudRecuperacion {
        public String idRecuperacion;
        public Integer usuarioId;
        public String codigo;
        public LocalDateTime vencimiento;
        public int intentos;

        public SolicitudRecuperacion(String idRecuperacion, Integer usuarioId, String codigo, LocalDateTime vencimiento, int intentos) {
            this.idRecuperacion = idRecuperacion;
            this.usuarioId = usuarioId;
            this.codigo = codigo;
            this.vencimiento = vencimiento;
            this.intentos = intentos;
        }
    }

    private void limpiarVencidas() {
        LocalDateTime ahora = LocalDateTime.now();
        solicitudes.values().removeIf(s -> ahora.isAfter(s.vencimiento));
    }

    public Map<String, Object> solicitar(Map<String, String> body, boolean modoDemostracion) {
        if (body == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Faltan datos obligatorios", "email");
        }
        String email = body.get("email");
        String dni = body.get("dni");

        if ((email == null || email.isBlank()) && (dni == null || dni.isBlank())) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Debe proporcionar email o dni", "email");
        }

        limpiarVencidas();

        Optional<Usuario> usuarioOpt = Optional.empty();

        if (email != null && !email.isBlank()) {
            String emailNorm = email.trim().toLowerCase();
            usuarioOpt = usuarioRepository.findByEmail(emailNorm);
        } else if (dni != null && !dni.isBlank()) {
            String dniTrim = dni.trim();
            Optional<Paciente> pacienteOpt = pacienteRepository.findByDni(dniTrim);
            if (pacienteOpt.isPresent()) {
                usuarioOpt = Optional.of(pacienteOpt.get().getUsuario());
            }
        }

        if (usuarioOpt.isEmpty()) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "CUENTA_NO_ENCONTRADA", "Cuenta no encontrada");
        }

        Usuario usuario = usuarioOpt.get();
        if (Boolean.FALSE.equals(usuario.getActivo())) {
            throw new ExcepcionApi(HttpStatus.FORBIDDEN, "CUENTA_INACTIVA", "Cuenta inactiva");
        }

        String codigo = String.format("%06d", secureRandom.nextInt(1000000));
        String idRecuperacion = UUID.randomUUID().toString();
        LocalDateTime vencimiento = LocalDateTime.now().plusMinutes(10);

        SolicitudRecuperacion solicitud = new SolicitudRecuperacion(idRecuperacion, usuario.getId(), codigo, vencimiento, 0);
        solicitudes.put(idRecuperacion, solicitud);

        Map<String, Object> resultado = new HashMap<>();
        resultado.put("idRecuperacion", idRecuperacion);
        resultado.put("venceEnMinutos", 10);
        if (modoDemostracion) {
            resultado.put("codigoDemostracion", codigo);
        }

        return resultado;
    }

    public void restablecer(Map<String, String> body) {
        if (body == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Faltan datos obligatorios");
        }

        String idRecuperacion = body.get("idRecuperacion");
        String codigo = body.get("codigo");
        String nuevaContrasena = body.get("nuevaContrasena");

        if (nuevaContrasena == null || nuevaContrasena.length() < 8) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La nueva contraseña debe tener al menos 8 caracteres", "nuevaContrasena");
        }

        if (idRecuperacion == null || codigo == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Faltan datos obligatorios");
        }

        limpiarVencidas();

        SolicitudRecuperacion solicitud = solicitudes.get(idRecuperacion);
        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "SOLICITUD_NO_ENCONTRADA", "Solicitud no encontrada o ya usada");
        }

        LocalDateTime ahora = LocalDateTime.now();
        if (ahora.isAfter(solicitud.vencimiento)) {
            solicitudes.remove(idRecuperacion);
            throw new ExcepcionApi(HttpStatus.GONE, "CODIGO_VENCIDO", "Código vencido");
        }

        if (solicitud.intentos >= 5) {
            solicitudes.remove(idRecuperacion);
            throw new ExcepcionApi(HttpStatus.TOO_MANY_REQUESTS, "DEMASIADOS_INTENTOS", "Demasiados intentos fallidos");
        }

        if (!solicitud.codigo.equals(codigo)) {
            solicitud.intentos++;
            if (solicitud.intentos >= 5) {
                solicitudes.remove(idRecuperacion);
                throw new ExcepcionApi(HttpStatus.TOO_MANY_REQUESTS, "DEMASIADOS_INTENTOS", "Demasiados intentos fallidos");
            }
            Map<String, Object> extras = Map.of("intentosRestantes", 5 - solicitud.intentos);
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "CODIGO_INVALIDO", "Código incorrecto", null, extras);
        }

        // Éxito: actualizar contraseña y borrar solicitud
        Usuario usuario = usuarioRepository.findById(solicitud.usuarioId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "CUENTA_NO_ENCONTRADA", "Cuenta no encontrada"));

        usuario.setContrasena(passwordEncoder.encode(nuevaContrasena));
        usuarioRepository.save(usuario);

        solicitudes.remove(idRecuperacion);
    }
}
