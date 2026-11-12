import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mediturnos/medicos/datos/fuentes/clienteMedicosApi.dart';
import 'package:mediturnos/medicos/datos/modelos/excepcionMedicos.dart';

void main() {
  group('ClienteMedicosApi Tests', () {
    test('obtenerMedicos exitoso con incluirInactivos=true', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/medicos');
        expect(request.url.queryParameters['incluirInactivos'], 'true');
        return http.Response(
          json.encode([
            {
              'id': 1,
              'nombre': 'Juan',
              'apellido': 'Pérez',
              'matricula': '1234',
              'activo': true,
              'especialidad': {'id': 1, 'nombre': 'Cardiología', 'activo': true}
            }
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final cliente = ClienteMedicosApi(mockClient);
      final medicos = await cliente.obtenerMedicos(incluirInactivos: true);
      expect(medicos.length, 1);
      expect(medicos[0].nombre, 'Juan');
    });

    test('crearMedico con MATRICULA_DUPLICADA lanza excepcion matriculaDuplicada', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/medicos');
        return http.Response(
          json.encode({'error': 'Matrícula duplicada', 'codigo': 'MATRICULA_DUPLICADA', 'campo': 'matricula'}),
          409,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final cliente = ClienteMedicosApi(mockClient);
      expect(
        () => cliente.crearMedico(
          nombre: 'Ana',
          apellido: 'Gómez',
          especialidadId: 1,
          matricula: '1234',
          activo: true,
        ),
        throwsA(isA<ExcepcionMedicos>().having((e) => e.tipo, 'tipo', ErrorMedicos.matriculaDuplicada)),
      );
    });

    test('cambiarEstadoMedico PATCH a /estado exitoso', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/medicos/5/estado');
        final body = json.decode(request.body);
        expect(body['activo'], false);
        return http.Response(
          json.encode({
            'id': 5,
            'nombre': 'Carlos',
            'apellido': 'Ruiz',
            'matricula': '9999',
            'activo': false,
            'especialidad': {'id': 2, 'nombre': 'Pediatría', 'activo': true}
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final cliente = ClienteMedicosApi(mockClient);
      final medico = await cliente.cambiarEstadoMedico(5, false);
      expect(medico.activo, false);
    });
  });
}
