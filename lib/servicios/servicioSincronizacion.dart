import 'dart:convert';
import 'package:http/http.dart' as http;

import '../configuracion/configuracionServidor.dart';
import '../turnos/datos/fuentes/baseDatosLocal.dart';
import '../turnos/datos/modelos/turno.dart';
import '../turnos/datos/repositorios/repositorioTurnos.dart';

class ServicioSincronizacion {
  final RepositorioTurnos repositorio;
  static bool _sincronizando = false;

  ServicioSincronizacion(this.repositorio);

  Future<List<Turno>> obtenerTurnosPendientes() async {
    final turnos = await repositorio.obtenerTurnos();

    return turnos
        .where(
          (turno) => !turno.sincronizado && turno.errorSincronizacion == null,
        )
        .toList();
  }

  Future<void> sincronizar() async {
    if (_sincronizando) return;
    _sincronizando = true;

    try {
      final db = await BaseDatosLocal.obtenerBaseDatos();
      final filasPendientes = await db.query(
        'turnos',
        where: 'sincronizado = 0 AND errorSincronizacion IS NULL',
      );

      for (final fila in filasPendientes) {
        final id = fila['id'] as int;
        final operacion =
            (fila['operacionPendiente']?.toString() ?? 'CREAR').toUpperCase();
        final pacienteId = fila['pacienteId'] as int?;
        final medicoId = fila['medicoId'] as int?;
        final claveSolicitud = fila['claveSolicitud']?.toString();
        final fecha = fila['fecha'].toString();
        final hora = fila['hora'].toString();
        final estado = fila['estado'].toString();

        try {
          if (operacion == 'CREAR' || id < 0) {
            if (pacienteId == null ||
                medicoId == null ||
                claveSolicitud == null) {
              await repositorio.marcarErrorSincronizacion(
                id,
                'Faltan datos necesarios para sincronizar el turno.',
              );
              continue;
            }

            final respuesta = await http
                .post(
                  Uri.parse('${ConfiguracionServidor.urlBase}/turnos'),
                  headers: {'Content-Type': 'application/json; charset=utf-8'},
                  body: jsonEncode({
                    'paciente': {'id': pacienteId},
                    'medico': {'id': medicoId},
                    'fecha': fecha,
                    'hora': hora,
                    'estado': estado.toUpperCase(),
                    'claveSolicitud': claveSolicitud,
                  }),
                )
                .timeout(ConfiguracionServidor.tiempoEspera);

            if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
              final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
              final turnoSincronizado = Turno(
                id: datos['id'] as int,
                paciente: fila['paciente'].toString(),
                medico: fila['medico'].toString(),
                especialidad: fila['especialidad'].toString(),
                fecha: fecha,
                hora: hora,
                estado: datos['estado']?.toString() ?? estado,
                sincronizado: true,
                pacienteId: pacienteId,
                medicoId: medicoId,
                claveSolicitud: claveSolicitud,
                errorSincronizacion: null,
              );
              await repositorio.reemplazarTurno(id, turnoSincronizado);
            } else {
              await _manejarErrorHttp(id, respuesta);
            }
          } else if (operacion == 'REPROGRAMAR') {
            final respuesta = await http
                .put(
                  Uri.parse('${ConfiguracionServidor.urlBase}/turnos/$id'),
                  headers: {'Content-Type': 'application/json; charset=utf-8'},
                  body: jsonEncode({
                    'fecha': fecha,
                    'hora': hora,
                  }),
                )
                .timeout(ConfiguracionServidor.tiempoEspera);

            if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
              await db.update(
                'turnos',
                {'sincronizado': 1, 'operacionPendiente': null},
                where: 'id = ?',
                whereArgs: [id],
              );
            } else {
              await _manejarErrorHttp(id, respuesta);
            }
          } else if (operacion == 'CAMBIAR_ESTADO') {
            final respuesta = await http
                .patch(
                  Uri.parse(
                    '${ConfiguracionServidor.urlBase}/turnos/$id/estado',
                  ),
                  headers: {'Content-Type': 'application/json; charset=utf-8'},
                  body: jsonEncode({
                    'estado': estado.toUpperCase(),
                  }),
                )
                .timeout(ConfiguracionServidor.tiempoEspera);

            if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
              await db.update(
                'turnos',
                {'sincronizado': 1, 'operacionPendiente': null},
                where: 'id = ?',
                whereArgs: [id],
              );
            } else {
              await _manejarErrorHttp(id, respuesta);
            }
          }
        } catch (_) {
          // Si falla por red, permanece pendiente para el próximo intento.
        }
      }
    } finally {
      _sincronizando = false;
    }
  }

  Future<void> _manejarErrorHttp(int id, http.Response respuesta) async {
    if (respuesta.statusCode >= 400 &&
        respuesta.statusCode < 500 &&
        respuesta.statusCode != 401 &&
        respuesta.statusCode != 403 &&
        respuesta.statusCode != 408 &&
        respuesta.statusCode != 429) {
      String detalle = 'Error HTTP ${respuesta.statusCode}';
      try {
        final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
        final codigo = datos['codigo']?.toString();
        final mensaje = datos['error']?.toString() ??
            datos['mensaje']?.toString() ??
            datos['message']?.toString();
        if (codigo != null || mensaje != null) {
          detalle = [
            if (codigo != null) codigo,
            if (mensaje != null) mensaje,
          ].join(': ');
        }
      } catch (_) {}

      await repositorio.marcarErrorSincronizacion(id, detalle);
    }
  }
}