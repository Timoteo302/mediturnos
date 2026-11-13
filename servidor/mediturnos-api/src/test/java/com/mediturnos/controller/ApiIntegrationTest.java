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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
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

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @BeforeEach
    void setUp() {
        turnoRepository.deleteAll();
        horarioAtencionRepository.deleteAll();
        medicoRepository.deleteAll();
        especialidadRepository.deleteAll();
        pacienteRepository.deleteAll();
        usuarioRepository.deleteAll();

        // Admin
        Usuario admin = new Usuario();
        admin.setNombre("Administrador");
        admin.setApellido("MediTurnos");
        admin.setEmail("admin@mediturnos.com");
        admin.setContrasena(passwordEncoder.encode("Admin1234"));
        admin.setRol(Usuario.Rol.ADMIN);
        admin.setActivo(true);
        usuarioRepository.save(admin);

        // Paciente
        Usuario pacienteUser = new Usuario();
        pacienteUser.setNombre("Matías");
        pacienteUser.setApellido("Romero");
        pacienteUser.setEmail("paciente@mediturnos.com");
        pacienteUser.setContrasena(passwordEncoder.encode("Paciente1234"));
        pacienteUser.setRol(Usuario.Rol.PACIENTE);
        pacienteUser.setActivo(true);
        Usuario savedPacienteUser = usuarioRepository.save(pacienteUser);

        Paciente paciente = new Paciente();
        paciente.setUsuario(savedPacienteUser);
        paciente.setDni("36782904");
        paciente.setTelefono("1122334455");
        pacienteRepository.save(paciente);
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
                "dni", "40123456"
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
        // Crear especialidad válida
        Map<String, String> espData = Map.of(
                "nombre", "Cardiología",
                "descripcion", "Especialidad del corazón"
        );
        mockMvc.perform(post("/especialidades")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(espData)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.nombre").value("Cardiología"))
                .andExpect(jsonPath("$.activo").value(true));

        // Probar especialidad duplicada (con sin tilde)
        Map<String, String> espDuplicada = Map.of("nombre", "cardiologia");
        mockMvc.perform(post("/especialidades")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(espDuplicada)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.codigo").value("ESPECIALIDAD_DUPLICADA"))
                .andExpect(jsonPath("$.campo").value("nombre"));

        // Nombre vacío -> 400
        Map<String, String> espVacia = Map.of("nombre", "");
        mockMvc.perform(post("/especialidades")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(espVacia)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"))
                .andExpect(jsonPath("$.campo").value("nombre"));
    }

    @Test
    void test7_medicosEndpoints() throws Exception {
        // Guardar especialidad
        Especialidad esp = new Especialidad();
        esp.setNombre("Cardiología");
        esp.setDescripcion("Corazón");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        // POST Médico válido
        Map<String, Object> medicoBody = Map.of(
                "nombre", "Juan Manuel",
                "apellido", "Gómez",
                "especialidadId", esp.getId(),
                "matricula", "114820",
                "activo", true
        );
        MvcResult res = mockMvc.perform(post("/medicos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(medicoBody)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.nombre").value("Juan Manuel"))
                .andExpect(jsonPath("$.especialidad.nombre").value("Cardiología"))
                .andReturn();

        // Repetir matrícula -> 409 MATRICULA_DUPLICADA
        mockMvc.perform(post("/medicos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(medicoBody)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.codigo").value("MATRICULA_DUPLICADA"))
                .andExpect(jsonPath("$.campo").value("matricula"));
    }

    @Test
    void test8_horariosEndpoints() throws Exception {
        // Crear especialidad y médico
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

        // Cargar agenda de horarios
        Map<String, Object> agenda = Map.of(
                "horarios", List.of(
                        Map.of("diaSemana", 1, "horaInicio", "08:30", "horaFin", "12:30", "duracionTurno", 30)
                )
        );

        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
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
        // Crear especialidad, médico, agenda y paciente
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

        Paciente paciente = pacienteRepository.findAll().get(0);

        // Asignar agenda para un día futuro (ej: dentro de 10 días)
        LocalDate fechaFutura = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(10);
        int diaSemana = fechaFutura.getDayOfWeek().getValue();

        Map<String, Object> agenda = Map.of(
                "horarios", List.of(
                        Map.of("diaSemana", diaSemana, "horaInicio", "09:00", "horaFin", "12:00", "duracionTurno", 30)
                )
        );
        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(agenda)))
                .andExpect(status().isOk());

        // POST Turno en horario libre
        Map<String, Object> turnoPost = Map.of(
                "paciente", Map.of("id", paciente.getId()),
                "medico", Map.of("id", medico.getId()),
                "fecha", fechaFutura.toString(),
                "hora", "09:30",
                "claveSolicitud", "uuid-test-123"
        );

        MvcResult result = mockMvc.perform(post("/turnos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(turnoPost)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.estado").value("PENDIENTE"))
                .andExpect(jsonPath("$.paciente.id").value(paciente.getId()))
                .andExpect(jsonPath("$.medico.id").value(medico.getId()))
                .andReturn();

        // Repetir el mismo POST con la misma claveSolicitud -> 200 OK con el mismo ID (idempotencia)
        mockMvc.perform(post("/turnos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(turnoPost)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.claveSolicitud").value("uuid-test-123"));

        // GET /turnos/{id}
        String content = result.getResponse().getContentAsString();
        Map<?, ?> map = new ObjectMapper().readValue(content, Map.class);
        Integer turnoId = (Integer) map.get("id");

        mockMvc.perform(get("/turnos/" + turnoId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(turnoId));

        // GET /medicos/{id}/disponibilidad
        mockMvc.perform(get("/medicos/" + medico.getId() + "/disponibilidad?fecha=" + fechaFutura))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].hora").value("09:00"))
                .andExpect(jsonPath("$[0].disponible").value(true))
                .andExpect(jsonPath("$[1].hora").value("09:30"))
                .andExpect(jsonPath("$[1].disponible").value(false));
    }
}
