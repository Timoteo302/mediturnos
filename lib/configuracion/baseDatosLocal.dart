import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Esta clase maneja la base de datos SQLite del teléfono (mediturnos.db).
class BaseDatosLocal {
  static Database? _baseDatos;
  static String? _rutaPersonalizadaTest;

  // Método exclusivo para pruebas unitarias: permite reiniciar la instancia o definir una ruta específica (por ejemplo inMemoryDatabasePath).
  static Future<void> reiniciarParaTests({String? ruta}) async {
    if (_baseDatos != null && _baseDatos!.isOpen) {
      await _baseDatos!.close();
    }
    _baseDatos = null;
    _rutaPersonalizadaTest = ruta;
  }

  // Uso un singleton (_baseDatos) para reutilizar la conexión y no abrir la base varias veces a la vez.
  static Future<Database> obtenerBaseDatos() async {
    if (_baseDatos != null) {
      return _baseDatos!;
    }

    final ruta = _rutaPersonalizadaTest ?? join(await getDatabasesPath(), 'mediturnos.db');

    _baseDatos = await openDatabase(
      ruta,
      version: 7,
      onCreate: (db, version) async {
        // Tabla para guardar los turnos localmente.
        // sincronizado: 1 si ya se guardó en el servidor, 0 si se creó o modificó sin conexión.
        // operacionPendiente: la acción a enviar al reconectarse ('CREAR', 'CANCELAR', 'REPROGRAMAR').
        // claveSolicitud: clave única para evitar enviar dos veces la misma solicitud al servidor.
        // errorSincronizacion: mensaje descriptivo si falló la sincronización con el servidor.
        // respuestaPaciente: guarda si el paciente confirmó asistencia o no ('SIN_RESPUESTA', 'ASISTIRA', 'NO_ASISTIRA').
        // origenPendiente: registra quién originó un cambio de estado pendiente de envío ('PACIENTE' o 'CENTRO').
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
            operacionPendiente TEXT,
            respuestaPaciente TEXT NOT NULL DEFAULT 'SIN_RESPUESTA',
            origenPendiente TEXT
          )
        ''');

        // Tabla para cachear la nómina de médicos.
        // Se guarda un objeto JSON en "datos" para simplificar la estructura y mapearlo directo a Dart.
        // sincronizado indica si la info coincide con la API y operacionPendiente registra cambios locales.
        await db.execute('''
          CREATE TABLE medicos (
            id INTEGER PRIMARY KEY,
            datos TEXT NOT NULL,
            sincronizado INTEGER NOT NULL DEFAULT 1,
            operacionPendiente TEXT
          )
        ''');

        // Tabla para guardar las especialidades médicas.
        // Se almacena la info en JSON dentro de "datos" para simplificar lecturas sin crear múltiples tablas relacionadas.
        await db.execute('''
          CREATE TABLE especialidades (
            id INTEGER PRIMARY KEY,
            datos TEXT NOT NULL
          )
        ''');

        // Tabla para la configuración de atención y horarios de cada médico.
        // Guarda en "datos" la estructura JSON completa de la agenda del médico.
        await db.execute('''
          CREATE TABLE horarios_medico (
            medicoId INTEGER PRIMARY KEY,
            datos TEXT NOT NULL
          )
        ''');

        // Tabla centralizada para registrar las franjas horarias disponibles u ocupadas de los médicos.
        await db.execute('''
          CREATE TABLE disponibilidades (
            medicoId INTEGER NOT NULL,
            fecha TEXT NOT NULL,
            hora TEXT NOT NULL,
            disponible INTEGER NOT NULL,
            PRIMARY KEY (medicoId, fecha, hora)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Versión 2: agrega pacienteId, medicoId y claveSolicitud a los turnos para vincularlos con la API.
        if (oldVersion < 2) {
          await _agregarColumnaSiNoExiste(db, 'turnos', 'pacienteId', 'INTEGER');
          await _agregarColumnaSiNoExiste(db, 'turnos', 'medicoId', 'INTEGER');
          await _agregarColumnaSiNoExiste(db, 'turnos', 'claveSolicitud', 'TEXT');
        }
        // Versión 3: agrega la columna errorSincronizacion en turnos para registrar errores de red o servidor.
        if (oldVersion < 3) {
          await _agregarColumnaSiNoExiste(
            db,
            'turnos',
            'errorSincronizacion',
            'TEXT',
          );
        }
        // Versión 4: crea la tabla de médicos para guardar la nómina localmente.
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS medicos (
              id INTEGER PRIMARY KEY,
              datos TEXT NOT NULL
            )
          ''');
        }
        // Versión 5: agrega operacionPendiente y sincronizado a medicos, y crea las tablas de especialidades y horarios_medico.
        if (oldVersion < 5) {
          await _agregarColumnaSiNoExiste(
            db,
            'turnos',
            'operacionPendiente',
            'TEXT',
          );
          await _agregarColumnaSiNoExiste(
            db,
            'medicos',
            'sincronizado',
            'INTEGER NOT NULL DEFAULT 1',
          );
          await _agregarColumnaSiNoExiste(
            db,
            'medicos',
            'operacionPendiente',
            'TEXT',
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
        // Versión 6: crea la tabla disponibilidades dentro del esquema central para gestionar turnos libres u ocupados.
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS disponibilidades (
              medicoId INTEGER NOT NULL,
              fecha TEXT NOT NULL,
              hora TEXT NOT NULL,
              disponible INTEGER NOT NULL,
              PRIMARY KEY (medicoId, fecha, hora)
            )
          ''');
        }
        // Versión 7: agrega respuestaPaciente y origenPendiente en turnos para persistir confirmación de asistencia y origen.
        if (oldVersion < 7) {
          await _agregarColumnaSiNoExiste(
            db,
            'turnos',
            'respuestaPaciente',
            "TEXT NOT NULL DEFAULT 'SIN_RESPUESTA'",
          );
          await _agregarColumnaSiNoExiste(
            db,
            'turnos',
            'origenPendiente',
            'TEXT',
          );
        }
      },
    );

    return _baseDatos!;
  }

  /// Verifica la estructura de la tabla mediante `PRAGMA table_info` antes de intentar hacer un `ALTER TABLE`.
  /// Esto previene excepciones por columnas duplicadas durante actualizaciones parciales de versión.
  static Future<void> _agregarColumnaSiNoExiste(
    Database db,
    String tabla,
    String columna,
    String tipo,
  ) async {
    final columnas = await db.rawQuery('PRAGMA table_info($tabla)');
    final existe = columnas.any((c) => c['name'] == columna);
    if (!existe) {
      await db.execute('ALTER TABLE $tabla ADD COLUMN $columna $tipo');
    }
  }
}
