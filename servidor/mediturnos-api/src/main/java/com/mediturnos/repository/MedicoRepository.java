package com.mediturnos.repository;

import com.mediturnos.model.Medico;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MedicoRepository extends JpaRepository<Medico, Integer> {
    List<Medico> findByActivoTrue();
    List<Medico> findByEspecialidadIdAndActivoTrue(Integer especialidadId);
}