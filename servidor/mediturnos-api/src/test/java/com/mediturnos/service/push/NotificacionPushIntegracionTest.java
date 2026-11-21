package com.mediturnos.service.push;

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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Pruebas de integración para verificar la invocación de ServicioPush al crear notificaciones y la resiliencia ante errores.
 */
@SpringBootTest
@Transactional
class NotificacionPushIntegracionTest {

    @Autowired
    private NotificacionService notificacionService;

    @Autowired
    private NotificacionRepository notificacionRepository;

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

    @MockitoBean
    private ServicioPush servicioPush;

    private Usuario usuarioPaciente;
    private Paciente paciente;
    private Turno turno;

    @BeforeEach
    void setUp() {
        notificacionRepository.deleteAll();
        turnoRepository.deleteAll();
        medicoRepository.deleteAll();
        especialidadRepository.deleteAll();
        pacienteRepository.deleteAll();
        usuarioRepository.deleteAll();

        usuarioPaciente = new Usuario();
        usuarioPaciente.setNombre("Matías");
        usuarioPaciente.setApellido("Pérez");
        usuarioPaciente.setEmail("matias.push@test.com");
        usuarioPaciente.setContrasena("hash1234");
        usuarioPaciente.setRol(Usuario.Rol.PACIENTE);
        usuarioPaciente.setActivo(true);
        usuarioPaciente = usuarioRepository.save(usuarioPaciente);

        paciente = new Paciente();
        paciente.setUsuario(usuarioPaciente);
        paciente.setDni("33445566");
        paciente.setTelefono("11223344");
        paciente = pacienteRepository.save(paciente);

        Especialidad esp = new Especialidad();
        esp.setNombre("Pediatría");
        esp.setActivo(true);
        esp = especialidadRepository.save(esp);

        Medico medico = new Medico();
        medico.setNombre("Dr. Roberto");
        medico.setApellido("Sosa");
        medico.setMatricula("54321");
        medico.setEspecialidad(esp);
        medico.setActivo(true);
        medico = medicoRepository.save(medico);

        turno = new Turno();
        turno.setPaciente(paciente);
        turno.setMedico(medico);
        turno.setFecha(LocalDate.now().plusDays(2));
        turno.setHora(LocalTime.of(10, 0));
        turno.setEstado("PENDIENTE");
        turno.setClaveSolicitud("req-push-1");
        turno = turnoRepository.save(turno);
    }

    @Test
    void testCrearNotificacionLlamaAEnviarAUsuarioConDatosCorrectos() {
        notificacionService.crearParaPaciente(turno, "TURNO_CONFIRMADO", "Tu turno está confirmado", "Te esperamos");

        List<Notificacion> guardadas = notificacionRepository.findAll();
        assertEquals(1, guardadas.size());
        Notificacion notif = guardadas.get(0);

        ArgumentCaptor<Long> usuarioIdCaptor = ArgumentCaptor.forClass(Long.class);
        ArgumentCaptor<String> tituloCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> cuerpoCaptor = ArgumentCaptor.forClass(String.class);
        @SuppressWarnings("unchecked")
        ArgumentCaptor<Map<String, String>> datosCaptor = ArgumentCaptor.forClass(Map.class);

        verify(servicioPush, times(1)).enviarAUsuario(
                usuarioIdCaptor.capture(),
                tituloCaptor.capture(),
                cuerpoCaptor.capture(),
                datosCaptor.capture()
        );

        assertEquals((long) usuarioPaciente.getId(), usuarioIdCaptor.getValue());
        assertEquals("Tu turno está confirmado", tituloCaptor.getValue());
        assertEquals("Te esperamos", cuerpoCaptor.getValue());

        Map<String, String> datos = datosCaptor.getValue();
        assertEquals("TURNO_CONFIRMADO", datos.get("tipo"));
        assertEquals(String.valueOf(turno.getId()), datos.get("turnoId"));
        assertEquals(String.valueOf(notif.getId()), datos.get("notificacionId"));
    }

    @Test
    void testExcepcionEnServicioPushNoImpideGuardarNotificacion() {
        doThrow(new RuntimeException("Error simulado en push"))
                .when(servicioPush).enviarAUsuario(anyLong(), anyString(), anyString(), anyMap());

        assertDoesNotThrow(() ->
                notificacionService.crearParaPaciente(turno, "TURNO_CONFIRMADO", "Tu turno está confirmado", "Te esperamos")
        );

        List<Notificacion> guardadas = notificacionRepository.findAll();
        assertEquals(1, guardadas.size());
        assertEquals("TURNO_CONFIRMADO", guardadas.get(0).getTipo());
    }
}
