import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../configuracion/configuracionServidor.dart';
import '../modelos/resultadoReservaInvitado.dart';
import '../modelos/excepcionInvitado.dart';

// Cliente HTTP encargado de consultar los endpoints de reservas e invitación en la API remota.
class ClienteInvitadoApi {
  final http.Client client;

  ClienteInvitadoApi(this.client);

  Uri _uri(String path) => Uri.parse('${ConfiguracionServidor.urlBase}$path');

  Future<Map<String, dynamic>> _procesarRespuesta(http.Response respuesta) async {
    final cuerpoDecodificado = utf8.decode(respuesta.bodyBytes);
    Map<String, dynamic> jsonCuerpo = {};
    try {
      if (cuerpoDecodificado.isNotEmpty) {
        jsonCuerpo = json.decode(cuerpoDecodificado);
      }
    } catch (_) {}

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return jsonCuerpo;
    }

    if (respuesta.statusCode >= 500) {
      throw ExcepcionInvitado(TipoErrorInvitado.errorServidor, mensaje: jsonCuerpo['error']?.toString());
    }

    final codigo = jsonCuerpo['codigo']?.toString() ?? '';
    final campo = jsonCuerpo['campo']?.toString();
    final mensaje = jsonCuerpo['error']?.toString() ?? jsonCuerpo['mensaje']?.toString();

    switch (codigo) {
      case 'DATOS_INVALIDOS':
        throw ExcepcionInvitado(TipoErrorInvitado.datosInvalidos, codigo: codigo, campo: campo, mensaje: mensaje);
      case 'CUENTA_EXISTENTE':
        throw ExcepcionInvitado(TipoErrorInvitado.cuentaExistente, codigo: codigo, campo: campo, mensaje: mensaje);
      case 'LIMITE_INVITADO':
        throw ExcepcionInvitado(TipoErrorInvitado.limiteInvitado, codigo: codigo, mensaje: mensaje);
      case 'HORARIO_OCUPADO':
        throw ExcepcionInvitado(TipoErrorInvitado.horarioOcupado, codigo: codigo, mensaje: mensaje);
      case 'CODIGO_INVALIDO':
        throw ExcepcionInvitado(TipoErrorInvitado.codigoInvalido, codigo: codigo, mensaje: mensaje);
      case 'CODIGO_VENCIDO':
        throw ExcepcionInvitado(TipoErrorInvitado.codigoVencido, codigo: codigo, mensaje: mensaje);
      case 'DEMASIADOS_INTENTOS':
        throw ExcepcionInvitado(TipoErrorInvitado.demasiadosIntentos, codigo: codigo, mensaje: mensaje);
      case 'ESPERA_PARA_REENVIAR':
        throw ExcepcionInvitado(TipoErrorInvitado.esperaParaReenviar, codigo: codigo, mensaje: mensaje);
      case 'ACTIVACION_NO_ENCONTRADA':
        throw ExcepcionInvitado(TipoErrorInvitado.activacionNoEncontrada, codigo: codigo, mensaje: mensaje);
      default:
        throw ExcepcionInvitado(TipoErrorInvitado.desconocido, codigo: codigo, mensaje: mensaje);
    }
  }

  // Realiza la petición POST /reservas/invitado para registrar un turno en modo invitado.
  Future<ResultadoReservaInvitado> reservarComoInvitado({
    required String nombre,
    required String apellido,
    required String dni,
    required String email,
    required String telefono,
    required int medicoId,
    required String fecha,
    required String hora,
    required String claveSolicitud,
  }) async {
    try {
      final respuesta = await client.post(
        _uri('/reservas/invitado'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'dni': dni,
          'email': email,
          'telefono': telefono,
          'medicoId': medicoId,
          'fecha': fecha,
          'hora': hora,
          'claveSolicitud': claveSolicitud,
        }),
      ).timeout(ConfiguracionServidor.tiempoEspera);

      final jsonMap = await _procesarRespuesta(respuesta);
      return ResultadoReservaInvitado.fromJson(jsonMap);
    } on SocketException catch (e) {
      debugPrint('API reservarComoInvitado → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on TimeoutException catch (e) {
      debugPrint('API reservarComoInvitado → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on http.ClientException catch (e) {
      debugPrint('API reservarComoInvitado → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on ExcepcionInvitado catch (e) {
      debugPrint('API reservarComoInvitado → $e');
      rethrow;
    } catch (e) {
      debugPrint('API reservarComoInvitado → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.desconocido);
    }
  }

  // Realiza la petición POST /activacion/confirmar para activar la cuenta con el código recibido.
  Future<Map<String, dynamic>> confirmarActivacion({
    required String email,
    required String codigo,
    required String contrasena,
  }) async {
    try {
      final respuesta = await client.post(
        _uri('/activacion/confirmar'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'email': email,
          'codigo': codigo,
          'contrasena': contrasena,
        }),
      ).timeout(ConfiguracionServidor.tiempoEspera);

      return await _procesarRespuesta(respuesta);
    } on SocketException catch (e) {
      debugPrint('API confirmarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on TimeoutException catch (e) {
      debugPrint('API confirmarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on http.ClientException catch (e) {
      debugPrint('API confirmarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on ExcepcionInvitado catch (e) {
      debugPrint('API confirmarActivacion → $e');
      rethrow;
    } catch (e) {
      debugPrint('API confirmarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.desconocido);
    }
  }

  // Realiza la petición POST /activacion/reenviar para solicitar un nuevo código de activación.
  Future<Map<String, dynamic>> reenviarActivacion({required String email}) async {
    try {
      final respuesta = await client.post(
        _uri('/activacion/reenviar'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'email': email}),
      ).timeout(ConfiguracionServidor.tiempoEspera);

      return await _procesarRespuesta(respuesta);
    } on SocketException catch (e) {
      debugPrint('API reenviarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on TimeoutException catch (e) {
      debugPrint('API reenviarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on http.ClientException catch (e) {
      debugPrint('API reenviarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.sinConexion);
    } on ExcepcionInvitado catch (e) {
      debugPrint('API reenviarActivacion → $e');
      rethrow;
    } catch (e) {
      debugPrint('API reenviarActivacion → $e');
      throw ExcepcionInvitado(TipoErrorInvitado.desconocido);
    }
  }
}
