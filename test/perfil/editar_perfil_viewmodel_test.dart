import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/autenticacion/datos/modelos/paciente.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/perfil/datos/modelos/excepcionPerfil.dart';
import 'package:mediturnos/perfil/datos/repositorios/repositorioPerfil.dart';
import 'package:mediturnos/perfil/presentacion/viewmodels/editarPerfilViewModel.dart';

class FakeRepositorioPerfil implements RepositorioPerfil {
  bool simularSinConexion = false;
  bool simularErrorTelefono400 = false;

  @override
  Future<Usuario> actualizarPerfil({
    required int id,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    if (simularSinConexion) {
      throw ExcepcionPerfil(ErrorPerfil.sinConexion);
    }
    if (simularErrorTelefono400) {
      throw ExcepcionPerfil(
        ErrorPerfil.datosInvalidos,
        mensaje: 'Teléfono inválido según servidor.',
        campo: 'telefono',
      );
    }
    return Usuario(
      id: id,
      nombre: nombre,
      apellido: apellido,
      email: 'test@correo.com',
      rol: RolUsuario.paciente,
      activo: true,
      fechaCreacion: '2026-01-01',
      paciente: Paciente(id: 10, dni: '38450123', telefono: telefono),
    );
  }
}

void main() {
  group('EditarPerfilViewModel Tests', () {
    late FakeRepositorioPerfil repo;
    late EditarPerfilViewModel vm;
    late Usuario usuarioPrueba;

    setUp(() {
      repo = FakeRepositorioPerfil();
      vm = EditarPerfilViewModel(repo);
      usuarioPrueba = Usuario(
        id: 1,
        nombre: 'Lucas',
        apellido: 'González',
        email: 'lucas@test.com',
        rol: RolUsuario.paciente,
        activo: true,
        fechaCreacion: '2026-01-01',
        paciente: Paciente(id: 10, dni: '38450123', telefono: '3841404667'),
      );
    });

    test('Guardar exitoso retorna usuario actualizado', () async {
      final res = await vm.guardar(
        usuario: usuarioPrueba,
        nombre: 'Lucas Editado',
        apellido: 'González',
        telefono: '3841404667',
      );

      expect(res, isNotNull);
      expect(res!.nombre, equals('Lucas Editado'));
      expect(vm.errorGeneral, isNull);
    });

    test('Error 400 en campo telefono mapea a errorTelefono', () async {
      repo.simularErrorTelefono400 = true;

      final res = await vm.guardar(
        usuario: usuarioPrueba,
        nombre: 'Lucas',
        apellido: 'González',
        telefono: '3841404667',
      );

      expect(res, isNull);
      expect(vm.errorTelefono, equals('Teléfono inválido según servidor.'));
    });

    test('Error sin conexión mapea a errorGeneral', () async {
      repo.simularSinConexion = true;

      final res = await vm.guardar(
        usuario: usuarioPrueba,
        nombre: 'Lucas',
        apellido: 'González',
        telefono: '3841404667',
      );

      expect(res, isNull);
      expect(vm.errorGeneral, equals('Necesitás conexión para guardar los cambios.'));
    });
  });
}
