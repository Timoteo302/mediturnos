import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mediturnos/turnos/datos/fuentes/clienteTurnosApi.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/excepcionTurnos.dart';

void main() {
  group('ClienteTurnosApi Tests', () {
    test('obtenerTurnos exitoso con filtros', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/turnos');
        expect(request.url.queryParameters['pacienteId'], '1');
        return http.Response(
          json.encode([
            {
              'id': 12,
              'estado': 'PENDIENTE',
              'fecha': '2026-11-13',
              'hora': '09:30',
              'paciente': {'id': 1, 'nombre': 'Matías', 'apellido': 'Romero', 'dni': '36782904'},
              'medico': {'id': 3, 'nombre': 'Ramiro', 'apellido': 'Vaca', 'especialidad': {'id': 6, 'nombre': 'Traumatología'}}
            }
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final cliente = ClienteTurnosApi(mockClient);
      final turnos = await cliente.obtenerTurnos(pacienteId: 1);
      expect(turnos.length, 1);
      expect(turnos[0].id, 12);
    });

    test('solicitarTurno con HORARIO_OCUPADO lanza excepcion horarioOcupado', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/turnos');
        final body = json.decode(request.body);
        expect(body['paciente']['id'], 1);
        expect(body['medico']['id'], 3);
        return http.Response(
          json.encode({'error': 'Horario ocupado', 'codigo': 'HORARIO_OCUPADO'}),
          409,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final cliente = ClienteTurnosApi(mockClient);
      expect(
        () => cliente.solicitarTurno(
          pacienteId: 1,
          medicoId: 3,
          fecha: DateTime(2026, 11, 13),
          hora: '09:30',
          claveSolicitud: 'uuid-test',
        ),
        throwsA(isA<ExcepcionTurnos>().having((e) => e.tipo, 'tipo', ErrorTurnos.horarioOcupado)),
      );
    });
  });
}
