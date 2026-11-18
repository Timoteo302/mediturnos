import '../modelos/medico.dart';
import '../modelos/especialidad.dart';
import '../modelos/horarioAtencion.dart';
import '../modelos/excepcionMedicos.dart';
import '../fuentes/almacenMedicosLocal.dart';
import 'repositorioMedicos.dart';

class RepositorioMedicosOfflineFirst implements RepositorioMedicos {
  final RepositorioMedicos remoto;
  final AlmacenMedicosLocal local;

  RepositorioMedicosOfflineFirst({required this.remoto, required this.local});

  @override
  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false}) async {
    try {
      final medicos = await remoto.obtenerMedicos(
        incluirInactivos: incluirInactivos,
      );
      await local.guardarMedicos(medicos);

      // Descarga y guarda en SQLite los horarios de todos los médicos
      for (final medico in medicos) {
        try {
          final horarios = await remoto.obtenerHorarios(medico.id);
          await local.guardarHorarios(medico.id, horarios);
        } catch (_) {}
      }

      return local.obtenerMedicos(incluirInactivos: incluirInactivos);
    } on ExcepcionMedicos catch (e) {
      if (e.tipo == ErrorMedicos.sinConexion) {
        return local.obtenerMedicos(incluirInactivos: incluirInactivos);
      }
      rethrow;
    }
  }

  @override
  Future<Medico> crearMedico({
    required String nombre,
    required String apellido,
    required int especialidadId,
    required String matricula,
    required bool activo,
  }) async {
    final creado = await remoto.crearMedico(
      nombre: nombre,
      apellido: apellido,
      especialidadId: especialidadId,
      matricula: matricula,
      activo: activo,
    );
    await local.guardarMedicoLocal(creado, sincronizado: true);
    return creado;
  }

  @override
  Future<Medico> actualizarMedico(
    int id, {
    required String nombre,
    required String apellido,
    required int especialidadId,
    required String matricula,
    required bool activo,
  }) async {
    final actualizado = await remoto.actualizarMedico(
      id,
      nombre: nombre,
      apellido: apellido,
      especialidadId: especialidadId,
      matricula: matricula,
      activo: activo,
    );
    await local.guardarMedicoLocal(actualizado, sincronizado: true);
    return actualizado;
  }

  @override
  Future<Medico> cambiarEstadoMedico(int id, bool activo) async {
    final actualizado = await remoto.cambiarEstadoMedico(id, activo);
    await local.guardarMedicoLocal(actualizado, sincronizado: true);
    return actualizado;
  }

  @override
  Future<List<Especialidad>> obtenerEspecialidades({
    bool incluirInactivas = false,
  }) async {
    try {
      final especialidades = await remoto.obtenerEspecialidades(
        incluirInactivas: incluirInactivas,
      );
      await local.guardarEspecialidades(especialidades);
      return especialidades;
    } on ExcepcionMedicos catch (e) {
      if (e.tipo == ErrorMedicos.sinConexion) {
        return local.obtenerEspecialidades(incluirInactivas: incluirInactivas);
      }
      rethrow;
    }
  }

  @override
  Future<Especialidad> crearEspecialidad({
    required String nombre,
    String? descripcion,
  }) async {
    final creada = await remoto.crearEspecialidad(
      nombre: nombre,
      descripcion: descripcion,
    );
    final actuales = await local.obtenerEspecialidades(incluirInactivas: true);
    await local.guardarEspecialidades([...actuales, creada]);
    return creada;
  }

  @override
  Future<Especialidad> actualizarEspecialidad(
    int id, {
    required String nombre,
    String? descripcion,
  }) async {
    final actualizada = await remoto.actualizarEspecialidad(
      id,
      nombre: nombre,
      descripcion: descripcion,
    );
    final actuales = await local.obtenerEspecialidades(incluirInactivas: true);
    final actualizadas = actuales
        .map((e) => e.id == id ? actualizada : e)
        .toList();
    await local.guardarEspecialidades(actualizadas);
    return actualizada;
  }

  @override
  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo) async {
    final actualizada = await remoto.cambiarEstadoEspecialidad(id, activo);
    final actuales = await local.obtenerEspecialidades(incluirInactivas: true);
    final actualizadas = actuales
        .map((e) => e.id == id ? actualizada : e)
        .toList();
    await local.guardarEspecialidades(actualizadas);
    return actualizada;
  }

  @override
  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) async {
    try {
      final horarios = await remoto.obtenerHorarios(medicoId);
      await local.guardarHorarios(medicoId, horarios);
      return horarios;
    } on ExcepcionMedicos catch (e) {
      if (e.tipo == ErrorMedicos.sinConexion) {
        return local.obtenerHorarios(medicoId);
      }
      rethrow;
    }
  }

  @override
  Future<List<HorarioAtencion>> guardarHorarios(
    int medicoId,
    List<HorarioAtencion> horarios,
  ) async {
    final guardados = await remoto.guardarHorarios(medicoId, horarios);
    await local.guardarHorarios(medicoId, guardados);
    return guardados;
  }
}
