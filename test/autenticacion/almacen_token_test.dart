import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';

class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
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
  late FakeFlutterSecureStorage storageFake;
  late AlmacenToken almacenToken;

  setUp(() {
    storageFake = FakeFlutterSecureStorage();
    almacenToken = AlmacenToken(storage: storageFake);
  });

  test('Guarda y lee un token vigente', () async {
    final venceEn = DateTime.now().add(const Duration(hours: 1));
    await almacenToken.guardar('token-valido-123', venceEn);

    final token = await almacenToken.leerToken();
    expect(token, 'token-valido-123');
  });

  test('Devuelve null si el token ya venció', () async {
    final venceEnPasado = DateTime.now().subtract(const Duration(minutes: 5));
    await almacenToken.guardar('token-vencido-123', venceEnPasado);

    final token = await almacenToken.leerToken();
    expect(token, isNull);
  });

  test('Borra el token guardado', () async {
    final venceEn = DateTime.now().add(const Duration(hours: 1));
    await almacenToken.guardar('token-test', venceEn);

    await almacenToken.borrar();
    final token = await almacenToken.leerToken();
    expect(token, isNull);
  });
}
