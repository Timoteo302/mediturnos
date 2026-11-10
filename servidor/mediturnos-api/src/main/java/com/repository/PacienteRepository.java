package com.mediturnos.repository;

import com.mediturnos.model.Paciente;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface PacienteRepository extends JpaRepository<Paciente, Integer> {
    Optional<Paciente> findByUsuarioId(Integer usuarioId);
    boolean existsByDni(String dni);
}