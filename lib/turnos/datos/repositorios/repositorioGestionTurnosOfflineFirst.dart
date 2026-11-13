import '../fuentes/clienteTurnosApi.dart';
import '../fuentes/local/almacenTurnosLocal.dart';
import '../modelos/turnoDetalle.dart';
import '../modelos/estadoTurno.dart';
import '../modelos/horarioDisponible.dart';
import '../modelos/excepcionTurnos.dart';
import 'repositorioGestionTurnos.dart';

class RepositorioGestionTurnosOfflineFirst implements RepositorioGestionTurnos {
  final ClienteTurnosApi _clienteApi;
  final AlmacenTurnosLocal _almacenLocal;

  RepositorioGestionTurnosOfflineFirst(this._clienteApi, this._almacenLocal);

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({
    int? pacienteId,
    int? medicoId,
    DateTime? fecha,
    EstadoTurno? estado,
  }) async {
    try {
      final turnos = await _clienteApi.obtenerTurnos(
        pacienteId: pacienteId,
        medicoId: medicoId,
        fecha: fecha,
        estado: estado,
      );

      await _almacenLocal.guardarTurnos(turnos);

      final turnosLocales = await _almacenLocal.obtenerTurnos(
        pacienteId: pacienteId,
      );

      final turnosRechazados = turnosLocales
          .where((turno) => turno.errorSincronizacion != null)
          .toList();

      final idsServidor = turnos.map((turno) => turno.id).toSet();

      return [
        ...turnos,
        ...turnosRechazados.where((turno) => !idsServidor.contains(turno.id)),
      ];
    } on ExcepcionTurnos catch (e) {
      if (e.tipo != ErrorTurnos.sinConexion) rethrow;

      return _almacenLocal.obtenerTurnos(pacienteId: pacienteId);
    }
  }

  @override
  Future<TurnoDetalle> obtenerTurno(int id) {
    return _clienteApi.obtenerTurno(id);
  }

  @override
  Future<List<HorarioDisponible>> obtenerDisponibilidad({
    required int medicoId,
    required DateTime fecha,
  }) async {
    try {
      final horarios = await _clienteApi.obtenerDisponibilidad(
        medicoId: medicoId,
        fecha: fecha,
      );

      await _almacenLocal.guardarDisponibilidad(medicoId, fecha, horarios);

      return horarios;
    } on ExcepcionTurnos catch (e) {
      if (e.tipo != ErrorTurnos.sinConexion) rethrow;

      final horarios = await _almacenLocal.obtenerDisponibilidad(
        medicoId,
        fecha,
      );

      if (horarios.isEmpty) rethrow;

      return horarios;
    }
  }

  @override
  Future<TurnoDetalle> solicitarTurno({
    required int pacienteId,
    required int medicoId,
    required DateTime fecha,
    required String hora,
    required String claveSolicitud,
  }) async {
    try {
      final turno = await _clienteApi.solicitarTurno(
        pacienteId: pacienteId,
        medicoId: medicoId,
        fecha: fecha,
        hora: hora,
        claveSolicitud: claveSolicitud,
      );

      await _almacenLocal.guardarTurnos([turno]);

      return turno;
    } on ExcepcionTurnos catch (e) {
      if (e.tipo != ErrorTurnos.sinConexion) rethrow;

      final turnoLocal = TurnoDetalle(
        id: -DateTime.now().microsecondsSinceEpoch,
        estado: EstadoTurno.pendiente,
        fecha: fecha,
        hora: hora,
        claveSolicitud: claveSolicitud,
        sincronizado: false,
        paciente: PacienteDetalle(
          id: pacienteId,
          nombre: 'Paciente',
          apellido: '',
          dni: '',
        ),
        medico: MedicoDetalle(
          id: medicoId,
          nombre: 'Médico',
          apellido: '',
          especialidad: EspecialidadDetalle(id: 0, nombre: 'General'),
        ),
      );

      await _almacenLocal.guardarTurnos([turnoLocal]);

      return turnoLocal;
    }
  }

  @override
  Future<TurnoDetalle> reprogramarTurno({
    required int turnoId,
    required DateTime fecha,
    required String hora,
  }) {
    return _clienteApi.reprogramarTurno(
      turnoId: turnoId,
      fecha: fecha,
      hora: hora,
    );
  }

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({
    required int turnoId,
    required EstadoTurno estado,
  }) {
    return _clienteApi.cambiarEstadoTurno(turnoId: turnoId, estado: estado);
  }
}
