package com.mediturnos.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.UsuarioRepository;
import com.mediturnos.service.ServicioToken;
import com.mediturnos.service.push.ServicioPush;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Pruebas de integración para DispositivoController (Endpoints de registro y borrado de celulares).
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class DispositivoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private ServicioToken servicioToken;

    @MockitoBean
    private ServicioPush servicioPush;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private Usuario usuarioPrueba;
    private String tokenJwt;

    @BeforeEach
    void setUp() {
        usuarioRepository.deleteAll();

        usuarioPrueba = new Usuario();
        usuarioPrueba.setNombre("Carlos");
        usuarioPrueba.setApellido("Sosa");
        usuarioPrueba.setEmail("carlos.dispositivo@mediturnos.com");
        usuarioPrueba.setContrasena(passwordEncoder.encode("Password1234"));
        usuarioPrueba.setRol(Usuario.Rol.PACIENTE);
        usuarioPrueba.setActivo(true);
        usuarioPrueba = usuarioRepository.save(usuarioPrueba);

        tokenJwt = servicioToken.generar(usuarioPrueba).token();
    }

    @Test
    void testPutDispositivoSinTokenDevuelve401() throws Exception {
        Map<String, String> body = Map.of("tokenFcm", "fcm_token_super_largo_123");

        mockMvc.perform(put("/dispositivos/instalacion123")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.codigo").value("NO_AUTENTICADO"));
    }

    @Test
    void testPutDispositivoConTokenDevuelve204YLlamaARegistrarConIdDelJwt() throws Exception {
        Map<String, String> body = Map.of("tokenFcm", "fcm_token_valido_9999");

        mockMvc.perform(put("/dispositivos/instalacion123")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenJwt)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isNoContent());

        verify(servicioPush).registrarDispositivo("instalacion123", "fcm_token_valido_9999", (long) usuarioPrueba.getId(), "PACIENTE");
    }

    @Test
    void testPutDispositivoInstallationIdInvalidoDevuelve400() throws Exception {
        Map<String, String> body = Map.of("tokenFcm", "fcm_token_valido_9999");

        // Corto (< 8 caracteres)
        mockMvc.perform(put("/dispositivos/corto")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenJwt)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"));

        // Con caracteres inválidos
        mockMvc.perform(put("/dispositivos/instalacion_123!")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenJwt)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"));
    }

    @Test
    void testPutDispositivoTokenFcmVacioDevuelve400() throws Exception {
        Map<String, String> body = Map.of("tokenFcm", "");

        mockMvc.perform(put("/dispositivos/instalacion123")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenJwt)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(body)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("DATOS_INVALIDOS"));
    }

    @Test
    void testDeleteDispositivoSinTokenDevuelve401() throws Exception {
        mockMvc.perform(delete("/dispositivos/instalacion123"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void testDeleteDispositivoConTokenDevuelve204YLlamaAEliminar() throws Exception {
        mockMvc.perform(delete("/dispositivos/instalacion123")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenJwt))
                .andExpect(status().isNoContent());

        verify(servicioPush).eliminarDispositivo("instalacion123", (long) usuarioPrueba.getId());
    }
}
