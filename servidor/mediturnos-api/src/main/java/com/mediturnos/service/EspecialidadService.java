package com.mediturnos.service;

import com.mediturnos.dto.EspecialidadRespuesta;
import com.mediturnos.dto.EspecialidadSolicitud;
import com.mediturnos.dto.EstadoSolicitud;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.Especialidad;
import com.mediturnos.repository.EspecialidadRepository;
import com.mediturnos.repository.MedicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio para gestionar la lógica de negocio de las especialidades médicas.
 */
@Service
public class EspecialidadService {

    @Autowired
    private EspecialidadRepository especialidadRepository;

    @Autowired
    private MedicoRepository medicoRepository;

    /**
     * Lista las especialidades registradas.
     * @param incluirInactivas si es true incluye especialidades activas e inactivas; de lo contrario solo activas.
     * @return Lista de EspecialidadRespuesta ordenadas por nombre.
     */
    @Transactional(readOnly = true)
    public List<EspecialidadRespuesta> listar(Boolean incluirInactivas) {
        List<Especialidad> lista;
        if (Boolean.TRUE.equals(incluirInactivas)) {
            lista = especialidadRepository.findAllByOrderByNombreAsc();
        } else {
            lista = especialidadRepository.findByActivoTrueOrderByNombreAsc();
        }
        return lista.stream()
                .map(this::convertirADto)
                .collect(Collectors.toList());
    }

    /**
     * Crea una nueva especialidad médica.
     * @param solicitud DTO con los datos de la especialidad.
     * @return EspecialidadRespuesta creada.
     */
    @Transactional
    public EspecialidadRespuesta crear(EspecialidadSolicitud solicitud) {
        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La solicitud no puede ser nula.", "nombre");
        }

        // Normalizar textos aplicando trim
        String nombre = solicitud.getNombre() != null ? solicitud.getNombre().trim() : null;
        String descripcion = solicitud.getDescripcion() != null ? solicitud.getDescripcion().trim() : null;
        if (descripcion != null && descripcion.isEmpty()) {
            descripcion = null;
        }

        // Validaciones del campo nombre
        if (nombre == null || nombre.length() < 2 || nombre.length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre de la especialidad debe tener entre 2 y 100 caracteres.", "nombre");
        }

        // Validaciones del campo descripcion
        if (descripcion != null && descripcion.length() > 255) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La descripción no puede superar los 255 caracteres.", "descripcion");
        }

        // Validar que el nombre no esté duplicado (insensible a mayúsculas y tildes)
        if (existeNombreDuplicado(nombre, null)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "ESPECIALIDAD_DUPLICADA", "Ya existe una especialidad con ese nombre.", "nombre");
        }

        Especialidad especialidad = new Especialidad();
        especialidad.setNombre(nombre);
        especialidad.setDescripcion(descripcion);
        especialidad.setActivo(true);

        try {
            Especialidad guardada = especialidadRepository.save(especialidad);
            return convertirADto(guardada);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "ESPECIALIDAD_DUPLICADA", "Ya existe una especialidad con ese nombre.", "nombre");
        }
    }

    /**
     * Actualiza una especialidad existente.
     * @param id Identificador de la especialidad.
     * @param solicitud DTO con los campos a actualizar.
     * @return EspecialidadRespuesta actualizada.
     */
    @Transactional
    public EspecialidadRespuesta actualizar(Integer id, EspecialidadSolicitud solicitud) {
        Especialidad especialidad = especialidadRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "ESPECIALIDAD_NO_ENCONTRADA", "Especialidad no encontrada."));

        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La solicitud no puede ser nula.", "nombre");
        }

        // Normalizar textos
        String nombre = solicitud.getNombre() != null ? solicitud.getNombre().trim() : null;
        String descripcion = solicitud.getDescripcion() != null ? solicitud.getDescripcion().trim() : null;
        if (descripcion != null && descripcion.isEmpty()) {
            descripcion = null;
        }

        // Validaciones
        if (nombre == null || nombre.length() < 2 || nombre.length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre de la especialidad debe tener entre 2 y 100 caracteres.", "nombre");
        }

        if (descripcion != null && descripcion.length() > 255) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La descripción no puede superar los 255 caracteres.", "descripcion");
        }

        // Validar nombre duplicado excluyendo la propia especialidad
        if (existeNombreDuplicado(nombre, id)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "ESPECIALIDAD_DUPLICADA", "Ya existe una especialidad con ese nombre.", "nombre");
        }

        especialidad.setNombre(nombre);
        especialidad.setDescripcion(descripcion);

        try {
            Especialidad guardada = especialidadRepository.save(especialidad);
            return convertirADto(guardada);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "ESPECIALIDAD_DUPLICADA", "Ya existe una especialidad con ese nombre.", "nombre");
        }
    }

    /**
     * Activa o desactiva una especialidad médica.
     * @param id Identificador de la especialidad.
     * @param solicitud DTO con el nuevo estado activo.
     * @return EspecialidadRespuesta modificada.
     */
    @Transactional
    public EspecialidadRespuesta cambiarEstado(Integer id, EstadoSolicitud solicitud) {
        if (solicitud == null || solicitud.getActivo() == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El estado activo es obligatorio.", "activo");
        }

        Especialidad especialidad = especialidadRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "ESPECIALIDAD_NO_ENCONTRADA", "Especialidad no encontrada."));

        // Al intentar desactivar, verificar que no tenga médicos activos asignados
        if (Boolean.FALSE.equals(solicitud.getActivo())) {
            boolean tieneMedicosActivos = medicoRepository.existsByEspecialidadIdAndActivoTrue(id);
            if (tieneMedicosActivos) {
                throw new ExcepcionApi(HttpStatus.CONFLICT, "ESPECIALIDAD_EN_USO", "No se puede desactivar la especialidad porque tiene médicos activos.");
            }
        }

        especialidad.setActivo(solicitud.getActivo());
        Especialidad guardada = especialidadRepository.save(especialidad);
        return convertirADto(guardada);
    }

    /**
     * Verifica si existe alguna especialidad con el mismo nombre normalizado.
     */
    private boolean existeNombreDuplicado(String nombre, Integer idExcluir) {
        String normalizado = normalizarTexto(nombre);
        return especialidadRepository.findAll().stream()
                .filter(e -> idExcluir == null || !e.getId().equals(idExcluir))
                .anyMatch(e -> normalizarTexto(e.getNombre()).equals(normalizado));
    }

    /**
     * Normaliza un texto eliminando tildes y convirtiéndolo a minúsculas.
     */
    private String normalizarTexto(String texto) {
        if (texto == null) return "";
        String nfd = Normalizer.normalize(texto, Normalizer.Form.NFD);
        return nfd.replaceAll("\\p{M}", "").toLowerCase();
    }

    /**
     * Convierte una entidad Especialidad a su DTO de salida EspecialidadRespuesta.
     */
    private EspecialidadRespuesta convertirADto(Especialidad especialidad) {
        return new EspecialidadRespuesta(
                especialidad.getId(),
                especialidad.getNombre(),
                especialidad.getDescripcion(),
                especialidad.getActivo()
        );
    }
}
