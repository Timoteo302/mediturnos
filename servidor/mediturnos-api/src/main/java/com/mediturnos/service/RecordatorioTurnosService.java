package com.mediturnos.service;

import com.mediturnos.model.Turno;
import com.mediturnos.repository.TurnoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@ConditionalOnProperty(name = "mediturnos.recordatorios.habilitados", havingValue = "true", matchIfMissing = true)
public class RecordatorioTurnosService {

    private static final Logger logger = LoggerFactory.getLogger(RecordatorioTurnosService.class);
    private static final ZoneId ZONA_BUENOS_AIRES = ZoneId.of("America/Argentina/Buenos_Aires");
    private static final DateTimeFormatter FORMATO_HORA = DateTimeFormatter.ofPattern("HH:mm");

    @Autowired
    private TurnoRepository turnoRepository;

    @Autowired
    private NotificacionService notificacionService;

    @Scheduled(fixedDelay = 600000)
    public void procesarRecordatorios() {
        procesarAhora();
    }

    public void procesarAhora() {
        LocalDate fechaHoy = LocalDate.now(ZONA_BUENOS_AIRES);
        LocalTime horaHoy = LocalTime.now(ZONA_BUENOS_AIRES);
        LocalDate fechaManana = fechaHoy.plusDays(1);

        List<Turno> turnos = turnoRepository.findTurnosParaRecordatorio(fechaHoy, horaHoy, fechaManana);
        logger.info("Procesando recordatorios para {} turnos.", turnos.size());

        for (Turno turno : turnos) {
            try {
                enviarRecordatorio(turno);
            } catch (Exception e) {
                logger.error("Error al enviar recordatorio para el turno {}: {}", turno.getId(), e.getMessage());
            }
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void enviarRecordatorio(Turno turno) {
        if (Boolean.TRUE.equals(turno.getRecordatorioEnviado())) {
            return;
        }
        
        String msg = String.format("Tenés turno con %s el %02d/%02d a las %s. Confirmanos si vas a asistir.",
                turno.getMedico().getNombre() + " " + turno.getMedico().getApellido(),
                turno.getFecha().getDayOfMonth(), turno.getFecha().getMonthValue(),
                turno.getHora().format(FORMATO_HORA));

        notificacionService.crearParaPaciente(turno, "RECORDATORIO_ASISTENCIA", "¿Vas a asistir?", msg);
        turno.setRecordatorioEnviado(true);
        turnoRepository.save(turno);
        
        logger.info("Recordatorio enviado exitosamente para el turno {}", turno.getId());
    }
}
