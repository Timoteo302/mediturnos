package com.mediturnos.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.UsuarioRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
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

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @BeforeEach
    void setUp() {
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
}
