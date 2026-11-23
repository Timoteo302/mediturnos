import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';

class FakeStorageForVmTest extends Fake implements FlutterSecureStorage {
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

class RepositorioAutenticacionLoginTokenFake implements RepositorioAutenticacion {
  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async {
    return Usuario.fromJson({
      'id': 1,
      'nombre': 'Test',
      'apellido': 'User',
      'email': email,
      'rol': 'PACIENTE',
    });
  }

  @override
  Future<Usuario> registrarPaciente({required String nombre, required String apellido, required String dni, required String telefono, required String email, required String contrasena}) async => throw UnimplementedError();

  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) async => throw UnimplementedError();

  @override
  Future<void> restablecerContrasena({required String idRecuperacion, required String codigo, required String nuevaContrasena}) async {}

  @override
  Future<void> actualizarCopiaLocal(Usuario usuario) async {}
}

void main() {
  late FakeStorageForVmTest storageFake;
  late AlmacenToken almacenToken;
  late RepositorioAutenticacionLoginTokenFake repoFake;
  late AutenticacionViewModel authVm;

  setUp(() {
    storageFake = FakeStorageForVmTest();
    almacenToken = AlmacenToken(storage: storageFake);
    repoFake = RepositorioAutenticacionLoginTokenFake();
    authVm = AutenticacionViewModel(repoFake, almacenToken: almacenToken, limpiezaLocal: () async {});
  });

  tearDown(() {
    authVm.dispose();
  });

  test('Cerrar sesión borra el token guardado', () async {
    await almacenToken.guardar('token-123', DateTime.now().add(const Duration(hours: 1)));
    expect(await almacenToken.leerToken(), 'token-123');

    await authVm.cerrarSesion();
    expect(await almacenToken.leerToken(), isNull);
  });

  test('Entrar como invitado borra el token guardado', () async {
    await almacenToken.guardar('token-123', DateTime.now().add(const Duration(hours: 1)));
    expect(await almacenToken.leerToken(), 'token-123');

    authVm.entrarComoInvitado();
    expect(await almacenToken.leerToken(), isNull);
  });
}
