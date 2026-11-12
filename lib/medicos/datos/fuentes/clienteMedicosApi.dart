import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../configuracion/configuracionServidor.dart';
import '../modelos/medico.dart';
import '../modelos/especialidad.dart';
import '../modelos/horarioAtencion.dart';
import '../modelos/excepcionMedicos.dart';

class ClienteMedicosApi {
  final http.Client client;

  ClienteMedicosApi(this.client);

  Uri _uri(String path) => Uri.parse('${ConfiguracionServidor.urlBase}$path');

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
        throw ExcepcionMedicos(ErrorMedicos.errorServidor, mensajeServidor: jsonCuerpo is Map ? jsonCuerpo['error']?.toString() : null);
      }

      final codigo = jsonCuerpo is Map ? jsonCuerpo['codigo']?.toString() ?? '' : '';
      final campo = jsonCuerpo is Map ? jsonCuerpo['campo']?.toString() : null;
      final mensaje = jsonCuerpo is Map ? jsonCuerpo['error']?.toString() : null;

      switch (codigo) {
        case 'DATOS_INVALIDOS':
          throw ExcepcionMedicos(ErrorMedicos.datosInvalidos, campo: campo, mensajeServidor: mensaje);
        case 'MATRICULA_DUPLICADA':
          throw ExcepcionMedicos(ErrorMedicos.matriculaDuplicada, campo: campo, mensajeServidor: mensaje);
        case 'MEDICO_NO_ENCONTRADO':
          throw ExcepcionMedicos(ErrorMedicos.medicoNoEncontrado, mensajeServidor: mensaje);
        case 'ESPECIALIDAD_DUPLICADA':
          throw ExcepcionMedicos(ErrorMedicos.especialidadDuplicada, campo: campo, mensajeServidor: mensaje);
        case 'ESPECIALIDAD_EN_USO':
          throw ExcepcionMedicos(ErrorMedicos.especialidadEnUso, mensajeServidor: mensaje);
        case 'ESPECIALIDAD_NO_ENCONTRADA':
          throw ExcepcionMedicos(ErrorMedicos.especialidadNoEncontrada, mensajeServidor: mensaje);
        default:
          throw ExcepcionMedicos(ErrorMedicos.desconocido, mensajeServidor: mensaje);
      }
    } on SocketException catch (e) {
      debugPrint('API medicos $metodoNombre → $e');
      throw ExcepcionMedicos(ErrorMedicos.sinConexion);
    } on TimeoutException catch (e) {
      debugPrint('API medicos $metodoNombre → $e');
      throw ExcepcionMedicos(ErrorMedicos.sinConexion);
    } on http.ClientException catch (e) {
      debugPrint('API medicos $metodoNombre → $e');
      throw ExcepcionMedicos(ErrorMedicos.sinConexion);
    } on ExcepcionMedicos catch (e) {
      debugPrint('API medicos $metodoNombre → $e');
      rethrow;
    } catch (e) {
      debugPrint('API medicos $metodoNombre → $e');
      throw ExcepcionMedicos(ErrorMedicos.desconocido);
    }
  }

  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false}) async {
    final res = await _ejecutarLlamada(
      'obtenerMedicos',
      () => client.get(_uri('/medicos?incluirInactivos=$incluirInactivos')),
    );
    return (res as List).map((x) => Medico.fromJson(x)).toList();
  }

  Future<Medico> crearMedico({
    required String nombre,
    required String apellido,
    required int especialidadId,
    required String matricula,
    required bool activo,
  }) async {
    final res = await _ejecutarLlamada(
      'crearMedico',
      () => client.post(
        _uri('/medicos'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'especialidadId': especialidadId,
          'matricula': matricula,
          'activo': activo,
        }),
      ),
    );
    return Medico.fromJson(res);
  }

  Future<Medico> actualizarMedico(
    int id, {
    required String nombre,
    required String apellido,
    required int especialidadId,
    required String matricula,
    required bool activo,
  }) async {
    final res = await _ejecutarLlamada(
      'actualizarMedico',
      () => client.put(
        _uri('/medicos/$id'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'especialidadId': especialidadId,
          'matricula': matricula,
          'activo': activo,
        }),
      ),
    );
    return Medico.fromJson(res);
  }

  Future<Medico> cambiarEstadoMedico(int id, bool activo) async {
    final res = await _ejecutarLlamada(
      'cambiarEstadoMedico',
      () => client.patch(
        _uri('/medicos/$id/estado'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'activo': activo}),
      ),
    );
    return Medico.fromJson(res);
  }

  Future<List<Especialidad>> obtenerEspecialidades({bool incluirInactivas = false}) async {
    final res = await _ejecutarLlamada(
      'obtenerEspecialidades',
      () => client.get(_uri('/especialidades?incluirInactivas=$incluirInactivas')),
    );
    return (res as List).map((x) => Especialidad.fromJson(x)).toList();
  }

  Future<Especialidad> crearEspecialidad({required String nombre, String? descripcion}) async {
    final res = await _ejecutarLlamada(
      'crearEspecialidad',
      () => client.post(
        _uri('/especialidades'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'nombre': nombre, 'descripcion': descripcion}),
      ),
    );
    return Especialidad.fromJson(res);
  }

  Future<Especialidad> actualizarEspecialidad(int id, {required String nombre, String? descripcion}) async {
    final res = await _ejecutarLlamada(
      'actualizarEspecialidad',
      () => client.put(
        _uri('/especialidades/$id'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'nombre': nombre, 'descripcion': descripcion}),
      ),
    );
    return Especialidad.fromJson(res);
  }

  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo) async {
    final res = await _ejecutarLlamada(
      'cambiarEstadoEspecialidad',
      () => client.patch(
        _uri('/especialidades/$id/estado'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'activo': activo}),
      ),
    );
    return Especialidad.fromJson(res);
  }

  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) async {
    final res = await _ejecutarLlamada(
      'obtenerHorarios',
      () => client.get(_uri('/medicos/$medicoId/horarios')),
    );
    return (res as List).map((x) => HorarioAtencion.fromJson(x)).toList();
  }

  Future<List<HorarioAtencion>> guardarHorarios(int medicoId, List<HorarioAtencion> horarios) async {
    final res = await _ejecutarLlamada(
      'guardarHorarios',
      () => client.put(
        _uri('/medicos/$medicoId/horarios'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'horarios': horarios.map((h) => h.toJson()).toList(),
        }),
      ),
    );
    return (res as List).map((x) => HorarioAtencion.fromJson(x)).toList();
  }
}
