import 'dart:convert';
import 'package:http/http.dart' as http;

import '../componentes/comunes/notificacionApp.dart';
import '../configuracion/configuracionServidor.dart';
import '../configuracion/baseDatosLocal.dart';
import '../turnos/datos/modelos/turno.dart';
import '../turnos/datos/repositorios/repositorioTurnos.dart';

// Servicio encargado de sincronizar con la API remota los turnos creados o modificados offline.
class ServicioSincronizacion {
  final RepositorioTurnos repositorio;
  final http.Client _clienteHttp;
  static bool _sincronizando = false;

  ServicioSincronizacion(this.repositorio, {required http.Client clienteHttp})
      : _clienteHttp = clienteHttp;

  Future<List<Turno>> obtenerTurnosPendientes() async {
    final turnos = await repositorio.obtenerTurnos();

    return turnos
        .where(
          (turno) => !turno.sincronizado && turno.errorSincronizacion == null,
        )
        .toList();
  }

  // Sincroniza las operaciones pendientes de la tabla local turnos con la API HTTP.
  Future<void> sincronizar() async {
    if (_sincronizando) return;
    _sincronizando = true;

    int erroresTotal = 0;
    bool huboHorarioOcupado = false;

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
        final origenPendiente = fila['origenPendiente']?.toString();

        try {
          if (operacion == 'CREAR' || id < 0) {
            if (pacienteId == null ||
                medicoId == null ||
                claveSolicitud == null) {
              erroresTotal++;
              await repositorio.marcarErrorSincronizacion(
                id,
                'Faltan datos necesarios para sincronizar el turno.',
              );
              continue;
            }

            final respuesta = await _clienteHttp
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

            if (respuesta.statusCode == 401) {
              // Si el pedido da 401, frenar la sincronización inmediatamente sin marcar los turnos como error.
              return;
            }

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
                respuestaPaciente: datos['respuestaPaciente']?.toString() ?? 'SIN_RESPUESTA',
              );
              await repositorio.reemplazarTurno(id, turnoSincronizado);
            } else {
              final codigoError = await _manejarErrorHttp(id, respuesta);
              if (_esErrorDeServidorHandled(respuesta.statusCode)) {
                erroresTotal++;
                if (codigoError == 'HORARIO_OCUPADO') {
                  huboHorarioOcupado = true;
                }
              }
            }
          } else if (operacion == 'REPROGRAMAR') {
            final respuesta = await _clienteHttp
                .put(
                  Uri.parse('${ConfiguracionServidor.urlBase}/turnos/$id'),
                  headers: {'Content-Type': 'application/json; charset=utf-8'},
                  body: jsonEncode({
                    'fecha': fecha,
                    'hora': hora,
                  }),
                )
                .timeout(ConfiguracionServidor.tiempoEspera);

            if (respuesta.statusCode == 401) {
              return;
            }

            if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
              final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
              final estadoFinal = datos['estado']?.toString() ?? estado;
              final respuestaPacienteFinal = datos['respuestaPaciente']?.toString() ?? 'SIN_RESPUESTA';
              await db.update(
                'turnos',
                {
                  'estado': estadoFinal,
                  'respuestaPaciente': respuestaPacienteFinal,
                  'sincronizado': 1,
                  'operacionPendiente': null,
                  'origenPendiente': null,
                  'errorSincronizacion': null,
                },
                where: 'id = ?',
                whereArgs: [id],
              );
            } else {
              final codigoError = await _manejarErrorHttp(id, respuesta);
              if (_esErrorDeServidorHandled(respuesta.statusCode)) {
                erroresTotal++;
                if (codigoError == 'HORARIO_OCUPADO') {
                  huboHorarioOcupado = true;
                }
                if (id >= 0) {
                  await _restaurarEstadoRealServidor(id, db);
                }
              }
            }
          } else if (operacion == 'CAMBIAR_ESTADO') {
            final bodyMap = <String, dynamic>{
              'estado': estado.toUpperCase(),
            };
            if (origenPendiente != null && origenPendiente.isNotEmpty) {
              bodyMap['origen'] = origenPendiente;
            }

            final respuesta = await _clienteHttp
                .patch(
                  Uri.parse(
                    '${ConfiguracionServidor.urlBase}/turnos/$id/estado',
                  ),
                  headers: {'Content-Type': 'application/json; charset=utf-8'},
                  body: jsonEncode(bodyMap),
                )
                .timeout(ConfiguracionServidor.tiempoEspera);

            if (respuesta.statusCode == 401) {
              return;
            }

            if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
              final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
              final estadoFinal = datos['estado']?.toString() ?? estado;
              final respuestaPacienteFinal = datos['respuestaPaciente']?.toString() ?? 'SIN_RESPUESTA';
              await db.update(
                'turnos',
                {
                  'estado': estadoFinal,
                  'respuestaPaciente': respuestaPacienteFinal,
                  'sincronizado': 1,
                  'operacionPendiente': null,
                  'origenPendiente': null,
                  'errorSincronizacion': null,
                },
                where: 'id = ?',
                whereArgs: [id],
              );
            } else {
              final codigoError = await _manejarErrorHttp(id, respuesta);
              if (_esErrorDeServidorHandled(respuesta.statusCode)) {
                erroresTotal++;
                if (codigoError == 'HORARIO_OCUPADO') {
                  huboHorarioOcupado = true;
                }
                if (id >= 0) {
                  await _restaurarEstadoRealServidor(id, db);
                }
              }
            }
          }
        } catch (_) {
          // Si falla por red, permanece pendiente para el próximo intento y NO cuenta como error del servidor.
        }
      }

      // Notifica si ocurrieron errores de servidor al sincronizar los turnos.
      if (erroresTotal > 0) {
        if (huboHorarioOcupado) {
          mostrarNotificacionAppGlobal(
            tipo: TipoNotificacionApp.error,
            titulo: 'No pudimos reservar un turno',
            mensaje: 'El horario ya fue tomado mientras estabas sin conexión. Entrá a Mis turnos para elegir otro.',
          );
        } else {
          mostrarNotificacionAppGlobal(
            tipo: TipoNotificacionApp.error,
            titulo: 'No pudimos enviar algunos cambios',
            mensaje: 'Revisá Mis turnos para ver el detalle.',
          );
        }
      }
    } finally {
      _sincronizando = false;
    }
  }

  bool _esErrorDeServidorHandled(int statusCode) {
    return statusCode >= 400 &&
        statusCode < 500 &&
        statusCode != 401 &&
        statusCode != 403 &&
        statusCode != 408 &&
        statusCode != 429;
  }

  // Registra el mensaje de error de la API y devuelve el código de error devuelto si existe.
  Future<String?> _manejarErrorHttp(int id, http.Response respuesta) async {
    String? codigoServidor;
    if (_esErrorDeServidorHandled(respuesta.statusCode)) {
      String detalle = 'Error HTTP ${respuesta.statusCode}';
      try {
        final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
        codigoServidor = datos['codigo']?.toString();
        final mensaje = datos['error']?.toString() ??
            datos['mensaje']?.toString() ??
            datos['message']?.toString();
        if (codigoServidor != null || mensaje != null) {
          detalle = [
            if (codigoServidor != null) codigoServidor,
            if (mensaje != null) mensaje,
          ].join(': ');
        }
      } catch (_) {}

      await repositorio.marcarErrorSincronizacion(id, detalle);
    }
    return codigoServidor;
  }

  // Restaura la información real del servidor en la base local si falla la reprogramación o cambio de estado de un turno existente.
  Future<void> _restaurarEstadoRealServidor(int id, dynamic db) async {
    try {
      final res = await _clienteHttp
          .get(Uri.parse('${ConfiguracionServidor.urlBase}/turnos/$id'))
          .timeout(ConfiguracionServidor.tiempoEspera);

      if (res.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(res.bodyBytes));
        await db.update(
          'turnos',
          {
            'fecha': datos['fecha']?.toString(),
            'hora': datos['hora']?.toString(),
            'estado': datos['estado']?.toString(),
            'respuestaPaciente': datos['respuestaPaciente']?.toString() ?? 'SIN_RESPUESTA',
            'sincronizado': 1,
            'operacionPendiente': null,
            'origenPendiente': null,
            'errorSincronizacion': null,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      } else if (res.statusCode == 404) {
        await db.delete('turnos', where: 'id = ?', whereArgs: [id]);
      }
    } catch (_) {}
  }
}
