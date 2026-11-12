package com.mediturnos.repository;

import com.mediturnos.model.Medico;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio Spring Data JPA para la entidad Medico.
 */
public interface MedicoRepository extends JpaRepository<Medico, Integer> {
    // Busca médicos con estado activo = true
    List<Medico> findByActivoTrue();

    // Busca médicos activos asociados a una especialidad determinada
    List<Medico> findByEspecialidadIdAndActivoTrue(Integer especialidadId);

    // Busca todos los médicos (activos e inactivos) de una especialidad dada
    List<Medico> findByEspecialidadId(Integer especialidadId);

    // Verifica si existen médicos activos vinculados a una especialidad dada
    boolean existsByEspecialidadIdAndActivoTrue(Integer especialidadId);

    // Verifica la existencia de una matrícula profesional
    boolean existsByMatricula(String matricula);

    // Verifica la existencia de una matrícula profesional excluyendo un médico por su ID
    boolean existsByMatriculaAndIdNot(String matricula, Integer id);

    // Busca un médico por su matrícula profesional
    Optional<Medico> findByMatricula(String matricula);
}
