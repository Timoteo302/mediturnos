import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'almacenSesionLocal.dart';

class AlmacenSesionLocalSqlite implements AlmacenSesionLocal {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _inicializarDb();
    return _database!;
  }

  Future<Database> _inicializarDb() async {
    final rutasBases = await getDatabasesPath();
    final ruta = join(rutasBases, 'mediturnos_sesion.db');

    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sesiones_locales (
            email TEXT PRIMARY KEY,
            contrasena_hash TEXT NOT NULL,
            usuario_json TEXT NOT NULL,
            ultimo_acceso TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> guardar(Usuario usuario, String contrasenaHash) async {
    final db = await database;
    final jsonMap = usuario.toJson();
    // Mantenemos el estado real de sesionOffline del usuario (false si es online, true si es offline)
    jsonMap['sesionOffline'] = usuario.sesionOffline;
    final usuarioJsonStr = json.encode(jsonMap);

    await db.insert(
      'sesiones_locales',
      {
        'email': usuario.email.trim().toLowerCase(),
        'contrasena_hash': contrasenaHash,
        'usuario_json': usuarioJsonStr,
        'ultimo_acceso': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, dynamic>?> obtener(String email) async {
    final db = await database;
    final emailNorm = email.trim().toLowerCase();
    final resultado = await db.query(
      'sesiones_locales',
      where: 'email = ?',
      whereArgs: [emailNorm],
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    }
    return null;
  }

  @override
  Future<void> borrar(String email) async {
    final db = await database;
    final emailNorm = email.trim().toLowerCase();
    await db.delete(
      'sesiones_locales',
      where: 'email = ?',
      whereArgs: [emailNorm],
    );
  }
}
