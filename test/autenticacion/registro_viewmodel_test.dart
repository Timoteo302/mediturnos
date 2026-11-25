import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/registroViewModel.dart';

class FakeRepositorioAutenticacion implements RepositorioAutenticacion {
  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) {
    throw UnimplementedError();
  }

  @override
  Future<Usuario> registrarPaciente({
    required String nombre,
    required String apellido,
    required String dni,
    required String telefono,
    required String email,
    required String contrasena,
  }) async {
    return Usuario(
      id: 1,
      nombre: nombre,
      apellido: apellido,
      email: email,
      rol: RolUsuario.paciente,
      activo: true,
      fechaCreacion: '2026-01-01',
    );
  }

  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) {
    throw UnimplementedError();
  }

  @override
  Future<void> restablecerContrasena({
    required String idRecuperacion,
    required String codigo,
    required String nuevaContrasena,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> actualizarCopiaLocal(Usuario usuario) async {}
}

void main() {
  group('RegistroViewModel - Pruebas de validación de teléfono', () {
    late RegistroViewModel vm;

    setUp(() {
      vm = RegistroViewModel(FakeRepositorioAutenticacion());
    });

    test('Teléfono vacío falla validación', () async {
      final exito = await vm.registrar(
        nombre: 'Lucas',
        apellido: 'González',
        dni: '38450123',
        telefono: '',
        email: 'lucas@test.com',
        contrasena: '12345678',
        confirmacion: '12345678',
      );

      expect(exito, isFalse);
      expect(vm.errorTelefono, equals('El teléfono es obligatorio.'));
    });

    test('Teléfono con letras sólo tiene dígitos no suficientes y falla validación', () async {
      final exito = await vm.registrar(
        nombre: 'Lucas',
        apellido: 'González',
        dni: '38450123',
        telefono: '3841abc',
        email: 'lucas@test.com',
        contrasena: '12345678',
        confirmacion: '12345678',
      );

      expect(exito, isFalse);
      expect(vm.errorTelefono, equals('El teléfono debe tener entre 8 y 15 dígitos.'));
    });

    test('Teléfono con 7 dígitos (menos de 8) falla validación', () async {
      final exito = await vm.registrar(
        nombre: 'Lucas',
        apellido: 'González',
        dni: '38450123',
        telefono: '1234567',
        email: 'lucas@test.com',
        contrasena: '12345678',
        confirmacion: '12345678',
      );

      expect(exito, isFalse);
      expect(vm.errorTelefono, equals('El teléfono debe tener entre 8 y 15 dígitos.'));
    });

    test('Teléfono válido de 10 dígitos pasa validación y registra exitosamente', () async {
      final exito = await vm.registrar(
        nombre: 'Lucas',
        apellido: 'González',
        dni: '38450123',
        telefono: '3841404667',
        email: 'lucas@test.com',
        contrasena: '12345678',
        confirmacion: '12345678',
      );

      expect(exito, isTrue);
      expect(vm.errorTelefono, isNull);
    });
  });

  group('RegistroViewModel - Pruebas de validación de DNI', () {
    late RegistroViewModel vm;

    setUp(() {
      vm = RegistroViewModel(FakeRepositorioAutenticacion());
    });

    test('validarDni("00000000") devuelve mensaje de error', () {
      final res = vm.validarDni('00000000');
      expect(res, isNotNull);
      expect(res, equals('El DNI debe tener 7 u 8 números, sin puntos, y no puede empezar con 0.'));
    });

    test('validarDni("0123456") devuelve mensaje de error', () {
      final res = vm.validarDni('0123456');
      expect(res, isNotNull);
    });

    test('validarDni("45858281") devuelve null (DNI válido)', () {
      final res = vm.validarDni('45858281');
      expect(res, isNull);
    });

    test('validarDni("1234567") devuelve null (DNI de 7 dígitos válido)', () {
      final res = vm.validarDni('1234567');
      expect(res, isNull);
    });
  });
}
