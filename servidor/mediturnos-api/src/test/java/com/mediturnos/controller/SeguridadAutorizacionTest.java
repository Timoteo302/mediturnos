package com.mediturnos.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mediturnos.model.Especialidad;
import com.mediturnos.model.Medico;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Turno;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.EspecialidadRepository;
import com.mediturnos.repository.HorarioAtencionRepository;
import com.mediturnos.repository.MedicoRepository;
import com.mediturnos.repository.NotificacionRepository;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.TurnoRepository;
import com.mediturnos.repository.UsuarioRepository;
import com.mediturnos.service.ServicioToken;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Pruebas de integración específicas para seguridad JWT y autorización por rol y por dueño.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class SeguridadAutorizacionTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    @Autowired
    private EspecialidadRepository especialidadRepository;

    @Autowired
    private MedicoRepository medicoRepository;

    @Autowired
    private HorarioAtencionRepository horarioAtencionRepository;

    @Autowired
    private TurnoRepository turnoRepository;

    @Autowired
    private NotificacionRepository notificacionRepository;

    @Autowired
    private ServicioToken servicioToken;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private Usuario admin;
    private Usuario uPacienteA;
    private Usuario uPacienteB;
    private Paciente pacienteA;
    private Paciente pacienteB;
    private Medico medico;
    private String tokenAdmin;
    private String tokenPacienteA;
    private String tokenPacienteB;

    @BeforeEach
    void setUp() {
        notificacionRepository.deleteAll();
        turnoRepository.deleteAll();
        horarioAtencionRepository.deleteAll();
        medicoRepository.deleteAll();
        especialidadRepository.deleteAll();
        pacienteRepository.deleteAll();
        usuarioRepository.deleteAll();

        // Admin
        admin = new Usuario();
        admin.setNombre("Admin");
        admin.setApellido("Sistema");
        admin.setEmail("admin@mediturnos.com");
        admin.setContrasena(passwordEncoder.encode("Admin1234"));
        admin.setRol(Usuario.Rol.ADMIN);
        admin.setActivo(true);
        admin = usuarioRepository.save(admin);
        tokenAdmin = servicioToken.generar(admin).token();

        // Paciente A
        uPacienteA = new Usuario();
        uPacienteA.setNombre("PacienteA");
        uPacienteA.setApellido("Perez");
        uPacienteA.setEmail("paciente.a@mediturnos.com");
        uPacienteA.setContrasena(passwordEncoder.encode("Paciente1234"));
        uPacienteA.setRol(Usuario.Rol.PACIENTE);
        uPacienteA.setActivo(true);
        uPacienteA = usuarioRepository.save(uPacienteA);

        pacienteA = new Paciente();
        pacienteA.setUsuario(uPacienteA);
        pacienteA.setDni("11111111");
        pacienteA.setTelefono("1122334455");
        pacienteA = pacienteRepository.save(pacienteA);
        tokenPacienteA = servicioToken.generar(uPacienteA).token();

        // Paciente B
        uPacienteB = new Usuario();
        uPacienteB.setNombre("PacienteB");
        uPacienteB.setApellido("Gomez");
        uPacienteB.setEmail("paciente.b@mediturnos.com");
        uPacienteB.setContrasena(passwordEncoder.encode("Paciente1234"));
        uPacienteB.setRol(Usuario.Rol.PACIENTE);
        uPacienteB.setActivo(true);
        uPacienteB = usuarioRepository.save(uPacienteB);

        pacienteB = new Paciente();
        pacienteB.setUsuario(uPacienteB);
        pacienteB.setDni("22222222");
        pacienteB.setTelefono("1199887766");
        pacienteB = pacienteRepository.save(pacienteB);
        tokenPacienteB = servicioToken.generar(uPacienteB).token();

        Especialidad esp = new Especialidad();
        esp.setNombre("Pediatría");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        medico = new Medico();
        medico.setNombre("Dr. Roberto");
        medico.setApellido("Sosa");
        medico.setMatricula("54321");
        medico.setEspecialidad(esp);
        medico.setActivo(true);
        medico = medicoRepository.save(medico);
    }

    @Test
    void testLoginDevuelveTokenYVencimiento() throws Exception {
        Map<String, String> body = Map.of(
                "email", "paciente.a@mediturnos.com",
                "contrasena", "Paciente1234"
        );

        mockMvc.perform(post("/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists())
                .andExpect(jsonPath("$.tokenVenceEn").exists());
    }

    @Test
    void testGetTurnosSinTokenRetorna401() throws Exception {
        mockMvc.perform(get("/turnos"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.codigo").value("NO_AUTENTICADO"))
                .andExpect(jsonPath("$.error").value("Tu sesión venció o no es válida. Iniciá sesión de nuevo."));
    }

    @Test
    void testTokenInvalidoOVencidoRetorna401() throws Exception {
        mockMvc.perform(get("/turnos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer token_invalido_xyz"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.codigo").value("NO_AUTENTICADO"));
    }

    @Test
    void testRutasPublicasSinTokenRetornan200() throws Exception {
        mockMvc.perform(get("/salud")).andExpect(status().isOk());
        mockMvc.perform(get("/especialidades")).andExpect(status().isOk());
        mockMvc.perform(get("/medicos")).andExpect(status().isOk());
        mockMvc.perform(get("/medicos/" + medico.getId())).andExpect(status().isOk());
        mockMvc.perform(get("/respuesta-turno?token=inexistente&asistira=true")).andExpect(status().isNotFound());
    }

    @Test
    void testPacienteAPideTurnosDePacienteBRetorna403() throws Exception {
        mockMvc.perform(get("/turnos?pacienteId=" + pacienteB.getId())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPacienteA))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"))
                .andExpect(jsonPath("$.error").value("No tenés permiso para consultar turnos de otro paciente."));
    }

    @Test
    void testPacienteAPideTurnoEspecificoDePacienteBRetorna403() throws Exception {
        Turno turnoB = new Turno();
        turnoB.setPaciente(pacienteB);
        turnoB.setMedico(medico);
        turnoB.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turnoB.setHora(LocalTime.of(10, 0));
        turnoB.setEstado("PENDIENTE");
        turnoB.setClaveSolicitud("req-turno-b");
        turnoB = turnoRepository.save(turnoB);

        mockMvc.perform(get("/turnos/" + turnoB.getId())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPacienteA))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"));
    }

    @Test
    void testPacienteAIntentaCancelarTurnoDePacienteBRetorna403() throws Exception {
        Turno turnoB = new Turno();
        turnoB.setPaciente(pacienteB);
        turnoB.setMedico(medico);
        turnoB.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turnoB.setHora(LocalTime.of(10, 0));
        turnoB.setEstado("PENDIENTE");
        turnoB.setClaveSolicitud("req-canc-b");
        turnoB = turnoRepository.save(turnoB);

        mockMvc.perform(patch("/turnos/" + turnoB.getId() + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPacienteA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CANCELADO\"}"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"));
    }

    @Test
    void testPacienteIntentaConfirmarTurnoRetorna403() throws Exception {
        Turno turnoA = new Turno();
        turnoA.setPaciente(pacienteA);
        turnoA.setMedico(medico);
        turnoA.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(1));
        turnoA.setHora(LocalTime.of(10, 0));
        turnoA.setEstado("PENDIENTE");
        turnoA.setClaveSolicitud("req-conf-a");
        turnoA = turnoRepository.save(turnoA);

        mockMvc.perform(patch("/turnos/" + turnoA.getId() + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPacienteA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CONFIRMADO\"}"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"));
    }

    @Test
    void testPacienteIntentaCrearMedicoRetorna403YAdmin201() throws Exception {
        Map<String, Object> body = Map.of(
                "nombre", "Carlos",
                "apellido", "Lopez",
                "matricula", "998877",
                "especialidadId", medico.getEspecialidad().getId(),
                "activo", true
        );

        // Paciente -> 403
        mockMvc.perform(post("/medicos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPacienteA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"));

        // Admin -> 201
        mockMvc.perform(post("/medicos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isCreated());
    }

    @Test
    void testPacienteEditaPerfilDeOtroRetorna403() throws Exception {
        Map<String, String> body = Map.of(
                "nombre", "Hack",
                "apellido", "User",
                "telefono", "1122334455"
        );

        mockMvc.perform(put("/usuarios/" + uPacienteB.getId() + "/perfil")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPacienteA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"));
    }

    @Test
    void testPacienteLeeNotificacionesDeOtroRetorna403() throws Exception {
        mockMvc.perform(get("/notificaciones?usuarioId=" + uPacienteB.getId())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPacienteA))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"));
    }

    @Test
    void testReservaInvitadoSinTokenFunciona() throws Exception {
        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));
        int diaSemana = fechaHoy.plusDays(1).getDayOfWeek().getValue();

        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(Map.of("horarios", List.of(
                        Map.of("diaSemana", diaSemana, "horaInicio", "10:00", "horaFin", "11:00", "duracionTurno", 30)
                )))));

        Map<String, String> body = Map.of(
                "nombre", "Invitado",
                "apellido", "Prueba",
                "dni", "99887766",
                "email", "invitado2@test.com",
                "telefono", "1122334455",
                "medicoId", medico.getId().toString(),
                "fecha", fechaHoy.plusDays(1).toString(),
                "hora", "10:00",
                "claveSolicitud", "uuid-invitado-sec-1"
        );

        mockMvc.perform(post("/reservas/invitado")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.turno.estado").value("PENDIENTE"));
    }
}
