import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../configuracion/configuracionServidor.dart';
import '../../../turnos/datos/modelos/excepcionTurnos.dart';
import '../modelos/notificacion.dart';

// Cliente HTTP para consultar los endpoints de notificaciones en el backend.
class ClienteNotificacionesApi {
  final http.Client client;

  ClienteNotificacionesApi(this.client);

  Uri _uri(String path) => Uri.parse('${ConfiguracionServidor.urlBase}$path');

  // Método auxiliar privado para ejecutar llamadas HTTP centralizadas con timeout y control de errores.
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

      final mensaje = jsonCuerpo is Map ? jsonCuerpo['error']?.toString() : null;
      throw ExcepcionTurnos(ErrorTurnos.desconocido, mensajeServidor: mensaje);
    } on SocketException catch (e) {
      debugPrint('API notificaciones $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.sinConexion);
    } on TimeoutException catch (e) {
      debugPrint('API notificaciones $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.sinConexion);
    } on http.ClientException catch (e) {
      debugPrint('API notificaciones $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.sinConexion);
    } on ExcepcionTurnos catch (e) {
      debugPrint('API notificaciones $metodoNombre → $e');
      rethrow;
    } catch (e) {
      debugPrint('API notificaciones $metodoNombre → $e');
      throw ExcepcionTurnos(ErrorTurnos.desconocido);
    }
  }

  // Obtiene la lista completa de notificaciones de un usuario.
  Future<List<Notificacion>> obtenerNotificaciones({required int usuarioId}) async {
    final res = await _ejecutarLlamada(
      'obtenerNotificaciones',
      () => client.get(_uri('/notificaciones?usuarioId=$usuarioId')),
    );
    return (res as List).map((x) => Notificacion.fromJson(x)).toList();
  }

  // Obtiene la cantidad de notificaciones no leídas para el contador de la campanita.
  Future<int> obtenerCantidadNoLeidas({required int usuarioId}) async {
    final res = await _ejecutarLlamada(
      'obtenerCantidadNoLeidas',
      () => client.get(_uri('/notificaciones/no-leidas?usuarioId=$usuarioId')),
    );
    if (res is Map && res.containsKey('cantidad')) {
      return (res['cantidad'] as num).toInt();
    }
    return 0;
  }

  // Marca una notificación específica como leída.
  Future<void> marcarLeida({required int id}) async {
    await _ejecutarLlamada(
      'marcarLeida',
      () => client.patch(_uri('/notificaciones/$id/leida')),
    );
  }

  // Marca todas las notificaciones de un usuario como leídas.
  Future<void> marcarTodasLeidas({required int usuarioId}) async {
    await _ejecutarLlamada(
      'marcarTodasLeidas',
      () => client.patch(_uri('/notificaciones/leidas?usuarioId=$usuarioId')),
    );
  }
}
