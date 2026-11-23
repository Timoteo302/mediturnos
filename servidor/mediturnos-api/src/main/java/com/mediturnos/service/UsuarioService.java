package com.mediturnos.service;

import com.mediturnos.dto.PacienteResumen;
import com.mediturnos.dto.UsuarioRespuesta;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.UsuarioRepository;
import com.mediturnos.security.ProveedorUsuarioActual;
import com.mediturnos.security.UsuarioActual;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    @Autowired
    private ServicioToken servicioToken;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Transactional
    public UsuarioRespuesta registrarUsuario(Map<String, String> body) {
        if (body == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Solicitud nula");
        }

        String nombre = body.get("nombre");
        String apellido = body.get("apellido");
        String email = body.get("email");
        String contrasena = body.get("contrasena");
        String dni = body.get("dni");
        String telefono = body.get("telefono");

        if (nombre == null || nombre.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre es obligatorio", "nombre");
        }
        if (apellido == null || apellido.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El apellido es obligatorio", "apellido");
        }
        if (email == null || email.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El email es obligatorio", "email");
        }
        if (contrasena == null || contrasena.length() < 8 || contrasena.length() > 72) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La contraseña debe tener entre 8 y 72 caracteres", "contrasena");
        }
        if (dni == null || dni.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El DNI es obligatorio", "dni");
        }
        if (telefono == null || telefono.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El teléfono es obligatorio", "telefono");
        }
        validarTelefono(telefono);

        String emailNorm = email.trim().toLowerCase();
        if (usuarioRepository.existsByEmail(emailNorm)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "EMAIL_DUPLICADO", "El email ya está registrado", "email");
        }

        if (pacienteRepository.existsByDni(dni.trim())) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "DNI_DUPLICADO", "El DNI ya está registrado", "dni");
        }

        Usuario usuario = new Usuario();
        usuario.setNombre(nombre.trim());
        usuario.setApellido(apellido.trim());
        usuario.setEmail(emailNorm);
        usuario.setContrasena(passwordEncoder.encode(contrasena));
        usuario.setRol(Usuario.Rol.PACIENTE);
        usuario.setActivo(true);
        usuario.setContrasenaPendiente(false);

        Usuario nuevoUsuario = usuarioRepository.save(usuario);

        Paciente paciente = new Paciente();
        paciente.setUsuario(nuevoUsuario);
        paciente.setDni(dni.trim());
        paciente.setTelefono(telefono.trim());

        pacienteRepository.save(paciente);

        return mapToRespuesta(nuevoUsuario, paciente);
    }

    public UsuarioRespuesta login(String email, String contrasena) {
        if (email == null || email.isBlank() || contrasena == null || contrasena.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Faltan email o contraseña", "email");
        }

        String emailNorm = email.trim().toLowerCase();
        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(emailNorm);

        if (usuarioOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            if (Boolean.TRUE.equals(usuario.getContrasenaPendiente())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "ACTIVACION_PENDIENTE", "Tu cuenta todavía no tiene contraseña. Revisá tu correo o pedí un código nuevo.");
            }
        }

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

        ServicioToken.ResultadoToken tokenRes = servicioToken.generar(usuario);
        return mapToRespuestaConToken(usuario, paciente, tokenRes.token(), tokenRes.venceEn().toString());
    }

    @Autowired
    private ProveedorUsuarioActual proveedorUsuarioActual;

    @Transactional
    public UsuarioRespuesta actualizarPerfil(Integer id, Map<String, String> body) {
        UsuarioActual actual = proveedorUsuarioActual.obtenerActual().orElse(null);
        if (actual != null && !actual.esAdmin()) {
            if (id == null || !id.equals(actual.id())) {
                throw new ExcepcionApi(HttpStatus.FORBIDDEN, "SIN_PERMISO", "No tenés permiso para modificar el perfil de otro usuario.");
            }
        }

        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "USUARIO_NO_ENCONTRADO", "Usuario no encontrado"));

        if (body == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "Solicitud nula");
        }

        String nombre = body.get("nombre");
        String apellido = body.get("apellido");
        String telefono = body.get("telefono");

        if (nombre == null || nombre.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre es obligatorio", "nombre");
        }
        if (apellido == null || apellido.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El apellido es obligatorio", "apellido");
        }
        if (telefono == null || telefono.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El teléfono es obligatorio", "telefono");
        }
        validarTelefono(telefono);

        usuario.setNombre(nombre.trim());
        usuario.setApellido(apellido.trim());
        usuarioRepository.save(usuario);

        Paciente paciente = null;
        if (usuario.getRol() == Usuario.Rol.PACIENTE) {
            paciente = pacienteRepository.findByUsuarioId(usuario.getId())
                    .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "PACIENTE_NO_ENCONTRADO", "Paciente no encontrado"));
            paciente.setTelefono(telefono.trim());
            pacienteRepository.save(paciente);
        }

        return mapToRespuesta(usuario, paciente);
    }

    private void validarTelefono(String telefono) {
        String num = telefono.replaceAll("[\\s\\-\\(\\)\\+]", "");
        if (num.length() < 7 || num.length() > 15 || !num.matches("\\d+")) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El teléfono debe contener entre 7 y 15 dígitos numéricos", "telefono");
        }
    }

    private UsuarioRespuesta mapToRespuesta(Usuario usuario, Paciente paciente) {
        return mapToRespuestaConToken(usuario, paciente, null, null);
    }

    private UsuarioRespuesta mapToRespuestaConToken(Usuario usuario, Paciente paciente, String token, String tokenVenceEn) {
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
                pacienteResumen,
                token,
                tokenVenceEn
        );
    }
}
