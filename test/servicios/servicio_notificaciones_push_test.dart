import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/servicios/servicioNotificacionesPush.dart';

class FakeFirebaseMessaging extends Fake implements FirebaseMessaging {
  String? tokenActual = 'fcm_token_test_123';
  bool tokenBorrado = false;

  @override
  Future<String?> getToken({String? vapidKey}) async {
    return tokenActual;
  }

  @override
  Future<void> deleteToken() async {
    tokenBorrado = true;
    tokenActual = null;
  }

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
}

class FakeStorageForPushTest extends Fake implements FlutterSecureStorage {
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

class RepositorioAuthFake extends Fake implements RepositorioAutenticacion {
  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async {
    return Usuario(
      id: 1,
      nombre: 'Test',
      apellido: 'User',
      email: email,
      rol: RolUsuario.paciente,
      activo: true,
      fechaCreacion: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> actualizarCopiaLocal(Usuario u) async {}
}

void main() {
  late FakeFirebaseMessaging fakeMessaging;
  late FakeStorageForPushTest fakeStorage;

  setUp(() {
    fakeMessaging = FakeFirebaseMessaging();
    fakeStorage = FakeStorageForPushTest();
  });

  test('registrar() hace PUT /dispositivos/{installationId} con el token FCM', () async {
    String? metodoRecibido;
    String? pathRecibido;
    Map<String, dynamic>? bodyRecibido;

    final mockClient = MockClient((request) async {
      metodoRecibido = request.method;
      pathRecibido = request.url.path;
      bodyRecibido = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response('', 204);
    });

    final servicioPush = ServicioNotificacionesPush(
      messaging: fakeMessaging,
      storage: fakeStorage,
      httpClient: mockClient,
    );

    final installationId = await servicioPush.obtenerInstallationId();
    await servicioPush.registrar();

    expect(metodoRecibido, 'PUT');
    expect(pathRecibido, '/dispositivos/$installationId');
    expect(bodyRecibido?['tokenFcm'], 'fcm_token_test_123');
  });

  test('desregistrar() hace DELETE /dispositivos/{installationId} y borra token FCM', () async {
    String? metodoRecibido;
    String? pathRecibido;

    final mockClient = MockClient((request) async {
      metodoRecibido = request.method;
      pathRecibido = request.url.path;
      return http.Response('', 204);
    });

    final servicioPush = ServicioNotificacionesPush(
      messaging: fakeMessaging,
      storage: fakeStorage,
      httpClient: mockClient,
    );

    final installationId = await servicioPush.obtenerInstallationId();
    await servicioPush.desregistrar();

    expect(metodoRecibido, 'DELETE');
    expect(pathRecibido, '/dispositivos/$installationId');
    expect(fakeMessaging.tokenBorrado, isTrue);
  });

  test('Error de red en registrar() NO lanza excepción', () async {
    final mockClient = MockClient((request) async {
      throw const SocketException('Sin conexión');
    });

    final servicioPush = ServicioNotificacionesPush(
      messaging: fakeMessaging,
      storage: fakeStorage,
      httpClient: mockClient,
    );

    expect(servicioPush.registrar(), completes);
  });

  test('installationId se genera una vez y se reutiliza en llamadas subsecuentes', () async {
    final servicioPush = ServicioNotificacionesPush(
      messaging: fakeMessaging,
      storage: fakeStorage,
    );

    final id1 = await servicioPush.obtenerInstallationId();
    final id2 = await servicioPush.obtenerInstallationId();

    expect(id1, isNotEmpty);
    expect(id1, equals(id2));
  });

  test('cerrarSesion() llama a desregistrar() antes de borrar el token JWT', () async {
    bool desregistradoLlamado = false;
    bool tokenBorrado = false;

    final storageToken = FakeStorageForPushTest();
    final almacenToken = AlmacenToken(storage: storageToken);
    await almacenToken.guardar('jwt-activo', DateTime.now().add(const Duration(hours: 1)));

    final mockClient = MockClient((request) async {
      if (request.method == 'DELETE') {
        desregistradoLlamado = true;
        final token = await storageToken.read(key: 'mediturnos_jwt_token');
        if (token == null) {
          tokenBorrado = true;
        }
      }
      return http.Response('', 204);
    });

    final servicioPush = ServicioNotificacionesPush(
      messaging: fakeMessaging,
      storage: fakeStorage,
      httpClient: mockClient,
    );

    final authVm = AutenticacionViewModel(
      RepositorioAuthFake(),
      almacenToken: almacenToken,
      limpiezaLocal: () async {},
      servicioPush: servicioPush,
    );

    await authVm.cerrarSesion();

    expect(desregistradoLlamado, isTrue);
    expect(tokenBorrado, isFalse, reason: 'El token JWT NO debía estar borrado al momento de llamar a desregistrar()');
  });

  test('Modo invitado no llama a registrar()', () async {
    bool registradorLlamado = false;

    final mockClient = MockClient((request) async {
      if (request.method == 'PUT') {
        registradorLlamado = true;
      }
      return http.Response('', 204);
    });

    final servicioPush = ServicioNotificacionesPush(
      messaging: fakeMessaging,
      storage: fakeStorage,
      httpClient: mockClient,
    );

    final authVm = AutenticacionViewModel(
      RepositorioAuthFake(),
      limpiezaLocal: () async {},
      servicioPush: servicioPush,
    );

    authVm.entrarComoInvitado();

    expect(authVm.esInvitado, isTrue);
    expect(registradorLlamado, isFalse);
  });
}
