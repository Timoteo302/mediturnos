package com.mediturnos.repository;

import com.mediturnos.model.HorarioAtencion;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface HorarioAtencionRepository extends JpaRepository<HorarioAtencion, Integer> {
    List<HorarioAtencion> findByMedicoIdAndActivoTrue(Integer medicoId);
}