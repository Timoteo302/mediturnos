package com.mediturnos.repository;

import com.mediturnos.model.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NotificacionRepository extends JpaRepository<Notificacion, Integer> {
    List<Notificacion> findTop50ByUsuarioIdOrderByFechaCreacionDesc(Integer usuarioId);
    long countByUsuarioIdAndLeidaFalse(Integer usuarioId);
    List<Notificacion> findByUsuarioIdAndLeidaFalse(Integer usuarioId);
    Optional<Notificacion> findByTurnoIdAndTipo(Integer turnoId, String tipo);
}
