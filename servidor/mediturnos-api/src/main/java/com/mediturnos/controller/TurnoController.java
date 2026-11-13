package com.mediturnos.controller;

import com.mediturnos.dto.*;
import com.mediturnos.service.TurnoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión de turnos médicos.
 */
@RestController
@RequestMapping("/turnos")
@CrossOrigin(origins = "*")
public class TurnoController {

    @Autowired
    private TurnoService turnoService;

    /**
     * Endpoint GET /turnos
     * Permite listar turnos con filtros opcionales (pacienteId, medicoId, fecha, estado).
     */
    @GetMapping
    public List<TurnoRespuesta> listar(
            @RequestParam(required = false) Integer pacienteId,
            @RequestParam(required = false) Integer medicoId,
            @RequestParam(required = false) String fecha,
            @RequestParam(required = false) String estado) {
        return turnoService.listarConFiltros(pacienteId, medicoId, fecha, estado);
    }

    /**
     * Endpoint GET /turnos/{id}
     * Retorna el detalle de un turno por su ID.
     */
    @GetMapping("/{id}")
    public TurnoRespuesta obtenerPorId(@PathVariable Integer id) {
        return turnoService.obtenerPorId(id);
    }

    /**
     * Endpoint POST /turnos
     * Crea un turno. Si la claveSolicitud ya existía, responde 200 OK con el existente (idempotencia offline).
     * De lo contrario, crea un turno nuevo y responde 201 Created.
     */
    @PostMapping
    public ResponseEntity<TurnoRespuesta> crear(@RequestBody TurnoCreacionSolicitud solicitud) {
        TurnoService.ResultadoCreacion resultado = turnoService.crear(solicitud);
        if (resultado.yaExistia()) {
            return ResponseEntity.ok(resultado.respuesta());
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(resultado.respuesta());
    }

    /**
     * Endpoint PUT /turnos/{id}
     * Reprograma la fecha y hora de un turno existente en estado PENDIENTE o CONFIRMADO.
     */
    @PutMapping("/{id}")
    public TurnoRespuesta reprogramar(@PathVariable Integer id, @RequestBody TurnoReprogramarSolicitud solicitud) {
        return turnoService.reprogramar(id, solicitud);
    }

    /**
     * Endpoint PATCH /turnos/{id}/estado
     * Modifica el estado de un turno siguiendo las reglas de la máquina de estados.
     */
    @PatchMapping("/{id}/estado")
    public TurnoRespuesta cambiarEstado(@PathVariable Integer id, @RequestBody TurnoEstadoSolicitud solicitud) {
        return turnoService.cambiarEstado(id, solicitud);
    }

    /**
     * Endpoint DELETE /turnos/{id}
     * Se mantiene exactamente igual para retrocompatibilidad.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        turnoService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
