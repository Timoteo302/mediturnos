import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/invitado/datos/modelos/excepcionInvitado.dart';
import 'package:mediturnos/invitado/datos/modelos/resultadoReservaInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitado.dart';
import 'package:mediturnos/invitado/presentacion/viewmodels/datosInvitadoViewModel.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';

class RepositorioInvitadoFake implements RepositorioInvitado {
  ResultadoReservaInvitado? resultadoSimulado;
  ExcepcionInvitado? excepcionSimulada;
  Map<String, dynamic>? ultimoLlamadoReserva;

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
    ultimoLlamadoReserva = {
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'email': email,
      'telefono': telefono,
      'medicoId': medicoId,
      'fecha': fecha,
      'hora': hora,
      'claveSolicitud': claveSolicitud,
    };

    if (excepcionSimulada != null) {
      throw excepcionSimulada!;
    }
    return resultadoSimulado ??
        ResultadoReservaInvitado(
          turno: TurnoDetalle(
            id: 10,
            estado: EstadoTurno.pendiente,
            fecha: fecha,
            hora: hora,
            paciente: PacienteDetalle(id: 1, nombre: nombre, apellido: apellido, dni: dni),
            medico: MedicoDetalle(
              id: medicoId,
              nombre: 'Dr. Test',
              apellido: '',
              especialidad: EspecialidadDetalle(id: 1, nombre: 'General'),
            ),
          ),
          email: email,
          venceEnDias: 3,
        );
  }

  @override
  Future<Map<String, dynamic>> confirmarActivacion({
    required String email,
    required String codigo,
    required String contrasena,
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> reenviarActivacion({required String email}) async {
    return {};
  }
}

void main() {
  late RepositorioInvitadoFake repoFake;
  late DatosInvitadoViewModel vm;

  setUp(() {
    repoFake = RepositorioInvitadoFake();
    vm = DatosInvitadoViewModel(repoFake);
  });

  test('Validaciones de formulario con datos vacíos o inválidos devuelven null', () async {
    final res1 = await vm.reservar(
      medicoId: 1,
      fecha: DateTime(2026, 12, 1),
      hora: '10:00',
      nombre: '',
      apellido: 'Perez',
      dni: '38450123',
      email: 'test@correo.com',
      telefono: '1122334455',
    );
    expect(res1, isNull);
    expect(vm.errorNombre, isNotNull);

    final res2 = await vm.reservar(
      medicoId: 1,
      fecha: DateTime(2026, 12, 1),
      hora: '10:00',
      nombre: 'Lucas',
      apellido: 'Perez',
      dni: '123', // DNI inválido
      email: 'test@correo.com',
      telefono: '1122334455',
    );
    expect(res2, isNull);
    expect(vm.errorDni, isNotNull);

    final res3 = await vm.reservar(
      medicoId: 1,
      fecha: DateTime(2026, 12, 1),
      hora: '10:00',
      nombre: 'Lucas',
      apellido: 'Perez',
      dni: '38450123',
      email: 'correoInvalido', // Email inválido
      telefono: '1122334455',
    );
    expect(res3, isNull);
    expect(vm.errorEmail, isNotNull);
  });

  test('Flujo feliz de reserva llama al repositorio y genera claveSolicitud UUID', () async {
    final res = await vm.reservar(
      medicoId: 2,
      fecha: DateTime(2026, 12, 15),
      hora: '11:30',
      nombre: 'Maria',
      apellido: 'Gomez',
      dni: '38450123',
      email: 'maria@ejemplo.com',
      telefono: '1122334455',
    );

    expect(res, isNotNull);
    expect(repoFake.ultimoLlamadoReserva, isNotNull);
    expect(repoFake.ultimoLlamadoReserva!['nombre'], 'Maria');
    expect(repoFake.ultimoLlamadoReserva!['medicoId'], 2);
    expect(repoFake.ultimoLlamadoReserva!['claveSolicitud'], isNotEmpty);
  });
}
