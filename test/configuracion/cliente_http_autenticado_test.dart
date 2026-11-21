import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';
import 'package:mediturnos/configuracion/clienteHttpAutenticado.dart';

class FakeStorageForHttpTest extends Fake implements FlutterSecureStorage {
  final Map<String, String> _datos = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _datos[key] = value;
    } else {
      _datos.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _datos[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _datos.remove(key);
  }
}

void main() {
  late FakeStorageForHttpTest storageFake;
  late AlmacenToken almacenToken;

  setUp(() {
    storageFake = FakeStorageForHttpTest();
    almacenToken = AlmacenToken(storage: storageFake);
  });

  test('Agrega el encabezado Authorization cuando existe un token vigente', () async {
    await almacenToken.guardar('token-jwt-super-seguro', DateTime.now().add(const Duration(hours: 2)));

    String? headerAuthRecibido;
    final inner = MockClient((request) async {
      headerAuthRecibido = request.headers['Authorization'];
      return http.Response('{"estado":"ok"}', 200);
    });

    final cliente = ClienteHttpAutenticado(inner, almacenToken: almacenToken);
    await cliente.get(Uri.parse('http://localhost:8080/turnos'));

    expect(headerAuthRecibido, 'Bearer token-jwt-super-seguro');
  });

  test('No agrega encabezado Authorization si no hay token guardado', () async {
    String? headerAuthRecibido;
    final inner = MockClient((request) async {
      headerAuthRecibido = request.headers['Authorization'];
      return http.Response('{"estado":"ok"}', 200);
    });

    final cliente = ClienteHttpAutenticado(inner, almacenToken: almacenToken);
    await cliente.get(Uri.parse('http://localhost:8080/salud'));

    expect(headerAuthRecibido, isNull);
  });

  test('Llama a alSesionVencida una sola vez cuando recibe 401 con token', () async {
    await almacenToken.guardar('token-expirado', DateTime.now().add(const Duration(hours: 2)));

    int llamadasCallback = 0;
    final inner = MockClient((request) async {
      return http.Response('{"codigo":"NO_AUTENTICADO"}', 401);
    });

    final cliente = ClienteHttpAutenticado(
      inner,
      almacenToken: almacenToken,
      alSesionVencida: () {
        llamadasCallback++;
      },
    );

    await cliente.get(Uri.parse('http://localhost:8080/turnos'));
    await cliente.get(Uri.parse('http://localhost:8080/turnos'));

    expect(llamadasCallback, 1);
  });

  test('No llama a alSesionVencida si recibe 401 sin token (ej: login fallido)', () async {
    int llamadasCallback = 0;
    final inner = MockClient((request) async {
      return http.Response('{"codigo":"CREDENCIALES_INVALIDAS"}', 401);
    });

    final cliente = ClienteHttpAutenticado(
      inner,
      almacenToken: almacenToken,
      alSesionVencida: () {
        llamadasCallback++;
      },
    );

    await cliente.post(Uri.parse('http://localhost:8080/login'));

    expect(llamadasCallback, 0);
  });
}
