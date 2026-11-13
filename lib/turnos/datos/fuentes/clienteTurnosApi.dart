import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../configuracion/configuracionServidor.dart';
import '../modelos/turnoDetalle.dart';
import '../modelos/horarioDisponible.dart';
import '../modelos/estadoTurno.dart';
import '../modelos/excepcionTurnos.dart';

/// Cliente remoto HTTP para interactuar con la API de turnos.
class ClienteTurnosApi {
  final http.Client client;

  ClienteTurnosApi(this.client);

  Uri _uri(String path) => Uri.parse('${ConfiguracionServidor.urlBase}$path');

  /// Método privado centralizado para ejecutar llamadas HTTP con timeout y traducción de errores.
  Future<dynamic> _ejecutarLlamada(
    String metodoNombre,
    Future<http.Response> Function() llamada,
  ) async {
    try {
      final respuesta = await llamada().timeout(ConfiguracionServidor.tiempoEspera);
      final cuerpoDecodificado = utf8.decode(respuesta.bodyBytes);
      dynamic jsonCuerpo;
      try {
        if (cuerpoDecodificado.isNotEmpty) {
          jsonCuerpo = json.decode(cuerpoDecodificado);
        }
      } catch (_) {}

      if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
        return jsonCuerpo;
      }

      if (respuesta.statusCode >= 500) {
        throw ExcepcionTurnos(ErrorTurnos.errorServidor, mensajeServidor: jsonCuerpo is Map ? jsonCuerpo['error']?.toString() : null);
      }

      final codigo = jsonCuerpo is Map ? jsonCuerpo['codigo']?.toString() ?? '' : '';
      final campo = jsonCuerpo is Map ? jsonCuerpo['campo']?.toString() : null;
      final mensaje = jsonCuerpo is Map ? jsonCuerpo['error']?.toString() : null;

      switch (codigo) {
        case 'DATOS_INVALIDOS':
          throw ExcepcionTurnos(ErrorTurnos.datosInvalidos, campo: campo, mensajeServidor: mensaje);
        case 'HORARIO_OCUPADO':
          throw ExcepcionTurnos(ErrorTurnos.horarioOcupado, mensajeServidor: mensaje);
        case 'HORARIO_NO_DISPONIBLE':
          throw ExcepcionTurnos(ErrorTurnos.horarioNoDisponible, mensajeServidor: mensaje);
        case 'TURNO_NO_ENCONTRADO':
          throw ExcepcionTurnos(ErrorTurnos.turnoNoEncontrado, mensajeServidor: mensaje);
        case 'TURNO_NO_MODIFICABLE':
          throw ExcepcionTurnos(ErrorTurnos.turnoNoModificable, mensajeServidor: mensaje);
        case 'TRANSICION_INVALIDA':
          throw ExcepcionTurnos(ErrorTurnos.transicionInvalida, mensajeServidor: mensaje);
        case 'MEDICO_NO_ENCONTRADO':
          throw ExcepcionTurnos(ErrorTurnos.medicoNoEncontrado, mensajeServidor: mensaje);
        case 'MEDICO_INACTIVO':
          throw ExcepcionTurnos(ErrorTurnos.medicoInactivo, mensajeServidor: mensaje);
        case 'PACIENTE_NO_ENCONTRADO':
          throw ExcepcionTurnos(ErrorTurnos.pacienteNoEncontrado, mensajeServidor: mensaje);
        default:
          throw ExcepcionTurnos(ErrorTurnos.desconocido, mensajeServidor: mensaje);
      }
    } on SocketException catch (e) {
      debugPrint('API turnos $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.sinConexion);
    } on TimeoutException catch (e) {
      debugPrint('API turnos $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.sinConexion);
    } on http.ClientException catch (e) {
      debugPrint('API turnos $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.sinConexion);
    } on ExcepcionTurnos catch (e) {
      debugPrint('API turnos $metodoNombre → $e');
      rethrow;
    } catch (e) {
      debugPrint('API turnos $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.desconocido);
    }
  }

  Future<List<TurnoDetalle>> obtenerTurnos({
    int? pacienteId,
    int? medicoId,
    DateTime? fecha,
    EstadoTurno? estado,
  }) async {
    final queryParams = <String, String>{};
    if (pacienteId != null) queryParams['pacienteId'] = pacienteId.toString();
    if (medicoId != null) queryParams['medicoId'] = medicoId.toString();
    if (fecha != null) {
      queryParams['fecha'] = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    }
    if (estado != null) queryParams['estado'] = estado.aTextoApi();

    final uri = _uri('/turnos').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final res = await _ejecutarLlamada(
      'obtenerTurnos',
      () => client.get(uri),
    );
    return (res as List).map((x) => TurnoDetalle.fromJson(x)).toList();
  }

  Future<TurnoDetalle> obtenerTurno(int id) async {
    final res = await _ejecutarLlamada(
      'obtenerTurno',
      () => client.get(_uri('/turnos/$id')),
    );
    return TurnoDetalle.fromJson(res);
  }

  Future<List<HorarioDisponible>> obtenerDisponibilidad({
    required int medicoId,
    required DateTime fecha,
  }) async {
    final fechaStr = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final res = await _ejecutarLlamada(
      'obtenerDisponibilidad',
      () => client.get(_uri('/medicos/$medicoId/disponibilidad?fecha=$fechaStr')),
    );
    return (res as List).map((x) => HorarioDisponible.fromJson(x)).toList();
  }

  Future<TurnoDetalle> solicitarTurno({
    required int pacienteId,
    required int medicoId,
    required DateTime fecha,
    required String hora,
    required String claveSolicitud,
  }) async {
    final fechaStr = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final res = await _ejecutarLlamada(
      'solicitarTurno',
      () => client.post(
        _uri('/turnos'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'paciente': {'id': pacienteId},
          'medico': {'id': medicoId},
          'fecha': fechaStr,
          'hora': hora,
          'estado': 'PENDIENTE',
          'claveSolicitud': claveSolicitud,
        }),
      ),
    );
    return TurnoDetalle.fromJson(res);
  }

  Future<TurnoDetalle> reprogramarTurno({
    required int turnoId,
    required DateTime fecha,
    required String hora,
  }) async {
    final fechaStr = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final res = await _ejecutarLlamada(
      'reprogramarTurno',
      () => client.put(
        _uri('/turnos/$turnoId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'fecha': fechaStr,
          'hora': hora,
        }),
      ),
    );
    return TurnoDetalle.fromJson(res);
  }

  Future<TurnoDetalle> cambiarEstadoTurno({
    required int turnoId,
    required EstadoTurno estado,
  }) async {
    final res = await _ejecutarLlamada(
      'cambiarEstadoTurno',
      () => client.patch(
        _uri('/turnos/$turnoId/estado'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'estado': estado.aTextoApi(),
        }),
      ),
    );
    return TurnoDetalle.fromJson(res);
  }
}
