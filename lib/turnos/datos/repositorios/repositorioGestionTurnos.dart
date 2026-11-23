import '../modelos/turnoDetalle.dart';
import '../modelos/horarioDisponible.dart';
import '../modelos/estadoTurno.dart';

// Definimos la interfaz del repositorio de turnos permitiendo origen y respuesta de asistencia.
abstract class RepositorioGestionTurnos {
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado});
  Future<TurnoDetalle> obtenerTurno(int id);
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha});
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud});
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora});
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado, String? origen});
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira});
  Future<void> eliminarTurnoLocal(int id);
}
