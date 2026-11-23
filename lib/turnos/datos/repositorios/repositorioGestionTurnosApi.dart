import '../modelos/turnoDetalle.dart';
import '../modelos/horarioDisponible.dart';
import '../modelos/estadoTurno.dart';
import '../fuentes/clienteTurnosApi.dart';
import 'repositorioGestionTurnos.dart';

// Implementación directa que delega las operaciones al cliente HTTP de la API de turnos.
class RepositorioGestionTurnosApi implements RepositorioGestionTurnos {
  final ClienteTurnosApi clienteApi;

  RepositorioGestionTurnosApi(this.clienteApi);

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) {
    return clienteApi.obtenerTurnos(pacienteId: pacienteId, medicoId: medicoId, fecha: fecha, estado: estado);
  }

  @override
  Future<TurnoDetalle> obtenerTurno(int id) {
    return clienteApi.obtenerTurno(id);
  }

  @override
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha}) {
    return clienteApi.obtenerDisponibilidad(medicoId: medicoId, fecha: fecha);
  }

  @override
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud}) {
    return clienteApi.solicitarTurno(pacienteId: pacienteId, medicoId: medicoId, fecha: fecha, hora: hora, claveSolicitud: claveSolicitud);
  }

  @override
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora}) {
    return clienteApi.reprogramarTurno(turnoId: turnoId, fecha: fecha, hora: hora);
  }

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado, String? origen}) {
    return clienteApi.cambiarEstadoTurno(turnoId: turnoId, estado: estado, origen: origen);
  }

  @override
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira}) {
    return clienteApi.responderAsistencia(turnoId: turnoId, asistira: asistira);
  }

  @override
  Future<void> eliminarTurnoLocal(int id) async {
    // Operación no aplicable para acceso directo a API remota
  }
}
