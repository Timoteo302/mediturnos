import 'package:sqflite/sqflite.dart';

import '../fuentes/baseDatosLocal.dart';
import '../modelos/turno.dart';
import 'repositorioTurnos.dart';

class RepositorioTurnosImpl implements RepositorioTurnos {
  @override
  Future<List<Turno>> obtenerTurnos() async {
    final db = await BaseDatosLocal.obtenerBaseDatos();
    final datos = await db.query('turnos');

    return datos.map((dato) {
      return Turno(
        id: dato['id'] as int,
        paciente: dato['paciente'] as String,
        medico: dato['medico'] as String,
        especialidad: dato['especialidad'] as String,
        fecha: dato['fecha'] as String,
        hora: dato['hora'] as String,
        estado: dato['estado'] as String,
        sincronizado: (dato['sincronizado'] as int) == 1,
        pacienteId: dato['pacienteId'] as int?,
        medicoId: dato['medicoId'] as int?,
        claveSolicitud: dato['claveSolicitud'] as String?,
        errorSincronizacion: dato['errorSincronizacion'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> guardarTurno(Turno turno) async {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    await db.insert('turnos', {
      'id': turno.id,
      'paciente': turno.paciente,
      'medico': turno.medico,
      'especialidad': turno.especialidad,
      'fecha': turno.fecha,
      'hora': turno.hora,
      'estado': turno.estado,
      'sincronizado': turno.sincronizado ? 1 : 0,
      'pacienteId': turno.pacienteId,
      'medicoId': turno.medicoId,
      'claveSolicitud': turno.claveSolicitud,
      'errorSincronizacion': turno.errorSincronizacion,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> modificarTurno(Turno turno) async {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    await db.update(
      'turnos',
      {
        'paciente': turno.paciente,
        'medico': turno.medico,
        'especialidad': turno.especialidad,
        'fecha': turno.fecha,
        'hora': turno.hora,
        'estado': turno.estado,
        'sincronizado': turno.sincronizado ? 1 : 0,
        'pacienteId': turno.pacienteId,
        'medicoId': turno.medicoId,
        'claveSolicitud': turno.claveSolicitud,
        'errorSincronizacion': turno.errorSincronizacion,
      },
      where: 'id = ?',
      whereArgs: [turno.id],
    );
  }

  @override
  Future<void> eliminarTurno(int id) async {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    await db.delete('turnos', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> reemplazarTurno(int idAnterior, Turno turno) async {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    await db.transaction((txn) async {
      await txn.delete('turnos', where: 'id = ?', whereArgs: [idAnterior]);

      await txn.insert('turnos', {
        'id': turno.id,
        'paciente': turno.paciente,
        'medico': turno.medico,
        'especialidad': turno.especialidad,
        'fecha': turno.fecha,
        'hora': turno.hora,
        'estado': turno.estado,
        'sincronizado': 1,
        'pacienteId': turno.pacienteId,
        'medicoId': turno.medicoId,
        'claveSolicitud': turno.claveSolicitud,
        'errorSincronizacion': null,
      });
    });
  }

  @override
  Future<void> marcarErrorSincronizacion(int id, String error) async {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    await db.update(
      'turnos',
      {'errorSincronizacion': error},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
