import 'dart:convert';

import 'package:http/http.dart' as http;

import '../configuracion/configuracionServidor.dart';
import '../turnos/datos/modelos/turno.dart';
import '../turnos/datos/repositorios/repositorioTurnos.dart';

class ServicioSincronizacion {
  final RepositorioTurnos repositorio;

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
    final turnosPendientes = await obtenerTurnosPendientes();

    for (final turno in turnosPendientes) {
      if (turno.pacienteId == null ||
          turno.medicoId == null ||
          turno.claveSolicitud == null) {
        await repositorio.marcarErrorSincronizacion(
          turno.id,
          'Faltan datos necesarios para sincronizar el turno.',
        );
        continue;
      }

      try {
        final respuesta = await http
            .post(
              Uri.parse('${ConfiguracionServidor.urlBase}/turnos'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'paciente': {'id': turno.pacienteId},
                'medico': {'id': turno.medicoId},
                'fecha': turno.fecha,
                'hora': turno.hora,
                'estado': turno.estado.toUpperCase(),
                'claveSolicitud': turno.claveSolicitud,
              }),
            )
            .timeout(ConfiguracionServidor.tiempoEspera);

        if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
          final datos = jsonDecode(respuesta.body);

          final turnoSincronizado = Turno(
            id: datos['id'] as int,
            paciente: turno.paciente,
            medico: turno.medico,
            especialidad: turno.especialidad,
            fecha: turno.fecha,
            hora: turno.hora,
            estado: datos['estado']?.toString() ?? turno.estado,
            sincronizado: true,
            pacienteId: turno.pacienteId,
            medicoId: turno.medicoId,
            claveSolicitud: turno.claveSolicitud,
            errorSincronizacion: null,
          );

          await repositorio.reemplazarTurno(turno.id, turnoSincronizado);
        } else if (respuesta.statusCode >= 400 &&
            respuesta.statusCode < 500 &&
            respuesta.statusCode != 401 &&
            respuesta.statusCode != 403 &&
            respuesta.statusCode != 408 &&
            respuesta.statusCode != 429) {
          String detalle = 'Error HTTP ${respuesta.statusCode}';

          try {
            final datos = jsonDecode(respuesta.body);

            final codigo = datos['codigo']?.toString();
            final mensaje =
                datos['mensaje']?.toString() ?? datos['message']?.toString();

            if (codigo != null || mensaje != null) {
              detalle = [
                if (codigo != null) codigo,
                if (mensaje != null) mensaje,
              ].join(': ');
            }
          } catch (_) {
            // Se conserva el detalle HTTP si la respuesta no es JSON.
          }

          await repositorio.marcarErrorSincronizacion(turno.id, detalle);
        }
      } catch (e) {
        // Si falla, permanece pendiente para el próximo intento.
      }
    }
  }
}
