package com.mediturnos.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mediturnos.model.Especialidad;
import com.mediturnos.model.Medico;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.EspecialidadRepository;
import com.mediturnos.repository.HorarioAtencionRepository;
import com.mediturnos.repository.MedicoRepository;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.UsuarioRepository;
import com.mediturnos.repository.TurnoRepository;
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
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;
import com.mediturnos.service.RecordatorioTurnosService;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.time.LocalTime;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class ApiIntegrationTest {

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
    private ServicioToken servicioToken;

    @Autowired(required = false)
    private RecordatorioTurnosService recordatorioTurnosService;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private Usuario admin;
    private Usuario pacienteUser;
    private Paciente paciente;
    private String tokenAdmin;
    private String tokenPaciente;

    @BeforeEach
    void setUp() {
        turnoRepository.deleteAll();
        horarioAtencionRepository.deleteAll();
        medicoRepository.deleteAll();
        especialidadRepository.deleteAll();
        pacienteRepository.deleteAll();
        usuarioRepository.deleteAll();

        // Admin
        admin = new Usuario();
        admin.setNombre("Administrador");
        admin.setApellido("MediTurnos");
        admin.setEmail("admin@mediturnos.com");
        admin.setContrasena(passwordEncoder.encode("Admin1234"));
        admin.setRol(Usuario.Rol.ADMIN);
        admin.setActivo(true);
        admin = usuarioRepository.save(admin);
        tokenAdmin = servicioToken.generar(admin).token();

        // Paciente
        pacienteUser = new Usuario();
        pacienteUser.setNombre("Matías");
        pacienteUser.setApellido("Romero");
        pacienteUser.setEmail("paciente@mediturnos.com");
        pacienteUser.setContrasena(passwordEncoder.encode("Paciente1234"));
        pacienteUser.setRol(Usuario.Rol.PACIENTE);
        pacienteUser.setActivo(true);
        pacienteUser = usuarioRepository.save(pacienteUser);

        paciente = new Paciente();
        paciente.setUsuario(pacienteUser);
        paciente.setDni("36782904");
        paciente.setTelefono("1122334455");
        paciente = pacienteRepository.save(paciente);
        tokenPaciente = servicioToken.generar(pacienteUser).token();
    }

    @Test
    void test1_loginAdmin() throws Exception {
        Map<String, String> body = Map.of(
                "email", "admin@mediturnos.com",
                "contrasena", "Admin1234"
        );

        mockMvc.perform(post("/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rol").value("ADMIN"))
                .andExpect(jsonPath("$.paciente").doesNotExist())
                .andExpect(jsonPath("$.contrasena").doesNotExist())
                .andExpect(jsonPath("$.token").exists())
                .andExpect(jsonPath("$.*", org.hamcrest.Matchers.not(org.hamcrest.Matchers.hasItem(org.hamcrest.Matchers.containsString("contrasena")))));
    }

    @Test
    void test2_loginPaciente() throws Exception {
        Map<String, String> body = Map.of(
                "email", "paciente@mediturnos.com",
                "contrasena", "Paciente1234"
        );

        mockMvc.perform(post("/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rol").value("PACIENTE"))
                .andExpect(jsonPath("$.paciente.id").exists())
                .andExpect(jsonPath("$.paciente.dni").value("36782904"))
                .andExpect(jsonPath("$.token").exists())
                .andExpect(jsonPath("$.contrasena").doesNotExist());
    }

    @Test
    void test3_loginCredencialesInvalidas() throws Exception {
        Map<String, String> body = Map.of(
                "email", "paciente@mediturnos.com",
                "contrasena", "WrongPassword"
        );

        mockMvc.perform(post("/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.codigo").value("CREDENCIALES_INVALIDAS"));
    }

    @Test
    void test4_registroYValidaciones() throws Exception {
        // Registro válido
        Map<String, String> nuevo = Map.of(
                "nombre", "Juan",
                "apellido", "Pérez",
                "email", "juan.perez@test.com",
                "contrasena", "Password123",
                "dni", "40123456",
                "telefono", "1199887766"
        );

        mockMvc.perform(post("/usuarios")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(nuevo)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.paciente.id").exists())
                .andExpect(jsonPath("$.paciente.dni").value("40123456"));

        // Repetir el mismo email -> 409 EMAIL_DUPLICADO
        mockMvc.perform(post("/usuarios")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(nuevo)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.codigo").value("EMAIL_DUPLICADO"))
                .andExpect(jsonPath("$.campo").value("email"));

        // Mismo DNI con otro email -> 409 DNI_DUPLICADO
        Map<String, String> otroEmail = Map.of(
                "nombre", "Juan",
                "apellido", "Pérez",
                "email", "otro.juan@test.com",
                "contrasena", "Password123",
                "dni", "40123456",
                "telefono", "1199887766"
        );
        mockMvc.perform(post("/usuarios")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(otroEmail)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.codigo").value("DNI_DUPLICADO"))
                .andExpect(jsonPath("$.campo").value("dni"));

        // Sin DNI -> 400 DATOS_INVALIDOS
        Map<String, String> sinDni = Map.of(
                "nombre", "Juan",
                "apellido", "Pérez",
                "email", "sindni@test.com",
                "contrasena", "Password123"
        );
        mockMvc.perform(post("/usuarios")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(sinDni)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"))
                .andExpect(jsonPath("$.campo").value("dni"));
    }

    @Test
    void test5_recuperacionCompleta() throws Exception {
        // Solicitar por email
        Map<String, String> solicitarBody = Map.of("email", "paciente@mediturnos.com");
        MvcResult result = mockMvc.perform(post("/recuperacion/solicitar")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(solicitarBody)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.idRecuperacion").exists())
                .andExpect(jsonPath("$.codigoDemostracion").exists())
                .andReturn();

        String responseString = result.getResponse().getContentAsString();
        Map<?, ?> respMap = new ObjectMapper().readValue(responseString, Map.class);
        String idRecuperacion = (String) respMap.get("idRecuperacion");
        String codigoDemo = (String) respMap.get("codigoDemostracion");

        // Código incorrecto
        Map<String, String> restablecerMal = Map.of(
                "idRecuperacion", idRecuperacion,
                "codigo", "999999",
                "nuevaContrasena", "NuevaPass123"
        );
        mockMvc.perform(post("/recuperacion/restablecer")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(restablecerMal)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("CODIGO_INVALIDO"))
                .andExpect(jsonPath("$.intentosRestantes").exists());

        // Restablecer con código correcto
        Map<String, String> restablecerBien = Map.of(
                "idRecuperacion", idRecuperacion,
                "codigo", codigoDemo,
                "nuevaContrasena", "NuevaPass123"
        );
        mockMvc.perform(post("/recuperacion/restablecer")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(restablecerBien)))
                .andExpect(status().isNoContent());

        // Login con contraseña vieja da 401
        Map<String, String> loginVieja = Map.of(
                "email", "paciente@mediturnos.com",
                "contrasena", "Paciente1234"
        );
        mockMvc.perform(post("/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(loginVieja)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.codigo").value("CREDENCIALES_INVALIDAS"));

        // Login con contraseña nueva da 200
        Map<String, String> loginNueva = Map.of(
                "email", "paciente@mediturnos.com",
                "contrasena", "NuevaPass123"
        );
        mockMvc.perform(post("/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(loginNueva)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rol").value("PACIENTE"));

        // Probar recuperación por DNI
        Map<String, String> solicitarDni = Map.of("dni", "36782904");
        mockMvc.perform(post("/recuperacion/solicitar")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(solicitarDni)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.idRecuperacion").exists());
    }

    @Test
    void test6_especialidadesEndpoints() throws Exception {
        Map<String, String> espData = Map.of(
                "nombre", "Cardiología",
                "descripcion", "Especialidad del corazón"
        );
        mockMvc.perform(post("/especialidades")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(espData)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.nombre").value("Cardiología"))
                .andExpect(jsonPath("$.activo").value(true));

        Map<String, String> espDuplicada = Map.of("nombre", "cardiologia");
        mockMvc.perform(post("/especialidades")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(espDuplicada)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.codigo").value("ESPECIALIDAD_DUPLICADA"))
                .andExpect(jsonPath("$.campo").value("nombre"));

        Map<String, String> espVacia = Map.of("nombre", "");
        mockMvc.perform(post("/especialidades")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(espVacia)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"))
                .andExpect(jsonPath("$.campo").value("nombre"));
    }

    @Test
    void test7_medicosEndpoints() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Cardiología");
        esp.setDescripcion("Corazón");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Map<String, Object> medicoBody = Map.of(
                "nombre", "Juan Manuel",
                "apellido", "Gómez",
                "especialidadId", esp.getId(),
                "matricula", "114820",
                "activo", true
        );
        MvcResult res = mockMvc.perform(post("/medicos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(medicoBody)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.nombre").value("Juan Manuel"))
                .andExpect(jsonPath("$.especialidad.nombre").value("Cardiología"))
                .andReturn();

        mockMvc.perform(post("/medicos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(medicoBody)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.codigo").value("MATRICULA_DUPLICADA"))
                .andExpect(jsonPath("$.campo").value("matricula"));
    }

    @Test
    void test8_horariosEndpoints() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Dermatología");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Lucía");
        medico.setApellido("Benítez");
        medico.setMatricula("128450");
        medico.setEspecialidad(esp);
        medico.setActivo(true);
        medico = medicoRepository.save(medico);

        Map<String, Object> agenda = Map.of(
                "horarios", List.of(
                        Map.of("diaSemana", 1, "horaInicio", "08:30", "horaFin", "12:30", "duracionTurno", 30)
                )
        );

        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(agenda)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].horaInicio").value("08:30"))
                .andExpect(jsonPath("$[0].horaFin").value("12:30"));
    }

    @Test
    void test9_corsPreflight() throws Exception {
        mockMvc.perform(options("/medicos/1/estado")
                        .header("Origin", "http://localhost:3000")
                        .header("Access-Control-Request-Method", "PATCH"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Methods", org.hamcrest.Matchers.containsString("PATCH")));

        mockMvc.perform(options("/turnos/1")
                        .header("Origin", "http://localhost:3000")
                        .header("Access-Control-Request-Method", "PUT"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Methods", org.hamcrest.Matchers.containsString("PUT")));

        mockMvc.perform(options("/turnos/1/estado")
                        .header("Origin", "http://localhost:3000")
                        .header("Access-Control-Request-Method", "PATCH"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Methods", org.hamcrest.Matchers.containsString("PATCH")));
    }

    @Test
    void test10_turnosEndpoints() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Oftalmología");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Ramiro");
        medico.setApellido("Vaca");
        medico.setMatricula("98712");
        medico.setEspecialidad(esp);
        medico.setActivo(true);
        medico = medicoRepository.save(medico);

        LocalDate fechaFutura = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(10);
        int diaSemana = fechaFutura.getDayOfWeek().getValue();

        Map<String, Object> agenda = Map.of(
                "horarios", List.of(
                        Map.of("diaSemana", diaSemana, "horaInicio", "09:00", "horaFin", "12:00", "duracionTurno", 30)
                )
        );
        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(agenda)))
                .andExpect(status().isOk());

        Map<String, Object> turnoPost = Map.of(
                "paciente", Map.of("id", paciente.getId()),
                "medico", Map.of("id", medico.getId()),
                "fecha", fechaFutura.toString(),
                "hora", "09:30",
                "claveSolicitud", "uuid-test-123"
        );

        MvcResult result = mockMvc.perform(post("/turnos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(turnoPost)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.estado").value("PENDIENTE"))
                .andExpect(jsonPath("$.paciente.id").value(paciente.getId()))
                .andExpect(jsonPath("$.medico.id").value(medico.getId()))
                .andReturn();

        mockMvc.perform(post("/turnos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(turnoPost)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.claveSolicitud").value("uuid-test-123"));

        String content = result.getResponse().getContentAsString();
        Map<?, ?> map = new ObjectMapper().readValue(content, Map.class);
        Integer turnoId = (Integer) map.get("id");

        mockMvc.perform(get("/turnos/" + turnoId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(turnoId));

        mockMvc.perform(get("/medicos/" + medico.getId() + "/disponibilidad?fecha=" + fechaFutura))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].hora").value("09:00"))
                .andExpect(jsonPath("$[0].disponible").value(true))
                .andExpect(jsonPath("$[1].hora").value("09:30"))
                .andExpect(jsonPath("$[1].disponible").value(false));
    }

    @Test
    void test11_actualizarPerfilPaciente() throws Exception {
        Integer usuarioId = paciente.getUsuario().getId();

        Map<String, String> body = Map.of(
                "nombre", "Matías Modificado",
                "apellido", "Romero Mod",
                "telefono", "+5491122334455",
                "email", "otromail@test.com"
        );

        mockMvc.perform(put("/usuarios/" + usuarioId + "/perfil")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nombre").value("Matías Modificado"))
                .andExpect(jsonPath("$.apellido").value("Romero Mod"))
                .andExpect(jsonPath("$.email").value("paciente@mediturnos.com"))
                .andExpect(jsonPath("$.paciente.telefono").value("+5491122334455"));
    }

    @Test
    void test12_actualizarPerfilTelefonosInvalidos() throws Exception {
        Integer usuarioId = paciente.getUsuario().getId();

        Map<String, String> body1 = Map.of(
                "nombre", "A", "apellido", "B",
                "telefono", "38414,04667"
        );
        mockMvc.perform(put("/usuarios/" + usuarioId + "/perfil")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body1)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.campo").value("telefono"));

        Map<String, String> body2 = Map.of(
                "nombre", "Valido", "apellido", "Valido",
                "telefono", "123456"
        );
        mockMvc.perform(put("/usuarios/" + usuarioId + "/perfil")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body2)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.campo").value("telefono"));

        Map<String, String> body3 = Map.of(
                "apellido", "Valido",
                "telefono", "1122334455"
        );
        mockMvc.perform(put("/usuarios/" + usuarioId + "/perfil")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body3)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.campo").value("nombre"));

        mockMvc.perform(put("/usuarios/" + admin.getId() + "/perfil")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body2)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("SIN_PERMISO"));
    }

    @Test
    void test13_actualizarPerfilAdmin() throws Exception {
        Usuario adminUser = usuarioRepository.findByEmail("admin@mediturnos.com").get();

        Map<String, String> body = Map.of(
                "nombre", "Admin Modificado",
                "apellido", "Admin Apellido",
                "telefono", "1122334455"
        );

        mockMvc.perform(put("/usuarios/" + adminUser.getId() + "/perfil")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nombre").value("Admin Modificado"))
                .andExpect(jsonPath("$.paciente").doesNotExist());
    }

    @Test
    void test14_transicionesTurno() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Oftalmología");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Ramiro");
        medico.setApellido("Vaca");
        medico.setMatricula("98712");
        medico.setActivo(true);
        medico.setEspecialidad(esp);
        medico = medicoRepository.save(medico);

        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));
        Integer[] turnos = new Integer[3];
        for (int i = 0; i < 3; i++) {
            com.mediturnos.model.Turno t = new com.mediturnos.model.Turno();
            t.setPaciente(paciente);
            t.setMedico(medico);
            t.setFecha(fechaHoy);
            t.setHora(LocalTime.of(8 + i, 0));
            t.setEstado("PENDIENTE");
            t.setClaveSolicitud("uuid-hoy-" + i);
            t = turnoRepository.save(t);
            turnos[i] = t.getId();
        }

        mockMvc.perform(patch("/turnos/" + turnos[0] + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CANCELADO\"}"))
                .andExpect(status().isOk());

        mockMvc.perform(patch("/turnos/" + turnos[0] + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CONFIRMADO\"}"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.codigo").value("TRANSICION_INVALIDA"));

        mockMvc.perform(patch("/turnos/" + turnos[1] + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CONFIRMADO\"}"))
                .andExpect(status().isOk());

        mockMvc.perform(patch("/turnos/" + turnos[1] + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CANCELADO\"}"))
                .andExpect(status().isOk());

        mockMvc.perform(patch("/turnos/" + turnos[2] + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CONFIRMADO\"}"))
                .andExpect(status().isOk());

        mockMvc.perform(patch("/turnos/" + turnos[2] + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"ATENDIDO\"}"))
                .andExpect(status().isOk());

        mockMvc.perform(patch("/turnos/" + turnos[2] + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CANCELADO\"}"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.codigo").value("TRANSICION_INVALIDA"));
    }

    @Test
    void test15_reprogramacionYCancelacionCentro() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Pediatría");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Ana");
        medico.setApellido("Paz");
        medico.setMatricula("77777");
        medico.setActivo(true);
        medico.setEspecialidad(esp);
        medico = medicoRepository.save(medico);
        
        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));
        
        com.mediturnos.model.Turno t = new com.mediturnos.model.Turno();
        t.setPaciente(paciente);
        t.setMedico(medico);
        t.setFecha(fechaHoy);
        t.setHora(LocalTime.of(15, 0));
        t.setEstado("CONFIRMADO");
        t.setClaveSolicitud("uuid-reprogramacion");
        t = turnoRepository.save(t);
        
        Map<String, Object> req = Map.of("fecha", fechaHoy.plusDays(1).toString(), "hora", "16:00");
        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(Map.of("horarios", List.of(
                        Map.of("diaSemana", fechaHoy.plusDays(1).getDayOfWeek().getValue(), "horaInicio", "15:00", "horaFin", "17:00", "duracionTurno", 30)
                )))))
                .andExpect(status().isOk());
                
        mockMvc.perform(put("/turnos/" + t.getId())
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.estado").value("PENDIENTE"));
                
        mockMvc.perform(patch("/turnos/" + t.getId() + "/estado")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"estado\":\"CANCELADO\", \"origen\":\"CENTRO\"}"))
                .andExpect(status().isOk());
    }

    @Test
    void test16_asistenciaYRecordatorio() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Clínica");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Carlos");
        medico.setApellido("Sanz");
        medico.setMatricula("11111");
        medico.setActivo(true);
        medico.setEspecialidad(esp);
        medico = medicoRepository.save(medico);
        
        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));
        LocalTime horaTurno = LocalTime.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusHours(2);
        
        com.mediturnos.model.Turno t = new com.mediturnos.model.Turno();
        t.setPaciente(paciente);
        t.setMedico(medico);
        t.setFecha(fechaHoy);
        t.setHora(horaTurno);
        t.setEstado("PENDIENTE");
        t.setClaveSolicitud("uuid-recordatorio");
        t = turnoRepository.save(t);
        
        recordatorioTurnosService.procesarAhora();
        
        mockMvc.perform(post("/turnos/" + t.getId() + "/asistencia")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"asistira\": true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.respuestaPaciente").value("ASISTIRA"));
                
        mockMvc.perform(get("/notificaciones?usuarioId=" + paciente.getUsuario().getId())
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente))
                .andExpect(status().isOk());
    }

    @Test
    void test17_reservaInvitado() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Neurología");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Jose");
        medico.setApellido("Paz");
        medico.setMatricula("55555");
        medico.setActivo(true);
        medico.setEspecialidad(esp);
        medico = medicoRepository.save(medico);
        
        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));
        
        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(Map.of("horarios", List.of(
                        Map.of("diaSemana", fechaHoy.plusDays(1).getDayOfWeek().getValue(), "horaInicio", "10:00", "horaFin", "11:00", "duracionTurno", 30)
                )))))
                .andExpect(status().isOk());
                
        Map<String, String> body = Map.of(
                "nombre", "Invitado",
                "apellido", "Prueba",
                "dni", "12345678",
                "email", "invitado@test.com",
                "telefono", "1122334455",
                "medicoId", medico.getId().toString(),
                "fecha", fechaHoy.plusDays(1).toString(),
                "hora", "10:00",
                "claveSolicitud", "uuid-invitado-1"
        );
        
        MvcResult result = mockMvc.perform(post("/reservas/invitado")
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.turno.estado").value("PENDIENTE"))
                .andExpect(jsonPath("$.turno.pacienteCuentaPendiente").value(true))
                .andReturn();
                
        String codigo = (String) new ObjectMapper().readValue(result.getResponse().getContentAsString(), Map.class).get("codigoDemostracion");
        
        mockMvc.perform(post("/login").contentType(MediaType.APPLICATION_JSON).content("{\"email\":\"invitado@test.com\",\"contrasena\":\"12345678\"}"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("ACTIVACION_PENDIENTE"));
                
        mockMvc.perform(post("/activacion/confirmar").contentType(MediaType.APPLICATION_JSON).content("{\"email\":\"invitado@test.com\",\"codigo\":\"" + codigo + "\",\"contrasena\":\"NuevaClave123\"}"))
                .andExpect(status().isOk());
    }

    @Test
    void test17_saludYRutasInexistentes() throws Exception {
        mockMvc.perform(get("/salud"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.estado").value("ok"));

        mockMvc.perform(get("/ruta-que-no-existe")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.codigo").value("RUTA_NO_ENCONTRADA"))
                .andExpect(jsonPath("$.error").value("La ruta solicitada no existe"));

        mockMvc.perform(get("/")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.codigo").value("RUTA_NO_ENCONTRADA"));
    }

    @Test
    void test18_validacionDni() throws Exception {
        Especialidad esp = new Especialidad();
        esp.setNombre("Pediatría DNI");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Dr. DNI");
        medico.setApellido("Test");
        medico.setMatricula("998877");
        medico.setActivo(true);
        medico.setEspecialidad(esp);
        medico = medicoRepository.save(medico);

        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));

        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(Map.of("horarios", List.of(
                        Map.of("diaSemana", fechaHoy.plusDays(2).getDayOfWeek().getValue(), "horaInicio", "08:00", "horaFin", "12:00", "duracionTurno", 30)
                )))))
                .andExpect(status().isOk());

        List<String> dnisInvalidos = List.of("00000000", "0123456", "123");

        for (String dniInvalid : dnisInvalidos) {
            Map<String, String> bodyReg = Map.of(
                    "nombre", "Pedro",
                    "apellido", "Prueba",
                    "dni", dniInvalid,
                    "telefono", "1122334455",
                    "email", "reg_" + dniInvalid + "@test.com",
                    "contrasena", "Clave1234"
            );
            mockMvc.perform(post("/usuarios")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(new ObjectMapper().writeValueAsString(bodyReg)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"));

            Map<String, String> bodyInv = Map.of(
                    "nombre", "Pedro",
                    "apellido", "Prueba",
                    "dni", dniInvalid,
                    "email", "inv_" + dniInvalid + "@test.com",
                    "telefono", "1122334455",
                    "medicoId", medico.getId().toString(),
                    "fecha", fechaHoy.plusDays(2).toString(),
                    "hora", "08:00",
                    "claveSolicitud", "uuid-inv-" + dniInvalid
            );
            mockMvc.perform(post("/reservas/invitado")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(new ObjectMapper().writeValueAsString(bodyInv)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"));
        }

        Map<String, String> bodyRegValido = Map.of(
                "nombre", "Pedro",
                "apellido", "Prueba",
                "dni", "1234567",
                "telefono", "1122334455",
                "email", "reg_1234567@test.com",
                "contrasena", "Clave1234"
        );
        mockMvc.perform(post("/usuarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(bodyRegValido)))
                .andExpect(status().isCreated());

        Map<String, String> bodyInvValido = Map.of(
                "nombre", "Pedro",
                "apellido", "Prueba",
                "dni", "45858281",
                "email", "inv_45858281@test.com",
                "telefono", "1122334455",
                "medicoId", medico.getId().toString(),
                "fecha", fechaHoy.plusDays(2).toString(),
                "hora", "08:30",
                "claveSolicitud", "uuid-inv-45858281"
        );
        mockMvc.perform(post("/reservas/invitado")
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(bodyInvValido)))
                .andExpect(status().isCreated());
    }
}
