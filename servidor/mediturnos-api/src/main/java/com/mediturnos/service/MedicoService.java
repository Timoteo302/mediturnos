package com.mediturnos.service;

import com.mediturnos.dto.EspecialidadResumen;
import com.mediturnos.dto.EstadoSolicitud;
import com.mediturnos.dto.MedicoRespuesta;
import com.mediturnos.dto.MedicoSolicitud;
import com.mediturnos.exception.ExcepcionApi;
import com.mediturnos.model.Especialidad;
import com.mediturnos.model.Medico;
import com.mediturnos.repository.EspecialidadRepository;
import com.mediturnos.repository.MedicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Servicio para gestionar la lógica de negocio de los médicos.
 */
@Service
public class MedicoService {

    @Autowired
    private MedicoRepository medicoRepository;

    @Autowired
    private EspecialidadRepository especialidadRepository;

    // Patrón para validar matrícula: únicamente dígitos entre 3 y 10 caracteres
    private static final Pattern PATRON_MATRICULA = Pattern.compile("^\\d{3,10}$");

    /**
     * Lista médicos aplicando filtros por especialidad y estado de actividad.
     * @param especialidadId ID opcional de especialidad para filtrar.
     * @param incluirInactivos si es true incluye activos e inactivos; si es false devuelve solo activos.
     * @return Lista de MedicoRespuesta.
     */
    @Transactional(readOnly = true)
    public List<MedicoRespuesta> listar(Integer especialidadId, Boolean incluirInactivos) {
        List<Medico> medicos;
        if (Boolean.TRUE.equals(incluirInactivos)) {
            if (especialidadId != null) {
                medicos = medicoRepository.findByEspecialidadId(especialidadId);
            } else {
                medicos = medicoRepository.findAll();
            }
        } else {
            if (especialidadId != null) {
                medicos = medicoRepository.findByEspecialidadIdAndActivoTrue(especialidadId);
            } else {
                medicos = medicoRepository.findByActivoTrue();
            }
        }
        return medicos.stream()
                .map(this::convertirADto)
                .collect(Collectors.toList());
    }

    /**
     * Mantiene compatibilidad con la firma previa del método para listar médicos activos.
     */
    @Transactional(readOnly = true)
    public List<Medico> listarActivos() {
        return medicoRepository.findByActivoTrue();
    }

    /**
     * Mantiene compatibilidad con la firma previa del método para listar por especialidad.
     */
    @Transactional(readOnly = true)
    public List<Medico> listarPorEspecialidad(Integer especialidadId) {
        return medicoRepository.findByEspecialidadIdAndActivoTrue(especialidadId);
    }

    /**
     * Busca un médico por su identificador único.
     * @param id Identificador del médico.
     * @return MedicoRespuesta encontrada.
     */
    @Transactional(readOnly = true)
    public MedicoRespuesta obtenerPorId(Integer id) {
        Medico medico = medicoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado."));
        return convertirADto(medico);
    }

    /**
     * Crea un nuevo médico en el sistema.
     * @param solicitud DTO con los datos del nuevo médico.
     * @return MedicoRespuesta del médico creado.
     */
    @Transactional
    public MedicoRespuesta crear(MedicoSolicitud solicitud) {
        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La solicitud no puede ser nula.", "nombre");
        }

        // Normalizar strings
        String nombre = solicitud.getNombre() != null ? solicitud.getNombre().trim() : null;
        String apellido = solicitud.getApellido() != null ? solicitud.getApellido().trim() : null;
        String matricula = solicitud.getMatricula() != null ? solicitud.getMatricula().trim() : null;

        // Validaciones de nombre y apellido
        if (nombre == null || nombre.length() < 2 || nombre.length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre es obligatorio y debe tener entre 2 y 100 caracteres.", "nombre");
        }
        if (apellido == null || apellido.length() < 2 || apellido.length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El apellido es obligatorio y debe tener entre 2 y 100 caracteres.", "apellido");
        }

        // Validación de matrícula
        if (matricula == null || !PATRON_MATRICULA.matcher(matricula).matches()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La matrícula debe contener entre 3 y 10 dígitos numéricos.", "matricula");
        }
        if (medicoRepository.existsByMatricula(matricula)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "MATRICULA_DUPLICADA", "La matrícula ingresada ya existe en el sistema.", "matricula");
        }

        // Validación de especialidadId (debe existir y estar activa)
        if (solicitud.getEspecialidadId() == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La especialidad es obligatoria.", "especialidadId");
        }
        Especialidad especialidad = especialidadRepository.findById(solicitud.getEspecialidadId())
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La especialidad especificada no existe.", "especialidadId"));
        if (!Boolean.TRUE.equals(especialidad.getActivo())) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La especialidad seleccionada está inactiva.", "especialidadId");
        }

        // Estado activo opcional en POST (default true)
        Boolean activo = solicitud.getActivo() != null ? solicitud.getActivo() : true;

        Medico medico = new Medico();
        medico.setNombre(nombre);
        medico.setApellido(apellido);
        medico.setMatricula(matricula);
        medico.setEspecialidad(especialidad);
        medico.setActivo(activo);

        try {
            Medico guardado = medicoRepository.save(medico);
            return convertirADto(guardado);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "MATRICULA_DUPLICADA", "La matrícula ingresada ya existe en el sistema.", "matricula");
        }
    }

    /**
     * Mantiene compatibilidad con el método guardar anterior.
     */
    @Transactional
    public Medico guardar(Medico medico) {
        return medicoRepository.save(medico);
    }

    /**
     * Actualiza la información de un médico existente.
     * @param id Identificador del médico.
     * @param solicitud DTO con los datos a actualizar.
     * @return MedicoRespuesta con la información actualizada.
     */
    @Transactional
    public MedicoRespuesta actualizar(Integer id, MedicoSolicitud solicitud) {
        Medico medico = medicoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado."));

        if (solicitud == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La solicitud no puede ser nula.", "nombre");
        }

        // Normalizar strings
        String nombre = solicitud.getNombre() != null ? solicitud.getNombre().trim() : null;
        String apellido = solicitud.getApellido() != null ? solicitud.getApellido().trim() : null;
        String matricula = solicitud.getMatricula() != null ? solicitud.getMatricula().trim() : null;

        // Validaciones
        if (nombre == null || nombre.length() < 2 || nombre.length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El nombre es obligatorio y debe tener entre 2 y 100 caracteres.", "nombre");
        }
        if (apellido == null || apellido.length() < 2 || apellido.length() > 100) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El apellido es obligatorio y debe tener entre 2 y 100 caracteres.", "apellido");
        }

        if (matricula == null || !PATRON_MATRICULA.matcher(matricula).matches()) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La matrícula debe contener entre 3 y 10 dígitos numéricos.", "matricula");
        }
        if (medicoRepository.existsByMatriculaAndIdNot(matricula, id)) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "MATRICULA_DUPLICADA", "La matrícula ingresada ya existe en el sistema.", "matricula");
        }

        // Validación del campo activo (obligatorio en PUT)
        if (solicitud.getActivo() == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El campo activo es obligatorio.", "activo");
        }

        // Validación de especialidadId
        if (solicitud.getEspecialidadId() == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La especialidad es obligatoria.", "especialidadId");
        }
        Especialidad especialidad = especialidadRepository.findById(solicitud.getEspecialidadId())
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La especialidad especificada no existe.", "especialidadId"));

        // En PUT, se permite conservar la misma especialidad del médico aunque esté inactiva; si se cambia, debe estar activa.
        boolean esMismaEspecialidad = especialidad.getId().equals(medico.getEspecialidad().getId());
        if (!esMismaEspecialidad && !Boolean.TRUE.equals(especialidad.getActivo())) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "La nueva especialidad seleccionada está inactiva.", "especialidadId");
        }

        medico.setNombre(nombre);
        medico.setApellido(apellido);
        medico.setMatricula(matricula);
        medico.setEspecialidad(especialidad);
        medico.setActivo(solicitud.getActivo());

        try {
            Medico guardado = medicoRepository.save(medico);
            return convertirADto(guardado);
        } catch (DataIntegrityViolationException ex) {
            throw new ExcepcionApi(HttpStatus.CONFLICT, "MATRICULA_DUPLICADA", "La matrícula ingresada ya existe en el sistema.", "matricula");
        }
    }

    /**
     * Activa o desactiva un médico.
     * @param id Identificador del médico.
     * @param solicitud DTO con el nuevo estado activo.
     * @return MedicoRespuesta modificado.
     */
    @Transactional
    public MedicoRespuesta cambiarEstado(Integer id, EstadoSolicitud solicitud) {
        if (solicitud == null || solicitud.getActivo() == null) {
            throw new ExcepcionApi(HttpStatus.BAD_REQUEST, "DATOS_INVALIDOS", "El campo activo es obligatorio.", "activo");
        }

        Medico medico = medicoRepository.findById(id)
                .orElseThrow(() -> new ExcepcionApi(HttpStatus.NOT_FOUND, "MEDICO_NO_ENCONTRADO", "Médico no encontrado."));

        medico.setActivo(solicitud.getActivo());
        Medico guardado = medicoRepository.save(medico);
        return convertirADto(guardado);
    }

    /**
     * Convierte la entidad Medico a su DTO de respuesta MedicoRespuesta.
     */
    public MedicoRespuesta convertirADto(Medico medico) {
        EspecialidadResumen espDto = null;
        if (medico.getEspecialidad() != null) {
            espDto = new EspecialidadResumen(medico.getEspecialidad().getId(), medico.getEspecialidad().getNombre());
        }
        return new MedicoRespuesta(
                medico.getId(),
                medico.getNombre(),
                medico.getApellido(),
                medico.getMatricula(),
                medico.getActivo(),
                espDto
        );
    }
}
