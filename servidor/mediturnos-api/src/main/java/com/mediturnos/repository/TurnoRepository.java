package com.mediturnos.repository;

import com.mediturnos.model.Turno;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface TurnoRepository extends JpaRepository<Turno, Integer> {
    List<Turno> findByPacienteId(Integer pacienteId);
    List<Turno> findByMedicoId(Integer medicoId);
    Optional<Turno> findByClaveSolicitud(String claveSolicitud);
}