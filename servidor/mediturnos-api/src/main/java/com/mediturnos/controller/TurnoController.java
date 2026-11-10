package com.mediturnos.controller;

import com.mediturnos.model.Turno;
import com.mediturnos.service.TurnoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController /*todo lo que devuelvan sus métodos se convierte automáticamente en JSON*/
@RequestMapping("/turnos")
@CrossOrigin(origins = "*")
public class TurnoController {

    @Autowired
    private TurnoService turnoService;

    @GetMapping
    public List<Turno> listar(@RequestParam(required = false) Integer pacienteId) {
        if (pacienteId != null) {
            return turnoService.listarPorPaciente(pacienteId);
        }
        return turnoService.listarTodos();
    }

    @PostMapping
    public ResponseEntity<Turno> crear(@RequestBody Turno turno) {
        Turno guardado = turnoService.guardar(turno);
        return ResponseEntity.status(HttpStatus.CREATED).body(guardado);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Turno> actualizar(@PathVariable Integer id, @RequestBody Turno turno) {
        return ResponseEntity.ok(turnoService.actualizar(id, turno));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        turnoService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}