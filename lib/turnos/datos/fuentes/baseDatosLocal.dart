import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatosLocal {
  static Database? _baseDatos;

  static Future<Database> obtenerBaseDatos() async {
    if (_baseDatos != null) {
      return _baseDatos!;
    }

    final ruta = join(
      await getDatabasesPath(),
      'mediturnos.db',
    );

    _baseDatos = await openDatabase(
      ruta,
      version: 2,
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
            claveSolicitud TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE turnos ADD COLUMN pacienteId INTEGER',
          );
          await db.execute(
            'ALTER TABLE turnos ADD COLUMN medicoId INTEGER',
          );
          await db.execute(
            'ALTER TABLE turnos ADD COLUMN claveSolicitud TEXT',
          );
        }
      },
    );

    return _baseDatos!;
  }
}