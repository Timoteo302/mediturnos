import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:mediturnos/turnos/datos/fuentes/baseDatosLocal.dart';

import '../modelos/medico.dart';
import '../modelos/especialidad.dart';
import '../modelos/horarioAtencion.dart';

class AlmacenMedicosLocal {
  Future<Database> get _db => BaseDatosLocal.obtenerBaseDatos();

  Future<void> guardarMedicos(List<Medico> medicos) async {
    final db = await _db;

    await db.transaction((txn) async {
      // Conservamos los médicos creados/modificados offline que aún no sincronizaron
      await txn.delete('medicos', where: 'sincronizado = 1');

      for (final medico in medicos) {
        final existePendiente = await txn.query(
          'medicos',
          where: 'id = ? AND sincronizado = 0',
          whereArgs: [medico.id],
        );
        if (existePendiente.isEmpty) {
          await txn.insert(
            'medicos',
            {
              'id': medico.id,
              'datos': jsonEncode(medico.toJson()),
              'sincronizado': 1,
              'operacionPendiente': null,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<void> guardarMedicoLocal(
    Medico medico, {
    required bool sincronizado,
    String? operacionPendiente,
  }) async {
    final db = await _db;
    await db.insert(
      'medicos',
      {
        'id': medico.id,
        'datos': jsonEncode(medico.toJson()),
        'sincronizado': sincronizado ? 1 : 0,
        'operacionPendiente': operacionPendiente,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Medico>> obtenerMedicos({
    bool incluirInactivos = false,
  }) async {
    final db = await _db;
    final filas = await db.query('medicos', orderBy: 'id');

    final medicos = filas.map((fila) {
      final datos = jsonDecode(fila['datos'] as String);
      return Medico.fromJson(datos);
    }).toList();

    if (incluirInactivos) return medicos;
    return medicos.where((medico) => medico.activo).toList();
  }

  Future<Medico?> obtenerMedicoPorId(int id) async {
    final db = await _db;
    final filas = await db.query('medicos', where: 'id = ?', whereArgs: [id]);
    if (filas.isEmpty) return null;
    return Medico.fromJson(jsonDecode(filas.first['datos'] as String));
  }

  Future<void> guardarEspecialidades(List<Especialidad> especialidades) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('especialidades');
      for (final esp in especialidades) {
        await txn.insert(
          'especialidades',
          {
            'id': esp.id,
            'datos': jsonEncode(esp.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Especialidad>> obtenerEspecialidades({
    bool incluirInactivas = false,
  }) async {
    final db = await _db;
    final filas = await db.query('especialidades', orderBy: 'id');

    final lista = filas
        .map((f) => Especialidad.fromJson(jsonDecode(f['datos'] as String)))
        .toList();

    if (incluirInactivas) return lista;
    return lista.where((e) => e.activo).toList();
  }

  Future<void> guardarHorarios(
    int medicoId,
    List<HorarioAtencion> horarios,
  ) async {
    final db = await _db;
    await db.insert(
      'horarios_medico',
      {
        'medicoId': medicoId,
        'datos': jsonEncode(horarios.map((h) => h.toJson()).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) async {
    final db = await _db;
    final filas = await db.query(
      'horarios_medico',
      where: 'medicoId = ?',
      whereArgs: [medicoId],
    );
    if (filas.isEmpty) return [];

    final listaJson = jsonDecode(filas.first['datos'] as String) as List<dynamic>;
    return listaJson
        .map((item) => HorarioAtencion.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}