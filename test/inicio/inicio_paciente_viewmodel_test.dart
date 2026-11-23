import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/inicio/presentacion/viewmodels/inicioPacienteViewModel.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';

// Repositorio falso para probar las llamadas de InicioPacienteViewModel.
class RepositorioGestionTurnosFake extends Fake implements RepositorioGestionTurnos {
  int? pacienteIdRecibido;
  bool llamado = false;

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) async {
    llamado = true;
    pacienteIdRecibido = pacienteId;
    return [
      TurnoDetalle(
        id: 10,
        estado: EstadoTurno.pendiente,
        fecha: DateTime.now().add(const Duration(days: 1)),
        hora: '10:00',
        paciente: PacienteDetalle(id: 4, nombre: 'Test', apellido: 'User', dni: '123', telefono: '123'),
        medico: MedicoDetalle(
          id: 1,
          nombre: 'Roberto',
          apellido: 'Sosa',
          especialidad: EspecialidadDetalle(id: 1, nombre: 'Pediatría'),
        ),
      ),
    ];
  }
}

void main() {
  test('InicioPacienteViewModel con pacienteId null: no llama al repositorio, turnos vacío y error null', () async {
    final repo = RepositorioGestionTurnosFake();
    final vm = InicioPacienteViewModel(
      repo,
      pacienteId: null,
      nombreUsuario: 'Invitado',
    );

    await Future.delayed(Duration.zero);

    expect(repo.llamado, isFalse);
    expect(vm.turnos, isEmpty);
    expect(vm.proximoTurno, isNull);
    expect(vm.cargando, isFalse);
    expect(vm.error, isNull);
  });

  test('InicioPacienteViewModel con pacienteId 4: llama al repositorio con pacienteId 4', () async {
    final repo = RepositorioGestionTurnosFake();
    final vm = InicioPacienteViewModel(
      repo,
      pacienteId: 4,
      nombreUsuario: 'Carlos',
    );

    await Future.delayed(Duration.zero);

    expect(repo.llamado, isTrue);
    expect(repo.pacienteIdRecibido, 4);
    expect(vm.turnos.length, 1);
    expect(vm.turnos.first.id, 10);
    expect(vm.cargando, isFalse);
    expect(vm.error, isNull);
  });
}
