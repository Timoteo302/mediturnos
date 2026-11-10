package com.mediturnos.service;

import com.mediturnos.model.Turno;
import com.mediturnos.repository.TurnoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class TurnoService {

    @Autowired
    private TurnoRepository turnoRepository;

    public List<Turno> listarTodos() {
        return turnoRepository.findAll();
    }

    public List<Turno> listarPorPaciente(Integer pacienteId) {
        return turnoRepository.findByPacienteId(pacienteId);
    }

    public Turno guardar(Turno turno) {
        // Si viene sin claveSolicitud, le generamos un UUID
        if (turno.getClaveSolicitud() == null || turno.getClaveSolicitud().isEmpty()) {
            turno.setClaveSolicitud(UUID.randomUUID().toString());
        } else {
            // Si ya existe en la BD (reintento offline), devolvemos el existente sin duplicar
            Optional<Turno> existente = turnoRepository.findByClaveSolicitud(turno.getClaveSolicitud());
            if (existente.isPresent()) {
                return existente.get();
            }
        }
        return turnoRepository.save(turno);
    }

    public Turno actualizar(Integer id, Turno turnoActualizado) {
        Turno turno = turnoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Turno no encontrado"));

        turno.setFecha(turnoActualizado.getFecha());
        turno.setHora(turnoActualizado.getHora());
        turno.setEstado(turnoActualizado.getEstado());

        return turnoRepository.save(turno);
    }

    public void eliminar(Integer id) {
        turnoRepository.deleteById(id);
    }
}