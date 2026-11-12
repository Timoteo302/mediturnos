package com.mediturnos.controller;

import com.mediturnos.dto.EspecialidadRespuesta;
import com.mediturnos.dto.EspecialidadSolicitud;
import com.mediturnos.dto.EstadoSolicitud;
import com.mediturnos.service.EspecialidadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión de especialidades médicas.
 */
@RestController
@RequestMapping("/especialidades")
@CrossOrigin(origins = "*")
public class EspecialidadController {

    @Autowired
    private EspecialidadService especialidadService;

    /**
     * Endpoint GET /especialidades
     * Retorna la lista de especialidades activas (o todas si incluirInactivas=true) ordenadas por nombre.
     */
    @GetMapping
    public List<EspecialidadRespuesta> listar(@RequestParam(required = false) Boolean incluirInactivas) {
        return especialidadService.listar(incluirInactivas);
    }

    /**
     * Endpoint POST /especialidades
     * Crea una nueva especialidad (retorna 201 Created).
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EspecialidadRespuesta crear(@RequestBody EspecialidadSolicitud solicitud) {
        return especialidadService.crear(solicitud);
    }

    /**
     * Endpoint PUT /especialidades/{id}
     * Actualiza el nombre y descripción de una especialidad existente.
     */
    @PutMapping("/{id}")
    public EspecialidadRespuesta actualizar(@PathVariable Integer id, @RequestBody EspecialidadSolicitud solicitud) {
        return especialidadService.actualizar(id, solicitud);
    }

    /**
     * Endpoint PATCH /especialidades/{id}/estado
     * Cambia el estado de activación de una especialidad.
     */
    @PatchMapping("/{id}/estado")
    public EspecialidadRespuesta cambiarEstado(@PathVariable Integer id, @RequestBody EstadoSolicitud solicitud) {
        return especialidadService.cambiarEstado(id, solicitud);
    }
}
