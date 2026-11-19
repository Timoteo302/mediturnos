package com.mediturnos.service;

import com.mediturnos.dto.NotificacionRespuesta;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.Notificacion;
import com.mediturnos.model.Turno;
import com.mediturnos.model.Usuario;
import com.mediturnos.repository.NotificacionRepository;
import com.mediturnos.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class NotificacionService {

    @Autowired
    private NotificacionRepository notificacionRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    private static final DateTimeFormatter FORMATO_HORA = DateTimeFormatter.ofPattern("HH:mm");

    /**
     * Crea una notificación para el paciente de un turno.
     */
    @Transactional
    public void crearParaPaciente(Turno turno, String tipo, String titulo, String mensaje) {
        if (turno == null || turno.getPaciente() == null || turno.getPaciente().getUsuario() == null) {
            return; // No se puede notificar sin usuario destino
        }
        crearNotificacion(turno.getPaciente().getUsuario(), turno, tipo, titulo, mensaje);
    }

    /**
     * Crea una notificación para todos los administradores activos.
     */
    @Transactional
    public void crearParaAdmins(Turno turno, String tipo, String titulo, String mensaje) {
        List<Usuario> admins = usuarioRepository.findByRolAndActivoTrue(Usuario.Rol.ADMIN);
        for (Usuario admin : admins) {
            crearNotificacion(admin, turno, tipo, titulo, mensaje);
        }
    }

    private void crearNotificacion(Usuario usuario, Turno turno, String tipo, String titulo, String mensaje) {
        Notificacion notif = new Notificacion();
        notif.setUsuario(usuario);
        notif.setTurno(turno);
        notif.setTipo(tipo);
        notif.setTitulo(titulo);
        notif.setMensaje(mensaje);
        notif.setLeida(false);
        notificacionRepository.save(notif);
    }

    /**
     * Lista las últimas 50 notificaciones de un usuario.
     */
    @Transactional(readOnly = true)
    public List<NotificacionRespuesta> listar(Integer usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "USUARIO_NO_ENCONTRADO", "El usuario no existe.");
        }
        return notificacionRepository.findTop50ByUsuarioIdOrderByFechaCreacionDesc(usuarioId)
                .stream().map(this::mapToRespuesta).toList();
    }

    /**
     * Cuenta cuántas notificaciones no leídas tiene un usuario.
     */
    @Transactional(readOnly = true)
    public long contarNoLeidas(Integer usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "USUARIO_NO_ENCONTRADO", "El usuario no existe.");
        }
        return notificacionRepository.countByUsuarioIdAndLeidaFalse(usuarioId);
    }

    /**
     * Marca una notificación específica como leída.
     */
    @Transactional
    public void marcarLeida(Integer notificacionId) {
        Notificacion notif = notificacionRepository.findById(notificacionId)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "NOTIFICACION_NO_ENCONTRADA", "Notificación no encontrada."));
        notif.setLeida(true);
        notificacionRepository.save(notif);
    }

    /**
     * Marca todas las notificaciones de un usuario como leídas.
     */
    @Transactional
    public void marcarTodasLeidas(Integer usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            throw new ExcepcionApi(HttpStatus.NOT_FOUND, "USUARIO_NO_ENCONTRADO", "El usuario no existe.");
        }
        List<Notificacion> noLeidas = notificacionRepository.findByUsuarioIdAndLeidaFalse(usuarioId);
        for (Notificacion notif : noLeidas) {
            notif.setLeida(true);
        }
        notificacionRepository.saveAll(noLeidas);
    }

    /**
     * Marca como leída la notificación RECORDATORIO_ASISTENCIA de un turno.
     */
    @Transactional
    public void marcarRecordatorioLeido(Integer turnoId) {
        notificacionRepository.findByTurnoIdAndTipo(turnoId, "RECORDATORIO_ASISTENCIA")
                .ifPresent(notif -> {
                    notif.setLeida(true);
                    notificacionRepository.save(notif);
                });
    }

    private NotificacionRespuesta mapToRespuesta(Notificacion notif) {
        Integer turnoId = null;
        String turnoFecha = null;
        String turnoHora = null;
        String turnoEstado = null;
        String respuestaPaciente = null;

        if (notif.getTurno() != null) {
            turnoId = notif.getTurno().getId();
            turnoFecha = notif.getTurno().getFecha() != null ? notif.getTurno().getFecha().toString() : null;
            turnoHora = notif.getTurno().getHora() != null ? notif.getTurno().getHora().format(FORMATO_HORA) : null;
            turnoEstado = notif.getTurno().getEstado();
            respuestaPaciente = notif.getTurno().getRespuestaPaciente();
        }

        return new NotificacionRespuesta(
                notif.getId(),
                notif.getTipo(),
                notif.getTitulo(),
                notif.getMensaje(),
                notif.getLeida(),
                notif.getFechaCreacion(),
                turnoId,
                turnoFecha,
                turnoHora,
                turnoEstado,
                respuestaPaciente
        );
    }
}
