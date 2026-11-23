package com.mediturnos.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mediturnos.dto.DatosTurnoCorreo;
import com.mediturnos.model.Especialidad;
import com.mediturnos.model.Medico;
import com.mediturnos.model.Notificacion;
import com.mediturnos.model.Paciente;
import com.mediturnos.model.Turno;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.EspecialidadRepository;
import com.mediturnos.repository.MedicoRepository;
import com.mediturnos.repository.NotificacionRepository;
import com.mediturnos.repository.PacienteRepository;
import com.mediturnos.repository.TurnoRepository;
import com.mediturnos.repository.UsuarioRepository;
import com.mediturnos.service.NotificacionService;
import com.mediturnos.service.ServicioToken;
import com.mediturnos.service.correo.ServicioCorreo;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Pruebas de integración para las respuestas de turnos vía correo y controladores web.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class RespuestaTurnoControllerTest {

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
    private TurnoRepository turnoRepository;

    @Autowired
    private NotificacionRepository notificacionRepository;

    @Autowired
    private NotificacionService notificacionService;

    @Autowired
    private ServicioToken servicioToken;

    @MockitoBean
    private ServicioCorreo servicioCorreo;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private Usuario admin;
    private Usuario pUser;
    private Paciente paciente;
    private Medico medico;
    private String tokenAdmin;
    private String tokenPaciente;

    @BeforeEach
    void setUp() {
        notificacionRepository.deleteAll();
        turnoRepository.deleteAll();
        medicoRepository.deleteAll();
        especialidadRepository.deleteAll();
        pacienteRepository.deleteAll();
        usuarioRepository.deleteAll();

        // Admin
        admin = new Usuario();
        admin.setNombre("Admin");
        admin.setApellido("Sistema");
        admin.setEmail("admin@mediturnos.com");
        admin.setContrasena(passwordEncoder.encode("Admin123"));
        admin.setRol(Usuario.Rol.ADMIN);
        admin.setActivo(true);
        admin = usuarioRepository.save(admin);
        tokenAdmin = servicioToken.generar(admin).token();

        // Paciente
        pUser = new Usuario();
        pUser.setNombre("Juan");
        pUser.setApellido("Pérez");
        pUser.setEmail("juan@mediturnos.com");
        pUser.setContrasena(passwordEncoder.encode("Juan1234"));
        pUser.setRol(Usuario.Rol.PACIENTE);
        pUser.setActivo(true);
        pUser = usuarioRepository.save(pUser);

        paciente = new Paciente();
        paciente.setUsuario(pUser);
        paciente.setDni("30111222");
        paciente.setTelefono("1122334455");
        paciente = pacienteRepository.save(paciente);
        tokenPaciente = servicioToken.generar(pUser).token();

        Especialidad esp = new Especialidad();
        esp.setNombre("Cardiología");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        medico = new Medico();
        medico.setNombre("Dr. Carlos");
        medico.setApellido("Gómez");
        medico.setMatricula("12345");
        medico.setEspecialidad(esp);
        medico.setActivo(true);
        medico = medicoRepository.save(medico);
    }

    @Test
    void testRecordatorioGeneraTokenYEnviaCorreoConUrls() {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(1));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setClaveSolicitud("req-rec-1");
        turno = turnoRepository.save(turno);

        assertNull(turno.getTokenRespuesta());

        notificacionService.crearParaPaciente(turno, "RECORDATORIO_ASISTENCIA", "¿Vas a asistir?", "Mensaje recordatorio");

        Turno turnoActualizado = turnoRepository.findById(turno.getId()).orElseThrow();
        assertNotNull(turnoActualizado.getTokenRespuesta());
        assertFalse(turnoActualizado.getTokenRespuesta().isBlank());

        ArgumentCaptor<String> captorSi = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> captorNo = ArgumentCaptor.forClass(String.class);

        verify(servicioCorreo, times(1)).enviarRecordatorioAsistencia(
                eq("juan@mediturnos.com"),
                eq("Juan"),
                any(DatosTurnoCorreo.class),
                captorSi.capture(),
                captorNo.capture()
        );

        assertTrue(captorSi.getValue().contains("/respuesta-turno?token=" + turnoActualizado.getTokenRespuesta() + "&asistira=true"));
        assertTrue(captorNo.getValue().contains("/respuesta-turno?token=" + turnoActualizado.getTokenRespuesta() + "&asistira=false"));
    }

    @Test
    void testConfirmacionEnvicaCorreoConfirmado() throws Exception {
        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(fechaHoy);
        turno.setHora(LocalTime.of(20, 0));
        turno.setEstado("PENDIENTE");
        turno.setClaveSolicitud("req-conf-1");
        turno = turnoRepository.save(turno);

        mockMvc.perform(patch("/turnos/" + turno.getId() + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CONFIRMADO\"}"))
                .andExpect(status().isOk());

        verify(servicioCorreo, times(1)).enviarTurnoConfirmado(
                eq("juan@mediturnos.com"),
                eq("Juan"),
                any(DatosTurnoCorreo.class)
        );
    }

    @Test
    void testCancelacionCentroEnviaCorreo() throws Exception {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setClaveSolicitud("req-canc-1");
        turno = turnoRepository.save(turno);

        mockMvc.perform(patch("/turnos/" + turno.getId() + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CANCELADO\",\"origen\":\"CENTRO\"}"))
                .andExpect(status().isOk());

        verify(servicioCorreo, times(1)).enviarTurnoCanceladoCentro(
                eq("juan@mediturnos.com"),
                eq("Juan"),
                any(DatosTurnoCorreo.class)
        );
    }

    @Test
    void testCancelacionPacienteNoEnviaCorreoAlPacientePeroCreaNotificacionAdmin() throws Exception {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setClaveSolicitud("req-canc-paciente");
        turno = turnoRepository.save(turno);

        mockMvc.perform(patch("/turnos/" + turno.getId() + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CANCELADO\",\"origen\":\"PACIENTE\"}"))
                .andExpect(status().isOk());

        verify(servicioCorreo, never()).enviarTurnoCanceladoCentro(anyString(), anyString(), any());

        // Comprobamos que se crea una notificación para el administrador
        List<Notificacion> notificacionesAdmin = notificacionRepository.findTop50ByUsuarioIdOrderByFechaCreacionDesc(admin.getId());
        assertFalse(notificacionesAdmin.isEmpty());
        Notificacion notif = notificacionesAdmin.get(0);
        assertEquals("PACIENTE_NO_ASISTIRA", notif.getTipo());
        assertEquals("Turno cancelado por el paciente", notif.getTitulo());
        assertTrue(notif.getMensaje().contains("Juan Pérez canceló su turno del"));
    }

    @Test
    void testErrorDeCorreoNoFallaOperacion() throws Exception {
        LocalDate fechaHoy = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires"));
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(fechaHoy);
        turno.setHora(LocalTime.of(20, 0));
        turno.setEstado("PENDIENTE");
        turno.setClaveSolicitud("req-err-mail");
        turno = turnoRepository.save(turno);

        doThrow(new RuntimeException("Error en servicio SMTP")).when(servicioCorreo).enviarTurnoConfirmado(anyString(), anyString(), any());

        mockMvc.perform(patch("/turnos/" + turno.getId() + "/estado")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"estado\":\"CONFIRMADO\"}"))
                .andExpect(status().isOk());

        Turno turnoActualizado = turnoRepository.findById(turno.getId()).orElseThrow();
        assertEquals("CONFIRMADO", turnoActualizado.getEstado());
    }

    @Test
    void testGetRespuestaTurnoNoModificaBD() throws Exception {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setTokenRespuesta("token-test-get");
        turno.setClaveSolicitud("req-get-1");
        turno = turnoRepository.save(turno);

        mockMvc.perform(get("/respuesta-turno?token=token-test-get&asistira=true"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.TEXT_HTML))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("¿Confirmás que vas a asistir?")));

        Turno sinCambios = turnoRepository.findById(turno.getId()).orElseThrow();
        assertEquals("SIN_RESPUESTA", sinCambios.getRespuestaPaciente());
        assertEquals("PENDIENTE", sinCambios.getEstado());
    }

    @Test
    void testPostRespuestaTurnoConfirmarAsistencia() throws Exception {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setTokenRespuesta("token-confirmar");
        turno.setClaveSolicitud("req-post-confirmar");
        turno = turnoRepository.save(turno);

        mockMvc.perform(post("/respuesta-turno")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("token", "token-confirmar")
                        .param("asistira", "true"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Avisamos al centro que vas a asistir")));

        Turno modificado = turnoRepository.findById(turno.getId()).orElseThrow();
        assertEquals("ASISTIRA", modificado.getRespuestaPaciente());
    }

    @Test
    void testPostRespuestaTurnoCancelarAsistencia() throws Exception {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setTokenRespuesta("token-cancelar");
        turno.setClaveSolicitud("req-post-cancelar");
        turno = turnoRepository.save(turno);

        mockMvc.perform(post("/respuesta-turno")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("token", "token-cancelar")
                        .param("asistira", "false"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("cancelamos tu turno")));

        Turno modificado = turnoRepository.findById(turno.getId()).orElseThrow();
        assertEquals("NO_ASISTIRA", modificado.getRespuestaPaciente());
        assertEquals("CANCELADO", modificado.getEstado());
    }

    @Test
    void testTokenInvalidoRetorna404() throws Exception {
        mockMvc.perform(get("/respuesta-turno?token=inexistente&asistira=true"))
                .andExpect(status().isNotFound())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Este enlace no es válido.")));

        mockMvc.perform(post("/respuesta-turno")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("token", "inexistente")
                        .param("asistira", "true"))
                .andExpect(status().isNotFound())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Este enlace no es válido.")));
    }

    @Test
    void testSegundaRespuestaOEstadoCanceladoRetorna200ConMensaje() throws Exception {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setRespuestaPaciente("ASISTIRA");
        turno.setTokenRespuesta("token-ya-respondido");
        turno.setClaveSolicitud("req-segunda-resp");
        turno = turnoRepository.save(turno);

        mockMvc.perform(get("/respuesta-turno?token=token-ya-respondido&asistira=true"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Ya nos avisaste que vas a asistir.")));
    }

    @Test
    void testReprogramarLimpiaTokenRespuesta() throws Exception {
        Turno turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setTokenRespuesta("token-reprog");
        turno.setClaveSolicitud("req-reprog");
        turno = turnoRepository.save(turno);

        LocalDate nuevaFecha = LocalDate.now(ZoneId.of("America/Argentina/Buenos_Aires")).plusDays(3);
        int diaSemana = nuevaFecha.getDayOfWeek().getValue();
        mockMvc.perform(put("/medicos/" + medico.getId() + "/horarios")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenAdmin)
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(Map.of("horarios", List.of(
                        Map.of("diaSemana", diaSemana, "horaInicio", "10:00", "horaFin", "12:00", "duracionTurno", 30)
                )))));

        mockMvc.perform(put("/turnos/" + turno.getId())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + tokenPaciente)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(Map.of("fecha", nuevaFecha.toString(), "hora", "10:30"))))
                .andExpect(status().isOk());

        Turno reprogramado = turnoRepository.findById(turno.getId()).orElseThrow();
        assertNull(reprogramado.getTokenRespuesta());
    }
}
