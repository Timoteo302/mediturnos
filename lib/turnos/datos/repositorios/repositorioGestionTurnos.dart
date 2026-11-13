import '../modelos/turnoDetalle.dart';
import '../modelos/horarioDisponible.dart';
import '../modelos/estadoTurno.dart';

/// Contrato abstracto para la gestión de turnos médicos en el repositorio.
abstract class RepositorioGestionTurnos {
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado});
  Future<TurnoDetalle> obtenerTurno(int id);
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha});
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud});
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora});
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado});
}
