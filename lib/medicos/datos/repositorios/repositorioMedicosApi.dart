import '../modelos/medico.dart';
import '../modelos/especialidad.dart';
import '../modelos/horarioAtencion.dart';
import '../fuentes/clienteMedicosApi.dart';
import 'repositorioMedicos.dart';

class RepositorioMedicosApi implements RepositorioMedicos {
  final ClienteMedicosApi clienteApi;

  RepositorioMedicosApi(this.clienteApi);

  @override
  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false}) {
    return clienteApi.obtenerMedicos(incluirInactivos: incluirInactivos);
  }

  @override
  Future<Medico> crearMedico({
    required String nombre,
    required String apellido,
    required int especialidadId,
    required String matricula,
    required bool activo,
  }) {
    return clienteApi.crearMedico(
      nombre: nombre,
      apellido: apellido,
      especialidadId: especialidadId,
      matricula: matricula,
      activo: activo,
    );
  }

  @override
  Future<Medico> actualizarMedico(
    int id, {
    required String nombre,
    required String apellido,
    required int especialidadId,
    required String matricula,
    required bool activo,
  }) {
    return clienteApi.actualizarMedico(
      id,
      nombre: nombre,
      apellido: apellido,
      especialidadId: especialidadId,
      matricula: matricula,
      activo: activo,
    );
  }

  @override
  Future<Medico> cambiarEstadoMedico(int id, bool activo) {
    return clienteApi.cambiarEstadoMedico(id, activo);
  }

  @override
  Future<List<Especialidad>> obtenerEspecialidades({bool incluirInactivas = false}) {
    return clienteApi.obtenerEspecialidades(incluirInactivas: incluirInactivas);
  }

  @override
  Future<Especialidad> crearEspecialidad({required String nombre, String? descripcion}) {
    return clienteApi.crearEspecialidad(nombre: nombre, descripcion: descripcion);
  }

  @override
  Future<Especialidad> actualizarEspecialidad(int id, {required String nombre, String? descripcion}) {
    return clienteApi.actualizarEspecialidad(id, nombre: nombre, descripcion: descripcion);
  }

  @override
  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo) {
    return clienteApi.cambiarEstadoEspecialidad(id, activo);
  }

  @override
  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) {
    return clienteApi.obtenerHorarios(medicoId);
  }

  @override
  Future<List<HorarioAtencion>> guardarHorarios(int medicoId, List<HorarioAtencion> horarios) {
    return clienteApi.guardarHorarios(medicoId, horarios);
  }
}
