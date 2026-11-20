package com.mediturnos.service;

import com.mediturnos.dto.TurnoRespuesta;
import com.mediturnos.dto.TurnoCreacionSolicitud;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.TurnoRepository;
import com.mediturnos.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Servicio para reservas de turnos de usuarios no registrados.
 */
@Service
public class ReservaInvitadoService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    @Autowired
    private TurnoService turnoService;

    @Autowired
    private TurnoRepository turnoRepository;

    @Autowired
    private ActivacionService activacionService;

    @Autowired
    private ValidadorDatosPersona validador;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Transactional
    public Map<String, Object> reservar(Map<String, String> body) {
        String nombre = body.get("nombre");
        String apellido = body.get("apellido");
        String dni = body.get("dni");
        String email = body.get("email");
        String telefono = body.get("telefono");

        validador.validarNombre(nombre);
        validador.validarApellido(apellido);
        validador.validarEmail(email);
        validador.validarDni(dni);
        validador.validarTelefono(telefono);

        String emailNorm = email.trim().toLowerCase();
        String dniTrim = dni.trim();

        Optional<Usuario> userByEmail = usuarioRepository.findByEmail(emailNorm);
        Optional<Paciente> pacienteByDni = pacienteRepository.findByDni(dniTrim);

        Usuario usuario;
        Paciente paciente;

        if (userByEmail.isEmpty() && pacienteByDni.isEmpty()) {
            usuario = new Usuario();
            usuario.setNombre(nombre.trim());
            usuario.setApellido(apellido.trim());
            usuario.setEmail(emailNorm);
            usuario.setContrasena(passwordEncoder.encode(UUID.randomUUID().toString()));
            usuario.setRol(Usuario.Rol.PACIENTE);
            usuario.setActivo(true);
            usuario.setContrasenaPendiente(true);
            usuario = usuarioRepository.save(usuario);

            paciente = new Paciente();
            paciente.setUsuario(usuario);
            paciente.setDni(dniTrim);
            paciente.setTelefono(telefono.trim());
            paciente = pacienteRepository.save(paciente);
        } else {
            if (userByEmail.isPresent() && pacienteByDni.isPresent()) {
                Usuario u = userByEmail.get();
                Paciente p = pacienteByDni.get();
                
                if (u.getId().equals(p.getUsuario().getId()) && Boolean.TRUE.equals(u.getContrasenaPendiente())) {
                    usuario = u;
                    paciente = p;
                    usuario.setNombre(nombre.trim());
                    usuario.setApellido(apellido.trim());
                    paciente.setTelefono(telefono.trim());
                    usuarioRepository.save(usuario);
                    pacienteRepository.save(paciente);
                } else {
                    throw new ExcepcionApi(HttpStatus.CONFLICT, "CUENTA_EXISTENTE", "Ya tenés una cuenta con este correo o DNI. Iniciá sesión para reservar.", "email");
                }
            } else {
                String campo = userByEmail.isPresent() ? "email" : "dni";
                throw new ExcepcionApi(HttpStatus.CONFLICT, "CUENTA_EXISTENTE", "Ya tenés una cuenta con este correo o DNI. Iniciá sesión para reservar.", campo);
            }
        }

        // Límite invitado
        long turnosFuturos = turnoRepository.findByPacienteId(paciente.getId()).stream()
                .filter(t -> ("PENDIENTE".equals(t.getEstado()) || "CONFIRMADO".equals(t.getEstado())) 
                          && t.getFecha().isAfter(LocalDateTime.now().toLocalDate().minusDays(1)))
                .count();
        if (turnosFuturos >= 2) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "LIMITE_INVITADO", "Activá tu cuenta para reservar más turnos.");
        }

        // Reutilizar lógica de turno
        TurnoCreacionSolicitud sol = new TurnoCreacionSolicitud();
        sol.setPacienteId(paciente.getId());
        sol.setMedicoId(Integer.parseInt(body.get("medicoId")));
        sol.setFecha(body.get("fecha"));
        sol.setHora(body.get("hora"));
        sol.setClaveSolicitud(body.get("claveSolicitud"));

        TurnoRespuesta turnoRespuesta = turnoService.crear(sol).respuesta();

        String resumen = String.format("Tu turno con %s el %s a las %s quedó reservado.", 
                                       turnoRespuesta.getMedico().getNombre() + " " + turnoRespuesta.getMedico().getApellido(),
                                       turnoRespuesta.getFecha().substring(8,10) + "/" + turnoRespuesta.getFecha().substring(5,7),
                                       turnoRespuesta.getHora());
        String demoCode = activacionService.generarYEnviar(usuario, resumen);

        Map<String, Object> respuestaFinal = new HashMap<>();
        respuestaFinal.put("turno", turnoRespuesta);
        respuestaFinal.put("email", emailNorm);
        respuestaFinal.put("venceEnDias", 7);
        if (demoCode != null) {
            respuestaFinal.put("codigoDemostracion", demoCode);
        }

        return respuestaFinal;
    }
}
