import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/configuracion/configuracionServidor.dart';
import '../modelos/excepcionPerfil.dart';

// Cliente HTTP para consumir los endpoints de perfil en la API REST.
class ClientePerfilApi {
  final http.Client client;

  ClientePerfilApi({http.Client? client}) : client = client ?? http.Client();

  Uri _uri(String path) {
    return Uri.parse('${ConfiguracionServidor.urlBase}$path');
  }

  // Realiza la petición PUT /usuarios/{id}/perfil para actualizar los datos del usuario.
  Future<Usuario> actualizarPerfil({
    required int id,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    try {
      final bodyMap = <String, dynamic>{
        'nombre': nombre,
        'apellido': apellido,
      };
      if (telefono != null) {
        bodyMap['telefono'] = telefono;
      }

      final respuesta = await client
          .put(
            _uri('/usuarios/$id/perfil'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode(bodyMap),
          )
          .timeout(ConfiguracionServidor.tiempoEspera);

      final bodyStr = utf8.decode(respuesta.bodyBytes);
      final dynamic decoded = bodyStr.isNotEmpty ? json.decode(bodyStr) : {};

      if (respuesta.statusCode == 200) {
        return Usuario.fromJson(decoded as Map<String, dynamic>);
      }

      final errorMsg = decoded is Map ? decoded['error']?.toString() : null;
      final campoMsg = decoded is Map ? decoded['campo']?.toString() : null;

      if (respuesta.statusCode == 400) {
        throw ExcepcionPerfil(
          ErrorPerfil.datosInvalidos,
          mensaje: errorMsg ?? 'Datos inválidos.',
          campo: campoMsg,
        );
      } else if (respuesta.statusCode == 404) {
        throw ExcepcionPerfil(
          ErrorPerfil.usuarioNoEncontrado,
          mensaje: errorMsg ?? 'Usuario no encontrado.',
          campo: campoMsg,
        );
      } else if (respuesta.statusCode >= 500) {
        throw ExcepcionPerfil(
          ErrorPerfil.errorServidor,
          mensaje: errorMsg ?? 'Error interno del servidor.',
        );
      } else {
        throw ExcepcionPerfil(
          ErrorPerfil.desconocido,
          mensaje: errorMsg ?? 'Ocurrió un error inesperado.',
        );
      }
    } on SocketException catch (e) {
      debugPrint('API actualizarPerfil → $e');
      throw ExcepcionPerfil(ErrorPerfil.sinConexion);
    } on TimeoutException catch (e) {
      debugPrint('API actualizarPerfil → $e');
      throw ExcepcionPerfil(ErrorPerfil.sinConexion);
    } on http.ClientException catch (e) {
      debugPrint('API actualizarPerfil → $e');
      throw ExcepcionPerfil(ErrorPerfil.sinConexion);
    } on ExcepcionPerfil catch (e) {
      debugPrint('API actualizarPerfil → $e');
      rethrow;
    } catch (e) {
      debugPrint('API actualizarPerfil → $e');
      throw ExcepcionPerfil(ErrorPerfil.desconocido);
    }
  }
}
