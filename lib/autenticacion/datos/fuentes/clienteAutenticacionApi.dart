import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../configuracion/configuracionServidor.dart';
import '../modelos/usuario.dart';
import '../modelos/solicitudRecuperacion.dart';
import '../modelos/excepcionAutenticacion.dart';

class ClienteAutenticacionApi {
  final http.Client client;

  ClienteAutenticacionApi(this.client);

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
      throw ExcepcionAutenticacion(ErrorAutenticacion.errorServidor);
    }

    final codigo = jsonCuerpo['codigo']?.toString() ?? '';
    final campo = jsonCuerpo['campo']?.toString();
    final intentos = jsonCuerpo['intentosRestantes'] is int 
        ? jsonCuerpo['intentosRestantes'] 
        : int.tryParse(jsonCuerpo['intentosRestantes']?.toString() ?? '');

    switch (codigo) {
      case 'CREDENCIALES_INVALIDAS':
        throw ExcepcionAutenticacion(ErrorAutenticacion.credencialesInvalidas);
      case 'CUENTA_INACTIVA':
        throw ExcepcionAutenticacion(ErrorAutenticacion.cuentaInactiva);
      case 'EMAIL_DUPLICADO':
        throw ExcepcionAutenticacion(ErrorAutenticacion.emailDuplicado, campo: campo);
      case 'DNI_DUPLICADO':
        throw ExcepcionAutenticacion(ErrorAutenticacion.dniDuplicado, campo: campo);
      case 'CUENTA_NO_ENCONTRADA':
        throw ExcepcionAutenticacion(ErrorAutenticacion.cuentaNoEncontrada);
      case 'DATOS_INVALIDOS':
        throw ExcepcionAutenticacion(ErrorAutenticacion.datosInvalidos, campo: campo);
      case 'CODIGO_INVALIDO':
        throw ExcepcionAutenticacion(ErrorAutenticacion.codigoInvalido, intentosRestantes: intentos);
      case 'CODIGO_VENCIDO':
        throw ExcepcionAutenticacion(ErrorAutenticacion.codigoVencido);
      case 'DEMASIADOS_INTENTOS':
        throw ExcepcionAutenticacion(ErrorAutenticacion.demasiadosIntentos);
      case 'SOLICITUD_NO_ENCONTRADA':
        throw ExcepcionAutenticacion(ErrorAutenticacion.solicitudNoEncontrada);
      default:
        throw ExcepcionAutenticacion(ErrorAutenticacion.desconocido);
    }
  }

  Future<Usuario> iniciarSesion(String email, String contrasena) async {
    try {
      final respuesta = await client.post(
        _uri('/login'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'email': email, 'contrasena': contrasena}),
      ).timeout(ConfiguracionServidor.tiempoEspera);

      final jsonMap = await _procesarRespuesta(respuesta);
      return Usuario.fromJson(jsonMap);
    } on SocketException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on TimeoutException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on http.ClientException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on ExcepcionAutenticacion {
      rethrow;
    } catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    }
  }

  Future<Usuario> registrarPaciente({
    required String nombre,
    required String apellido,
    required String dni,
    required String email,
    required String contrasena,
  }) async {
    try {
      final respuesta = await client.post(
        _uri('/usuarios'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'contrasena': contrasena,
          'dni': dni,
        }),
      ).timeout(ConfiguracionServidor.tiempoEspera);

      final jsonMap = await _procesarRespuesta(respuesta);
      return Usuario.fromJson(jsonMap);
    } on SocketException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on TimeoutException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on http.ClientException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on ExcepcionAutenticacion {
      rethrow;
    } catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    }
  }

  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) async {
    try {
      final body = <String, dynamic>{};
      if (email != null) body['email'] = email;
      if (dni != null) body['dni'] = dni;

      final respuesta = await client.post(
        _uri('/recuperacion/solicitar'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(body),
      ).timeout(ConfiguracionServidor.tiempoEspera);

      final jsonMap = await _procesarRespuesta(respuesta);
      return SolicitudRecuperacion.fromJson(jsonMap);
    } on SocketException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on TimeoutException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on http.ClientException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on ExcepcionAutenticacion {
      rethrow;
    } catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    }
  }

  Future<void> restablecerContrasena({
    required String idRecuperacion,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    try {
      final respuesta = await client.post(
        _uri('/recuperacion/restablecer'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'idRecuperacion': idRecuperacion,
          'codigo': codigo,
          'nuevaContrasena': nuevaContrasena,
        }),
      ).timeout(ConfiguracionServidor.tiempoEspera);

      await _procesarRespuesta(respuesta);
    } on SocketException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on TimeoutException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on http.ClientException catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    } on ExcepcionAutenticacion {
      rethrow;
    } catch (_) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    }
  }
}
