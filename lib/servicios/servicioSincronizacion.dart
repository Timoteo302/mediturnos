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

    return turnos.where((turno) => !turno.sincronizado).toList();
  }

  Future<void> sincronizar() async {
    final turnosPendientes = await obtenerTurnosPendientes();

    for (final turno in turnosPendientes) {
      if (turno.pacienteId == null ||
          turno.medicoId == null ||
          turno.claveSolicitud == null) {
        continue;
      }

      try {
        final respuesta = await http
            .post(
              Uri.parse('${ConfiguracionServidor.urlBase}/turnos'),
              headers: {
                'Content-Type': 'application/json',
              },
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

        if (respuesta.statusCode >= 200 &&
            respuesta.statusCode < 300) {
          final turnoSincronizado = Turno(
            id: turno.id,
            paciente: turno.paciente,
            medico: turno.medico,
            especialidad: turno.especialidad,
            fecha: turno.fecha,
            hora: turno.hora,
            estado: turno.estado,
            sincronizado: true,
            pacienteId: turno.pacienteId,
            medicoId: turno.medicoId,
            claveSolicitud: turno.claveSolicitud,
          );

          await repositorio.modificarTurno(turnoSincronizado);
        }
      } catch (e) {
        // Si falla la conexión, el turno permanece pendiente.
      }
    }
  }
}