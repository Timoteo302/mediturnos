package com.mediturnos.repository;

import com.mediturnos.model.Especialidad;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/**
 * Repositorio Spring Data JPA para la entidad Especialidad.
 */
public interface EspecialidadRepository extends JpaRepository<Especialidad, Integer> {
    // Obtiene especialidades activas
    List<Especialidad> findByActivoTrue();

    // Obtiene especialidades activas ordenadas por nombre
    List<Especialidad> findByActivoTrueOrderByNombreAsc();

    // Obtiene todas las especialidades ordenadas por nombre
    List<Especialidad> findAllByOrderByNombreAsc();
}
