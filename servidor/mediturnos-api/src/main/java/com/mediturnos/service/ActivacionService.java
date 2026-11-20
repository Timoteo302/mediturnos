package com.mediturnos.service;

import com.mediturnos.dto.UsuarioRespuesta;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.ActivacionCuenta;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.ActivacionCuentaRepository;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.UsuarioRepository;
import com.mediturnos.service.correo.ServicioCorreo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class ActivacionService {

    @Autowired
    private ActivacionCuentaRepository activacionCuentaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    @Autowired
    private ServicioCorreo servicioCorreo;

    @Value("${mediturnos.recuperacion.modo-demostracion:true}")
    private boolean modoDemostracion;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final SecureRandom random = new SecureRandom();

    /**
     * Genera un código de activación de 6 dígitos, invalida los anteriores
     * y envía el código por correo.
     * Devuelve el código en claro SOLAMENTE para modo demostración.
     */
    @Transactional
    public String generarYEnviar(Usuario usuario, String resumenTurno) {
        // Invalidar códigos anteriores
        List<ActivacionCuenta> anteriores = activacionCuentaRepository.findByUsuarioIdAndUsadoFalse(usuario.getId());
        anteriores.forEach(a -> a.setUsado(true));
        activacionCuentaRepository.saveAll(anteriores);

        // Generar 6 dígitos
        String codigo = String.format("%06d", random.nextInt(1000000));
        
        ActivacionCuenta activacion = new ActivacionCuenta();
        activacion.setUsuario(usuario);
        activacion.setCodigoHash(passwordEncoder.encode(codigo));
        activacion.setVenceEn(LocalDateTime.now().plusDays(7));
        activacionCuentaRepository.save(activacion);

        servicioCorreo.enviarCodigoActivacion(usuario.getEmail(), usuario.getNombre(), codigo, resumenTurno);
        
        return modoDemostracion ? codigo : null;
    }

    /**
     * Confirma la activación de cuenta, guarda la nueva contraseña e inicia sesión.
     */
    @Transactional
    public UsuarioRespuesta confirmar(String email, String codigo, String contrasena) {
        if (email == null || email.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El email es obligatorio", "email");
        }
        
        Usuario usuario = usuarioRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "ACTIVACION_NO_ENCONTRADA", "No hay una cuenta pendiente de activar con ese correo."));

        if (!Boolean.TRUE.equals(usuario.getContrasenaPendiente())) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "ACTIVACION_NO_ENCONTRADA", "No hay una cuenta pendiente de activar con ese correo.");
        }

        if (contrasena == null || contrasena.length() < 8 || contrasena.length() > 72) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La contraseña debe tener entre 8 y 72 caracteres", "contrasena");
        }
        
        if (codigo == null || codigo.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El código es obligatorio", "codigo");
        }

        ActivacionCuenta activacion = activacionCuentaRepository.findFirstByUsuarioIdAndUsadoFalseOrderByFechaCreacionDesc(usuario.getId())
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "ACTIVACION_NO_ENCONTRADA", "No hay una cuenta pendiente de activar con ese correo."));

        if (LocalDateTime.now().isAfter(activacion.getVenceEn())) {
            activacion.setUsado(true);
            activacionCuentaRepository.save(activacion);
            throw new ExcepcionApi(HttpStatus.GONE, "CODIGO_VENCIDO", "El código ha vencido. Solicitá uno nuevo.");
        }
        
        if (activacion.getIntentos() >= 5) {
            throw new ExcepcionApi(HttpStatus.TOO_MANY_REQUESTS, "DEMASIADOS_INTENTOS", "Demasiados intentos fallidos. Solicitá un código nuevo.");
        }

        if (!passwordEncoder.matches(codigo.trim(), activacion.getCodigoHash())) {
            activacion.setIntentos(activacion.getIntentos() + 1);
            activacionCuentaRepository.save(activacion);
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "CODIGO_INVALIDO", "El código es incorrecto.");
        }

        // Activación exitosa
        usuario.setContrasena(passwordEncoder.encode(contrasena));
        usuario.setContrasenaPendiente(false);
        usuarioRepository.save(usuario);
        
        activacion.setUsado(true);
        activacionCuentaRepository.save(activacion);
        
        // Mapear como login
        Paciente paciente = null;
        if (usuario.getRol() == Usuario.Rol.PACIENTE) {
            paciente = pacienteRepository.findByUsuarioId(usuario.getId()).orElse(null);
        }

        return mapToRespuesta(usuario, paciente);
    }
    
    /**
     * Reenvía el código de activación si no se pidió hace menos de 60 segundos.
     */
    @Transactional
    public String reenviar(String email) {
        if (email == null || email.isBlank()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El email es obligatorio", "email");
        }
        
        Usuario usuario = usuarioRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "ACTIVACION_NO_ENCONTRADA", "No hay una cuenta pendiente de activar con ese correo."));

        if (!Boolean.TRUE.equals(usuario.getContrasenaPendiente())) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "ACTIVACION_NO_ENCONTRADA", "No hay una cuenta pendiente de activar con ese correo.");
        }
        
        activacionCuentaRepository.findFirstByUsuarioIdAndUsadoFalseOrderByFechaCreacionDesc(usuario.getId())
                .ifPresent(act -> {
                    // Si se creó en el último minuto
                    if (act.getFechaCreacion() != null && act.getFechaCreacion().plusSeconds(60).isAfter(LocalDateTime.now())) {
                        throw new ExcepcionApi(HttpStatus.TOO_MANY_REQUESTS, "ESPERA_PARA_REENVIAR", "Esperá un minuto para pedir otro código.");
                    }
                });
                
        return generarYEnviar(usuario, "Tenés turnos reservados en MediTurnos.");
    }

    private UsuarioRespuesta mapToRespuesta(Usuario usuario, Paciente paciente) {
        com.mediturnos.dto.PacienteResumen pacienteResumen = null;
        if (usuario.getRol() == Usuario.Rol.PACIENTE && paciente != null) {
            pacienteResumen = new com.mediturnos.dto.PacienteResumen(paciente.getId(), paciente.getDni(), paciente.getTelefono());
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
