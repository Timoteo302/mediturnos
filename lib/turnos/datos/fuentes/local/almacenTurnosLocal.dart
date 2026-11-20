import 'package:sqflite/sqflite.dart';

import 'package:mediturnos/configuracion/baseDatosLocal.dart';
import '../../modelos/turnoDetalle.dart';
import '../../modelos/estadoTurno.dart';
import '../../modelos/horarioDisponible.dart';

// Almacén local de SQLite para guardar, consultar y actualizar turnos y sus disponibilidades offline.
class AlmacenTurnosLocal {
  Future<Database> get _db => BaseDatosLocal.obtenerBaseDatos();

  // Guarda una lista de turnos en la tabla local. Guarda la respuestaPaciente y pacienteCuentaPendiente.
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
        'respuestaPaciente': turno.respuestaPaciente,
        'pacienteCuentaPendiente': turno.pacienteCuentaPendiente ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Obtiene los turnos filtrados opcionalmente por pacienteId.
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

  // Busca un turno específico por su ID en SQLite.
  Future<TurnoDetalle?> obtenerTurnoPorId(int id) async {
    final db = await _db;
    final filas = await db.query('turnos', where: 'id = ?', whereArgs: [id]);
    if (filas.isEmpty) return null;
    return _mapearFilaATurnoDetalle(filas.first);
  }

  // Actualiza los valores de un turno cuando se modifica sin conexión.
  // Permite guardar origenPendiente y restablece estado/respuestaPaciente al reprogramar.
  Future<TurnoDetalle?> actualizarTurnoOffline({
    required int turnoId,
    DateTime? nuevaFecha,
    String? nuevaHora,
    EstadoTurno? nuevoEstado,
    String? origen,
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

    if (origen != null) {
      valores['origenPendiente'] = origen;
    }

    if (nuevaFecha != null || nuevaHora != null) {
      // Al reprogramar fecha u hora sin conexión, si estaba CONFIRMADO vuelve a PENDIENTE
      if (actual.estado == EstadoTurno.confirmado) {
        valores['estado'] = EstadoTurno.pendiente.aTextoApi();
      }
      // La respuesta de asistencia vuelve a 'SIN_RESPUESTA' al cambiar fecha u hora
      valores['respuestaPaciente'] = 'SIN_RESPUESTA';
    }

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

  // Convierte una fila de la base de datos a un objeto TurnoDetalle.
  // calcula puedeConfirmarse dinámicamente según la hora actual para evitar que quede desactualizado si no hay conexión.
  TurnoDetalle _mapearFilaATurnoDetalle(Map<String, Object?> fila) {
    final pacienteNombre = (fila['paciente'] ?? 'Paciente').toString();
    final medicoNombre = (fila['medico'] ?? 'Médico').toString();
    final estado = EstadoTurnoExtension.desdeTexto(fila['estado'].toString());
    final fecha = DateTime.parse(fila['fecha'].toString());
    final hora = fila['hora'].toString();
    final respuestaPaciente = fila['respuestaPaciente']?.toString() ?? 'SIN_RESPUESTA';
    final puedeConfirmarse = _calcularPuedeConfirmarse(estado, fecha, hora);
    final pacienteCuentaPendiente = fila['pacienteCuentaPendiente'] == 1;

    return TurnoDetalle(
      id: fila['id'] as int,
      estado: estado,
      fecha: fecha,
      hora: hora,
      claveSolicitud: fila['claveSolicitud']?.toString(),
      sincronizado: fila['sincronizado'] == 1,
      errorSincronizacion: fila['errorSincronizacion']?.toString(),
      respuestaPaciente: respuestaPaciente,
      puedeConfirmarse: puedeConfirmarse,
      pacienteCuentaPendiente: pacienteCuentaPendiente,
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

  // Calcula si el turno se puede confirmar (estado PENDIENTE y faltan 24 hs o menos para el inicio).
  // No lo guardamos en SQLite porque el tiempo transcurre sin conexión y el valor se quedaría congelado.
  bool _calcularPuedeConfirmarse(EstadoTurno estado, DateTime fecha, String hora) {
    if (estado != EstadoTurno.pendiente) return false;
    final partesHora = hora.split(':');
    final h = partesHora.isNotEmpty ? int.tryParse(partesHora[0]) ?? 0 : 0;
    final m = partesHora.length > 1 ? int.tryParse(partesHora[1]) ?? 0 : 0;
    final fechaHoraTurno = DateTime(fecha.year, fecha.month, fecha.day, h, m);
    final inicio24hAntes = fechaHoraTurno.subtract(const Duration(hours: 24));
    return !DateTime.now().isBefore(inicio24hAntes);
  }

  // Guarda las disponibilidades de un médico en SQLite.
  Future<void> guardarDisponibilidad(
    int medicoId,
    DateTime fecha,
    List<HorarioDisponible> horarios,
  ) async {
    final db = await _db;

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

  // Actualiza la disponibilidad (1 o 0) de un horario en la tabla disponibilidades si existe la fila.
  Future<void> marcarHorarioLocal(
    int medicoId,
    DateTime fecha,
    String hora, {
    required bool disponible,
  }) async {
    final db = await _db;
    final fechaStr = _formatearFecha(fecha);

    await db.update(
      'disponibilidades',
      {'disponible': disponible ? 1 : 0},
      where: 'medicoId = ? AND fecha = ? AND hora = ?',
      whereArgs: [medicoId, fechaStr, hora],
    );
  }

  // Obtiene los horarios disponibles de un médico desde la base local.
  Future<List<HorarioDisponible>> obtenerDisponibilidad(
    int medicoId,
    DateTime fecha,
  ) async {
    final db = await _db;

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
