import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/invitado/datos/modelos/excepcionInvitado.dart';
import 'package:mediturnos/invitado/datos/modelos/resultadoReservaInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitado.dart';
import 'package:mediturnos/invitado/presentacion/viewmodels/activarCuentaViewModel.dart';

class RepositorioInvitadoActivarFake implements RepositorioInvitado {
  ExcepcionInvitado? excepcionSimulada;

  @override
  Future<ResultadoReservaInvitado> reservarComoInvitado({
    required String nombre,
    required String apellido,
    required String dni,
    required String email,
    required String telefono,
    required int medicoId,
    required DateTime fecha,
    required String hora,
    required String claveSolicitud,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> confirmarActivacion({
    required String email,
    required String codigo,
    required String contrasena,
  }) async {
    if (excepcionSimulada != null) {
      throw excepcionSimulada!;
    }
    return {
      'id': 1,
      'nombre': 'Juan',
      'apellido': 'Perez',
      'email': email,
      'rol': 'PACIENTE',
      'dni': '38450123',
    };
  }

  @override
  Future<Map<String, dynamic>> reenviarActivacion({required String email}) async {
    if (excepcionSimulada != null) {
      throw excepcionSimulada!;
    }
    return {'venceEnDias': 3, 'codigoDemostracion': '123456'};
  }
}

void main() {
  late RepositorioInvitadoActivarFake repoFake;
  late ActivarCuentaViewModel vm;

  setUp(() {
    repoFake = RepositorioInvitadoActivarFake();
    vm = ActivarCuentaViewModel(repoFake);
  });

  tearDown(() {
    vm.dispose();
  });

  test('Validaciones de código y contraseñas', () async {
    // Código vacío
    final res1 = await vm.confirmar(
      email: 'test@ejemplo.com',
      codigo: '',
      contrasena: 'Pass123456',
      repetir: 'Pass123456',
    );
    expect(res1, isNull);
    expect(vm.errorCodigo, isNotNull);

    // Contraseñas no coinciden
    final res2 = await vm.confirmar(
      email: 'test@ejemplo.com',
      codigo: '123456',
      contrasena: 'Pass123456',
      repetir: 'Diferente123',
    );
    expect(res2, isNull);
    expect(vm.errorRepetir, 'Las contraseñas no coinciden.');
  });

  test('Reenviar inicia la cuenta regresiva de 60 segundos', () async {
    expect(vm.reenvioBloqueado, isFalse);

    final res = await vm.reenviar('test@ejemplo.com');

    expect(res, isNotNull);
    expect(vm.reenvioBloqueado, isTrue);
    expect(vm.segundosRestantes, 60);
  });

  test('Mapeo de CODIGO_INVALIDO y CODIGO_VENCIDO', () async {
    // Simular error CODIGO_INVALIDO
    repoFake.excepcionSimulada = ExcepcionInvitado(TipoErrorInvitado.codigoInvalido);
    await vm.confirmar(
      email: 'test@ejemplo.com',
      codigo: '123456',
      contrasena: 'Pass123456',
      repetir: 'Pass123456',
    );
    expect(vm.errorCodigo, 'El código no es correcto.');

    // Simular error CODIGO_VENCIDO
    repoFake.excepcionSimulada = ExcepcionInvitado(TipoErrorInvitado.codigoVencido);
    await vm.confirmar(
      email: 'test@ejemplo.com',
      codigo: '123456',
      contrasena: 'Pass123456',
      repetir: 'Pass123456',
    );
    expect(vm.errorCodigo, 'El código venció. Pedí uno nuevo.');
  });
}
