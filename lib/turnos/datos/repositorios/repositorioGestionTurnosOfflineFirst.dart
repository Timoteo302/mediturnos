import 'dart:convert';

import 'package:mediturnos/autenticacion/datos/fuentes/almacenSesionLocalSqlite.dart';
import 'package:mediturnos/medicos/datos/fuentes/almacenMedicosLocal.dart';

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
  final AlmacenMedicosLocal _almacenMedicos = AlmacenMedicosLocal();
  final AlmacenSesionLocalSqlite _almacenSesion = AlmacenSesionLocalSqlite();

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

      // Conservamos todos los turnos locales no sincronizados (pendientes o con error)
      final turnosPendientesLocales = turnosLocales
          .where((turno) => !turno.sincronizado)
          .toList();

      final idsPendientes = turnosPendientesLocales
          .map((turno) => turno.id)
          .toSet();

      return [
        ...turnosPendientesLocales,
        ...turnos.where((turno) => !idsPendientes.contains(turno.id)),
      ];
    } on ExcepcionTurnos catch (e) {
      if (e.tipo != ErrorTurnos.sinConexion) rethrow;

      var locales = await _almacenLocal.obtenerTurnos(pacienteId: pacienteId);
      if (medicoId != null) {
        locales = locales.where((t) => t.medico.id == medicoId).toList();
      }
      if (estado != null) {
        locales = locales.where((t) => t.estado == estado).toList();
      }
      if (fecha != null) {
        locales = locales
            .where(
              (t) =>
                  t.fecha.year == fecha.year &&
                  t.fecha.month == fecha.month &&
                  t.fecha.day == fecha.day,
            )
            .toList();
      }
      return locales;
    }
  }

  @override
  Future<TurnoDetalle> obtenerTurno(int id) async {
    try {
      return await _clienteApi.obtenerTurno(id);
    } on ExcepcionTurnos catch (e) {
      if (e.tipo != ErrorTurnos.sinConexion) rethrow;
      final local = await _almacenLocal.obtenerTurnoPorId(id);
      if (local != null) return local;
      rethrow;
    }
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

      // 1. Intentar leer disponibilidad exacta previamente cacheada
      final horariosCacheados = await _almacenLocal.obtenerDisponibilidad(
        medicoId,
        fecha,
      );
      if (horariosCacheados.isNotEmpty) {
        return horariosCacheados;
      }

      // 2. Fallback: calcular bloques desde los horarios de atención base del médico
      final horariosBase = await _almacenMedicos.obtenerHorarios(medicoId);
      if (horariosBase.isEmpty) rethrow;

      final turnosExistentes = await _almacenLocal.obtenerTurnos();
      final horasOcupadas = turnosExistentes
          .where(
            (t) =>
                t.medico.id == medicoId &&
                t.fecha.year == fecha.year &&
                t.fecha.month == fecha.month &&
                t.fecha.day == fecha.day &&
                t.estado != EstadoTurno.cancelado,
          )
          .map((t) => t.hora.substring(0, 5))
          .toSet();

      final generados = <HorarioDisponible>[];
      for (final franja in horariosBase) {
        if (!franja.activo || franja.diaSemana != fecha.weekday) continue;

        final inicio = _parsearMinutos(franja.horaInicio);
        final fin = _parsearMinutos(franja.horaFin);
        final paso = franja.duracionTurno > 0 ? franja.duracionTurno : 30;

        for (int min = inicio; min + paso <= fin; min += paso) {
          final h = (min ~/ 60).toString().padLeft(2, '0');
          final m = (min % 60).toString().padLeft(2, '0');
          final horaStr = '$h:$m';
          generados.add(
            HorarioDisponible(
              hora: horaStr,
              disponible: !horasOcupadas.contains(horaStr),
            ),
          );
        }
      }

      if (generados.isEmpty) rethrow;
      return generados;
    }
  }

  int _parsearMinutos(String hhmm) {
    final partes = hhmm.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
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

      final medicoLocal = await _almacenMedicos.obtenerMedicoPorId(medicoId);
      final nombrePaciente = await _resolverNombrePaciente(pacienteId);

      final turnoLocal = TurnoDetalle(
        id: -DateTime.now().microsecondsSinceEpoch,
        estado: EstadoTurno.pendiente,
        fecha: fecha,
        hora: hora,
        claveSolicitud: claveSolicitud,
        sincronizado: false,
        paciente: PacienteDetalle(
          id: pacienteId,
          nombre: nombrePaciente,
          apellido: '',
          dni: '',
        ),
        medico: MedicoDetalle(
          id: medicoId,
          nombre: medicoLocal != null
              ? '${medicoLocal.nombre} ${medicoLocal.apellido}'.trim()
              : 'Médico #$medicoId',
          apellido: '',
          especialidad: EspecialidadDetalle(
            id: medicoLocal?.especialidad.id ?? 0,
            nombre: medicoLocal?.especialidad.nombre ?? 'General',
          ),
        ),
      );

      await _almacenLocal.guardarTurnos([
        turnoLocal,
      ], operacionPendiente: 'CREAR');

      return turnoLocal;
    }
  }

  @override
  Future<TurnoDetalle> reprogramarTurno({
    required int turnoId,
    required DateTime fecha,
    required String hora,
  }) async {
    try {
      final actualizado = await _clienteApi.reprogramarTurno(
        turnoId: turnoId,
        fecha: fecha,
        hora: hora,
      );
      await _almacenLocal.guardarTurnos([actualizado]);
      return actualizado;
    } on ExcepcionTurnos catch (e) {
      if (e.tipo != ErrorTurnos.sinConexion) rethrow;

      final actualizadoLocal = await _almacenLocal.actualizarTurnoOffline(
        turnoId: turnoId,
        nuevaFecha: fecha,
        nuevaHora: hora,
        operacionPendiente: 'REPROGRAMAR',
      );
      if (actualizadoLocal != null) return actualizadoLocal;
      rethrow;
    }
  }

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({
    required int turnoId,
    required EstadoTurno estado,
  }) async {
    try {
      final actualizado = await _clienteApi.cambiarEstadoTurno(
        turnoId: turnoId,
        estado: estado,
      );
      await _almacenLocal.guardarTurnos([actualizado]);
      return actualizado;
    } on ExcepcionTurnos catch (e) {
      if (e.tipo != ErrorTurnos.sinConexion) rethrow;

      final actualizadoLocal = await _almacenLocal.actualizarTurnoOffline(
        turnoId: turnoId,
        nuevoEstado: estado,
        operacionPendiente: 'CAMBIAR_ESTADO',
      );
      if (actualizadoLocal != null) return actualizadoLocal;
      rethrow;
    }
  }

  Future<String> _resolverNombrePaciente(int pacienteId) async {
    try {
      final dbSesion = await _almacenSesion.database;
      final filas = await dbSesion.query(
        'sesiones_locales',
        orderBy: 'ultimo_acceso DESC',
      );
      for (final fila in filas) {
        final jsonMap =
            jsonDecode(fila['usuario_json'] as String) as Map<String, dynamic>;
        final pId = jsonMap['pacienteId'] ?? jsonMap['id'];
        if (pId == pacienteId) {
          final nombre = (jsonMap['nombre'] ?? '').toString();
          final apellido = (jsonMap['apellido'] ?? '').toString();
          final completo = '$nombre $apellido'.trim();
          if (completo.isNotEmpty) return completo;
        }
      }
    } catch (_) {}

    final previos = await _almacenLocal.obtenerTurnos(pacienteId: pacienteId);
    if (previos.isNotEmpty) {
      return previos.first.paciente.nombreCompleto;
    }
    return 'Paciente #$pacienteId';
  }
}
