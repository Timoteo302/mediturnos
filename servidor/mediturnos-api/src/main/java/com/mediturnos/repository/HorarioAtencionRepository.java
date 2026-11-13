package com.mediturnos.repository;

import com.mediturnos.model.HorarioAtencion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

/**
 * Repositorio Spring Data JPA para los horarios de atención médica.
 */
public interface HorarioAtencionRepository extends JpaRepository<HorarioAtencion, Integer> {
    // Busca los horarios activos de un médico ordenados por día y hora de inicio
    List<HorarioAtencion> findByMedicoIdAndActivoTrueOrderByDiaSemanaAscHoraInicioAsc(Integer medicoId);

    // Busca los horarios de atención activos de un médico para un día de la semana específico
    List<HorarioAtencion> findByMedicoIdAndDiaSemanaAndActivoTrueOrderByHoraInicioAsc(Integer medicoId, Integer diaSemana);

    // Elimina de forma masiva todos los horarios (activos e inactivos) pertenecientes a un médico
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("DELETE FROM HorarioAtencion h WHERE h.medico.id = :medicoId")
    void deleteByMedicoId(@Param("medicoId") Integer medicoId);
}
