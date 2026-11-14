import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatosLocal {
  static Database? _baseDatos;

  static Future<Database> obtenerBaseDatos() async {
    if (_baseDatos != null) {
      return _baseDatos!;
    }

    final ruta = join(await getDatabasesPath(), 'mediturnos.db');

    _baseDatos = await openDatabase(
      ruta,
      version: 5,
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

        await db.execute('''
          CREATE TABLE medicos (
            id INTEGER PRIMARY KEY,
            datos TEXT NOT NULL,
            sincronizado INTEGER NOT NULL DEFAULT 1,
            operacionPendiente TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE especialidades (
            id INTEGER PRIMARY KEY,
            datos TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE horarios_medico (
            medicoId INTEGER PRIMARY KEY,
            datos TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE turnos ADD COLUMN pacienteId INTEGER');
          await db.execute('ALTER TABLE turnos ADD COLUMN medicoId INTEGER');
          await db.execute('ALTER TABLE turnos ADD COLUMN claveSolicitud TEXT');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE turnos ADD COLUMN errorSincronizacion TEXT',
          );
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS medicos (
              id INTEGER PRIMARY KEY,
              datos TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE turnos ADD COLUMN operacionPendiente TEXT',
          );
          await db.execute(
            'ALTER TABLE medicos ADD COLUMN sincronizado INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute(
            'ALTER TABLE medicos ADD COLUMN operacionPendiente TEXT',
          );
          await db.execute('''
            CREATE TABLE IF NOT EXISTS especialidades (
              id INTEGER PRIMARY KEY,
              datos TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS horarios_medico (
              medicoId INTEGER PRIMARY KEY,
              datos TEXT NOT NULL
            )
          ''');
        }
      },
    );

    return _baseDatos!;
  }
}