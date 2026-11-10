package com.mediturnos.controller;

import com.mediturnos.model.Medico;
import com.mediturnos.service.MedicoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/medicos")
@CrossOrigin(origins = "*")
public class MedicoController {

    @Autowired
    private MedicoService medicoService;

    @GetMapping
    public List<Medico> listar(@RequestParam(required = false) Integer especialidadId) {
        if (especialidadId != null) {
            return medicoService.listarPorEspecialidad(especialidadId);
        }
        return medicoService.listarActivos();
    }

    @PostMapping
    public Medico crear(@RequestBody Medico medico) {
        return medicoService.guardar(medico);
    }
}