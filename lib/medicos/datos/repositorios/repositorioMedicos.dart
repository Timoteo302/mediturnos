import '../modelos/medico.dart';
import '../modelos/especialidad.dart';
import '../modelos/horarioAtencion.dart';

abstract class RepositorioMedicos {
  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false});
  Future<Medico> crearMedico({required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo});
  Future<Medico> actualizarMedico(int id, {required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo});
  Future<Medico> cambiarEstadoMedico(int id, bool activo);
  Future<List<Especialidad>> obtenerEspecialidades({bool incluirInactivas = false});
  Future<Especialidad> crearEspecialidad({required String nombre, String? descripcion});
  Future<Especialidad> actualizarEspecialidad(int id, {required String nombre, String? descripcion});
  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo);
  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId);
  Future<List<HorarioAtencion>> guardarHorarios(int medicoId, List<HorarioAtencion> horarios);
}
