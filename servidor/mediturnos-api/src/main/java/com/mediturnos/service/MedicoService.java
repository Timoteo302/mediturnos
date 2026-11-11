package com.mediturnos.service;

import com.mediturnos.model.Medico;
import com.mediturnos.repository.MedicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicoService {

    @Autowired
    private MedicoRepository medicoRepository;

    public List<Medico> listarActivos() {
        return medicoRepository.findByActivoTrue();
    }

    public List<Medico> listarPorEspecialidad(Integer especialidadId) {
        return medicoRepository.findByEspecialidadIdAndActivoTrue(especialidadId);
    }

    public Medico guardar(Medico medico) {
        return medicoRepository.save(medico);
    }
}