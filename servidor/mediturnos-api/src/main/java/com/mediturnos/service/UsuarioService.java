package com.mediturnos.service;

import com.mediturnos.dto.PacienteResumen;
import com.mediturnos.dto.UsuarioRespuesta;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern DNI_PATTERN = Pattern.compile("^\\d{7,8}$");

    @Transactional
    public UsuarioRespuesta registrarUsuario(Map<String, String> body) {
        if (body == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Faltan datos obligatorios");
        }

        String nombre = body.get("nombre");
        String apellido = body.get("apellido");
        String email = body.get("email");
        String contrasena = body.get("contrasena");
        String dni = body.get("dni");
        String telefono = body.get("telefono");

        // Validaciones
        if (nombre == null || nombre.trim().length() < 2 || nombre.trim().length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre es obligatorio y debe tener entre 2 y 100 caracteres", "nombre");
        }
        if (apellido == null || apellido.trim().length() < 2 || apellido.trim().length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El apellido es obligatorio y debe tener entre 2 y 100 caracteres", "apellido");
        }
        if (email == null || email.length() > 150) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El email es obligatorio y no puede superar los 150 caracteres", "email");
        }
        String emailNorm = email.trim().toLowerCase();
        if (!EMAIL_PATTERN.matcher(emailNorm).matches()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Formato de email inválido", "email");
        }
        if (contrasena == null || contrasena.length() < 8 || contrasena.length() > 72) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La contraseña debe tener entre 8 y 72 caracteres", "contrasena");
        }
        if (dni == null || !DNI_PATTERN.matcher(dni.trim()).matches()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El DNI es obligatorio y debe tener 7 u 8 dígitos", "dni");
        }
        if (telefono != null && !telefono.isBlank() && telefono.trim().length() > 30) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El teléfono no puede superar los 30 caracteres", "telefono");
        }

        // Duplicados
        if (usuarioRepository.existsByEmail(emailNorm)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "EMAIL_DUPLICADO", "El email ya está registrado", "email");
        }
        String dniTrim = dni.trim();
        if (pacienteRepository.existsByDni(dniTrim)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "DNI_DUPLICADO", "El DNI ya está registrado", "dni");
        }

        Usuario usuario = new Usuario();
        usuario.setNombre(nombre.trim());
        usuario.setApellido(apellido.trim());
        usuario.setEmail(emailNorm);
        usuario.setContrasena(passwordEncoder.encode(contrasena));
        usuario.setRol(Usuario.Rol.PACIENTE);
        usuario.setActivo(true);

        Usuario nuevoUsuario = usuarioRepository.save(usuario);

        Paciente paciente = new Paciente();
        paciente.setUsuario(nuevoUsuario);
        paciente.setDni(dniTrim);
        paciente.setTelefono(telefono != null && !telefono.isBlank() ? telefono.trim() : null);
        pacienteRepository.save(paciente);

        return mapToRespuesta(nuevoUsuario, paciente);
    }

    public UsuarioRespuesta login(String email, String contrasena) {
        if (email == null || email.isBlank() || contrasena == null || contrasena.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Faltan email o contraseña", "email");
        }

        String emailNorm = email.trim().toLowerCase();
        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(emailNorm);

        if (usuarioOpt.isEmpty() || !passwordEncoder.matches(contrasena, usuarioOpt.get().getContrasena())) {
            throw new ExcepcionApi(HttpStatus.UNAUTHORIZED, "CREDENCIALES_INVALIDAS", "Credenciales inválidas");
        }

        Usuario usuario = usuarioOpt.get();
        if (Boolean.FALSE.equals(usuario.getActivo())) {
            throw new ExcepcionApi(HttpStatus.FORBIDDEN, "CUENTA_INACTIVA", "Cuenta inactiva");
        }

        Paciente paciente = null;
        if (usuario.getRol() == Usuario.Rol.PACIENTE) {
            paciente = pacienteRepository.findByUsuarioId(usuario.getId()).orElse(null);
        }

        return mapToRespuesta(usuario, paciente);
    }

    private UsuarioRespuesta mapToRespuesta(Usuario usuario, Paciente paciente) {
        PacienteResumen pacienteResumen = null;
        if (usuario.getRol() == Usuario.Rol.PACIENTE) {
            if (paciente == null) {
                paciente = pacienteRepository.findByUsuarioId(usuario.getId()).orElse(null);
            }
            if (paciente != null) {
                pacienteResumen = new PacienteResumen(paciente.getId(), paciente.getDni(), paciente.getTelefono());
            }
        }

        return new UsuarioRespuesta(
                usuario.getId(),
                usuario.getNombre(),
                usuario.getApellido(),
                usuario.getEmail(),
                usuario.getRol().name(),
                usuario.getActivo(),
                usuario.getFechaCreacion(),
                pacienteResumen
        );
    }
}
