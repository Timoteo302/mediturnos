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
      version: 1,
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
            sincronizado INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );

    return _baseDatos!;
  }
}

/*Esta clase va a ser la encargada de crear y abrir la base SQLite del celular.
Que hace?
BaseDatosLocal
      ↓
Busca la base SQLite
      ↓
Si no existe → la crea
      ↓
Si ya existe → la abre
*/




