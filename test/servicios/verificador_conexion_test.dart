import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mediturnos/servicios/verificadorConexion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return ['wifi'];
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      null,
    );
  });

  group('Pruebas de VerificadorConexion con endpoint /salud', () {
    test('tieneConexionReal devuelve true cuando /salud responde HTTP 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/salud'));
        return http.Response(jsonEncode({'estado': 'ok'}), 200);
      });

      final conectado = await VerificadorConexion.tieneConexionReal(clienteHttp: mockClient);
      expect(conectado, isTrue);
    });

    test('tieneConexionReal devuelve false cuando /salud responde HTTP 500', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/salud'));
        return http.Response('Error interno', 500);
      });

      final conectado = await VerificadorConexion.tieneConexionReal(clienteHttp: mockClient);
      expect(conectado, isFalse);
    });

    test('tieneConexionReal devuelve false cuando ocurre una excepción de red', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Error de red al conectar con /salud');
      });

      final conectado = await VerificadorConexion.tieneConexionReal(clienteHttp: mockClient);
      expect(conectado, isFalse);
    });
  });
}
