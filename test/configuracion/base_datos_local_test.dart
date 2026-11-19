import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mediturnos/configuracion/baseDatosLocal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  tearDown(() async {
    await BaseDatosLocal.reiniciarParaTests();
  });

  group('Pruebas SQLite Real - BaseDatosLocal', () {
    test('Migración: abre base v6, actualiza a v7 agregando respuestaPaciente y origenPendiente conservando filas', () async {
      final rutaV6 = 'test_migracion_v6_v7.db';
      await deleteDatabase(rutaV6);

      // 1. Creamos la base manualmente en versión 6 sin las columnas nuevas de la versión 7.
      final dbV6 = await openDatabase(
        rutaV6,
        version: 6,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE turnos (
              id INTEGER PRIMARY KEY,
              paciente TEXT NOT NULL,
              medico TEXT NOT NULL,
              especialidad TEXT NOT NULL,
              fecha TEXT NOT NULL,
              hora TEXT NOT NULL,
              estado TEXT NOT NULL,
              sincronizado INTEGER NOT NULL DEFAULT 0,
              pacienteId INTEGER,
              medicoId INTEGER,
              claveSolicitud TEXT,
              errorSincronizacion TEXT,
              operacionPendiente TEXT
            )
          ''');
          await db.insert('turnos', {
            'id': 50,
            'paciente': 'Mario Rossi',
            'medico': 'Dr. Gomez',
            'especialidad': 'Pediatría',
            'fecha': '2026-06-10',
            'hora': '09:00',
            'estado': 'PENDIENTE',
            'sincronizado': 1,
          });
        },
      );
      await dbV6.close();

      // 2. Abrimos la base existente usando BaseDatosLocal para ejecutar la migración onUpgrade a versión 7.
      await BaseDatosLocal.reiniciarParaTests(ruta: rutaV6);
      final dbV7 = await BaseDatosLocal.obtenerBaseDatos();

      // 3. Verificamos que la tabla turnos contiene las dos nuevas columnas respuestaPaciente y origenPendiente.
      final columnas = await dbV7.rawQuery('PRAGMA table_info(turnos)');
      final nombresColumnas = columnas.map((c) => c['name'].toString()).toList();

      expect(nombresColumnas, contains('respuestaPaciente'));
      expect(nombresColumnas, contains('origenPendiente'));

      // 4. Verificamos que el turno previo se conserva y respuestaPaciente tiene el valor por defecto 'SIN_RESPUESTA'.
      final filas = await dbV7.query('turnos', where: 'id = 50');
      expect(filas.length, equals(1));
      expect(filas.first['paciente'], equals('Mario Rossi'));
      expect(filas.first['respuestaPaciente'], equals('SIN_RESPUESTA'));

      await dbV7.close();
      await deleteDatabase(rutaV6);
    });

    test('Base nueva en versión 7: crea todas las tablas y columnas requeridas', () async {
      await BaseDatosLocal.reiniciarParaTests(ruta: inMemoryDatabasePath);
      final db = await BaseDatosLocal.obtenerBaseDatos();

      final tablas = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final nombresTablas = tablas.map((t) => t['name'].toString()).toList();

      expect(nombresTablas, contains('turnos'));
      expect(nombresTablas, contains('medicos'));
      expect(nombresTablas, contains('especialidades'));
      expect(nombresTablas, contains('horarios_medico'));
      expect(nombresTablas, contains('disponibilidades'));

      final columnasTurnos = await db.rawQuery('PRAGMA table_info(turnos)');
      final nombresColumnas = columnasTurnos.map((c) => c['name'].toString()).toList();

      expect(nombresColumnas, contains('respuestaPaciente'));
      expect(nombresColumnas, contains('origenPendiente'));
    });
  });
}
