package com.mediturnos.repository;

import com.mediturnos.model.ActivacionCuenta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ActivacionCuentaRepository extends JpaRepository<ActivacionCuenta, Integer> {
    Optional<ActivacionCuenta> findFirstByUsuarioIdAndUsadoFalseOrderByFechaCreacionDesc(Integer usuarioId);
    List<ActivacionCuenta> findByUsuarioIdAndUsadoFalse(Integer usuarioId);
}
