package com.mediturnos.controller;

import com.mediturnos.dto.*;
import com.mediturnos.service.HorarioAtencionService;
import com.mediturnos.service.MedicoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la administración de médicos y sus horarios de atención.
 */
@RestController
@RequestMapping("/medicos")
@CrossOrigin(origins = "*")
public class MedicoController {

    @Autowired
    private MedicoService medicoService;

    @Autowired
    private HorarioAtencionService horarioAtencionService;

    /*
     * Endpoint GET /medicos
     * Mantiene compatibilidad actual (solo activos por defecto, filtra por especialidadId si se especifica)
     * y soporta el parámetro opcional incluirInactivos=true para incluir médicos inactivos.
     */
    @GetMapping
    public List<MedicoRespuesta> listar(
            @RequestParam(required = false) Integer especialidadId,
            @RequestParam(required = false) Boolean incluirInactivos) {
        return medicoService.listar(especialidadId, incluirInactivos);
    }

    /*
     * Endpoint GET /medicos/{id}
     * Retorna el detalle de un médico por su ID.
     */
    @GetMapping("/{id}")
    public MedicoRespuesta obtenerPorId(@PathVariable Integer id) {
        return medicoService.obtenerPorId(id);
    }

    /*
     * Endpoint POST /medicos
     * Registra un nuevo médico (retorna 201 Created).
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MedicoRespuesta crear(@RequestBody MedicoSolicitud solicitud) {
        return medicoService.crear(solicitud);
    }

    /*
     * Endpoint PUT /medicos/{id}
     * Modifica la información de un médico existente.
     */
    @PutMapping("/{id}")
    public MedicoRespuesta actualizar(@PathVariable Integer id, @RequestBody MedicoSolicitud solicitud) {
        return medicoService.actualizar(id, solicitud);
    }

    /**
     * Endpoint PATCH /medicos/{id}/estado
     * Modifica el estado de activación (activo/inactivo) de un médico.
     */
    @PatchMapping("/{id}/estado")
    public MedicoRespuesta cambiarEstado(@PathVariable Integer id, @RequestBody EstadoSolicitud solicitud) {
        return medicoService.cambiarEstado(id, solicitud);
    }

    /**
     * Endpoint GET /medicos/{id}/horarios
     * Retorna la lista de horarios de atención activos del médico.
     */
    @GetMapping("/{id}/horarios")
    public List<HorarioRespuesta> obtenerHorarios(@PathVariable Integer id) {
        return horarioAtencionService.obtenerHorariosPorMedico(id);
    }

    /**
     * Endpoint PUT /medicos/{id}/horarios
     * Reemplaza atómicamente la agenda de atención del médico.
     */
    @PutMapping("/{id}/horarios")
    public List<HorarioRespuesta> reemplazarAgenda(@PathVariable Integer id, @RequestBody AgendaSolicitud solicitud) {
        return horarioAtencionService.reemplazarAgenda(id, solicitud);
    }
}
