import 'package:sqflite/sqflite.dart';

import '../baseDatosLocal.dart';
import '../../modelos/turnoDetalle.dart';
import '../../modelos/estadoTurno.dart';
import '../../modelos/horarioDisponible.dart';

class AlmacenTurnosLocal {
  Future<Database> get _db => BaseDatosLocal.obtenerBaseDatos();

  Future<void> guardarTurnos(
    List<TurnoDetalle> turnos, {
    String? operacionPendiente,
  }) async {
    final db = await _db;

    for (final turno in turnos) {
      // Si viene del servidor (sincronizado == true), no pisar si hay una modificación offline pendiente sobre ese mismo ID
      if (turno.sincronizado) {
        final pendiente = await db.query(
          'turnos',
          where: 'id = ? AND sincronizado = 0',
          whereArgs: [turno.id],
        );
        if (pendiente.isNotEmpty) continue;
      }

      await db.insert('turnos', {
        'id': turno.id,
        'paciente': turno.paciente.nombreCompleto,
        'medico': turno.medico.nombreCompleto,
        'especialidad': turno.medico.especialidad.nombre,
        'fecha': _formatearFecha(turno.fecha),
        'hora': turno.hora,
        'estado': turno.estado.aTextoApi(),
        'sincronizado': turno.sincronizado ? 1 : 0,
        'pacienteId': turno.paciente.id,
        'medicoId': turno.medico.id,
        'claveSolicitud': turno.claveSolicitud,
        'errorSincronizacion': turno.errorSincronizacion,
        'operacionPendiente':
            turno.sincronizado ? null : (operacionPendiente ?? 'CREAR'),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId}) async {
    final db = await _db;

    final filas = await db.query(
      'turnos',
      where: pacienteId == null ? null : 'pacienteId = ?',
      whereArgs: pacienteId == null ? null : [pacienteId],
      orderBy: 'fecha DESC, hora DESC',
    );

    return filas.map(_mapearFilaATurnoDetalle).toList();
  }

  Future<TurnoDetalle?> obtenerTurnoPorId(int id) async {
    final db = await _db;
    final filas = await db.query('turnos', where: 'id = ?', whereArgs: [id]);
    if (filas.isEmpty) return null;
    return _mapearFilaATurnoDetalle(filas.first);
  }

  Future<TurnoDetalle?> actualizarTurnoOffline({
    required int turnoId,
    DateTime? nuevaFecha,
    String? nuevaHora,
    EstadoTurno? nuevoEstado,
    required String operacionPendiente,
  }) async {
    final db = await _db;
    final actual = await obtenerTurnoPorId(turnoId);
    if (actual == null) return null;

    final valores = <String, Object?>{
      'sincronizado': 0,
      'errorSincronizacion': null,
      // Si el turno aún no se creó en el servidor (id < 0), la operación sigue siendo CREAR con los datos actualizados
      'operacionPendiente': turnoId < 0 ? 'CREAR' : operacionPendiente,
    };

    if (nuevaFecha != null) {
      valores['fecha'] = _formatearFecha(nuevaFecha);
    }
    if (nuevaHora != null) {
      valores['hora'] = nuevaHora;
    }
    if (nuevoEstado != null) {
      valores['estado'] = nuevoEstado.aTextoApi();
    }

    await db.update(
      'turnos',
      valores,
      where: 'id = ?',
      whereArgs: [turnoId],
    );

    return obtenerTurnoPorId(turnoId);
  }

  TurnoDetalle _mapearFilaATurnoDetalle(Map<String, Object?> fila) {
    final pacienteNombre = (fila['paciente'] ?? 'Paciente').toString();
    final medicoNombre = (fila['medico'] ?? 'Médico').toString();

    return TurnoDetalle(
      id: fila['id'] as int,
      estado: EstadoTurnoExtension.desdeTexto(fila['estado'].toString()),
      fecha: DateTime.parse(fila['fecha'].toString()),
      hora: fila['hora'].toString(),
      claveSolicitud: fila['claveSolicitud']?.toString(),
      sincronizado: fila['sincronizado'] == 1,
      errorSincronizacion: fila['errorSincronizacion']?.toString(),
      paciente: PacienteDetalle(
        id: fila['pacienteId'] as int? ?? 0,
        nombre: pacienteNombre,
        apellido: '',
        dni: '',
      ),
      medico: MedicoDetalle(
        id: fila['medicoId'] as int? ?? 0,
        nombre: medicoNombre,
        apellido: '',
        especialidad: EspecialidadDetalle(
          id: 0,
          nombre: fila['especialidad'].toString(),
        ),
      ),
    );
  }

  Future<void> guardarDisponibilidad(
    int medicoId,
    DateTime fecha,
    List<HorarioDisponible> horarios,
  ) async {
    final db = await _db;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS disponibilidades (
        medicoId INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        disponible INTEGER NOT NULL,
        PRIMARY KEY (medicoId, fecha, hora)
      )
    ''');

    await db.delete(
      'disponibilidades',
      where: 'medicoId = ? AND fecha = ?',
      whereArgs: [medicoId, _formatearFecha(fecha)],
    );

    for (final horario in horarios) {
      await db.insert('disponibilidades', {
        'medicoId': medicoId,
        'fecha': _formatearFecha(fecha),
        'hora': horario.hora,
        'disponible': horario.disponible ? 1 : 0,
      });
    }
  }

  Future<List<HorarioDisponible>> obtenerDisponibilidad(
    int medicoId,
    DateTime fecha,
  ) async {
    final db = await _db;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS disponibilidades (
        medicoId INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        disponible INTEGER NOT NULL,
        PRIMARY KEY (medicoId, fecha, hora)
      )
    ''');

    final filas = await db.query(
      'disponibilidades',
      where: 'medicoId = ? AND fecha = ?',
      whereArgs: [medicoId, _formatearFecha(fecha)],
      orderBy: 'hora',
    );

    return filas.map((fila) {
      return HorarioDisponible(
        hora: fila['hora'].toString(),
        disponible: fila['disponible'] == 1,
      );
    }).toList();
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }
}