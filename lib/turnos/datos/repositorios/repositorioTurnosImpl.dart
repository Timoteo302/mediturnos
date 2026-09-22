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
      );
    }).toList();
  }

  @override
  Future<void> guardarTurno(Turno turno) async {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    await db.insert(
      'turnos',
      {
        'id': turno.id,
        'paciente': turno.paciente,
        'medico': turno.medico,
        'especialidad': turno.especialidad,
        'fecha': turno.fecha,
        'hora': turno.hora,
        'estado': turno.estado,
        'sincronizado': turno.sincronizado ? 1 : 0,
      },
    );
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
      },
      where: 'id = ?',
      whereArgs: [turno.id],
    );
  }

  @override
  Future<void> eliminarTurno(int id) async {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    await db.delete(
      'turnos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
/*RepositorioTurnos → sería como una interfaz. Dice qué operaciones existen.
Seria QUE PUEDE HACER? obtener, guardar, modificar
RepositorioTurnosImpl → es la clase que implementa esa interfaz y contiene el código real.
Seria COMO LO HACE? SQLite - API - sincronizacion */
