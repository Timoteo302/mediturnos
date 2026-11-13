package com.mediturnos.repository;

import com.mediturnos.model.Turno;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio Spring Data JPA para la entidad Turno.
 */
public interface TurnoRepository extends JpaRepository<Turno, Integer> {

    // Búsqueda por id de paciente
    List<Turno> findByPacienteId(Integer pacienteId);

    // Búsqueda por id de médico
    List<Turno> findByMedicoId(Integer medicoId);

    // Búsqueda por clave de solicitud para garantizar idempotencia
    Optional<Turno> findByClaveSolicitud(String claveSolicitud);

    // Búsqueda flexible con filtros opcionales (paciente, médico, fecha, estado) ordenada por fecha y hora ascendente
    @Query("SELECT t FROM Turno t WHERE " +
           "(:pacienteId IS NULL OR t.paciente.id = :pacienteId) AND " +
           "(:medicoId IS NULL OR t.medico.id = :medicoId) AND " +
           "(:fecha IS NULL OR t.fecha = :fecha) AND " +
           "(:estado IS NULL OR t.estado = :estado) " +
           "ORDER BY t.fecha ASC, t.hora ASC")
    List<Turno> buscarConFiltros(
            @Param("pacienteId") Integer pacienteId,
            @Param("medicoId") Integer medicoId,
            @Param("fecha") LocalDate fecha,
            @Param("estado") String estado);

    // Obtiene los turnos no cancelados de un médico para una fecha específica
    List<Turno> findByMedicoIdAndFechaAndEstadoNot(Integer medicoId, LocalDate fecha, String estadoExcluido);

    // Verifica si existe un turno no cancelado para un médico en una fecha y hora determinadas
    boolean existsByMedicoIdAndFechaAndHoraAndEstadoNot(Integer medicoId, LocalDate fecha, LocalTime hora, String estadoExcluido);

    // Verifica si existe un turno no cancelado para un médico en una fecha y hora excluyendo un turno por ID
    boolean existsByMedicoIdAndFechaAndHoraAndEstadoNotAndIdNot(Integer medicoId, LocalDate fecha, LocalTime hora, String estadoExcluido, Integer idExcluir);
}
