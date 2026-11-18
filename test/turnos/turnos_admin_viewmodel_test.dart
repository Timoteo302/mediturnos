import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/excepcionTurnos.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/medicos/datos/modelos/especialidad.dart';
import 'package:mediturnos/medicos/datos/repositorios/repositorioMedicos.dart';
import 'package:mediturnos/turnos/presentacion/viewmodels/turnosAdminViewModel.dart';

class FakeRepositorioGestionTurnos implements RepositorioGestionTurnos {
  bool simularSinConexion = false;
  bool simularError409 = false;
  EstadoTurno? estadoCambiado;

  final TurnoDetalle turnoPrueba = TurnoDetalle(
    id: 101,
    estado: EstadoTurno.pendiente,
    fecha: DateTime(2026, 1, 1),
    hora: '10:00',
    paciente: PacienteDetalle(id: 1, nombre: 'Lucas', apellido: 'González', dni: '38450123'),
    medico: MedicoDetalle(
      id: 2,
      nombre: 'Dr. Perez',
      apellido: '',
      especialidad: EspecialidadDetalle(id: 3, nombre: 'Cardiología'),
    ),
  );

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) async {
    return [turnoPrueba];
  }

  @override
  Future<TurnoDetalle> obtenerTurno(int id) async => turnoPrueba;

  @override
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha}) async => [];

  @override
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado}) async {
    if (simularSinConexion) {
      throw ExcepcionTurnos(tipo: ErrorTurnos.sinConexion);
    }
    if (simularError409) {
      throw ExcepcionTurnos(
        tipo: ErrorTurnos.errorServidor,
        mensajeServidor: 'Transición de estado inválida.',
      );
    }
    estadoCambiado = estado;
    return turnoPrueba;
  }
}

class FakeRepositorioMedicos implements RepositorioMedicos {
  @override
  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false}) async => [];

  @override
  Future<Medico> obtenerMedicoPorId(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Especialidad>> obtenerEspecialidades({bool incluirInactivas = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Medico> crearMedico(Medico medico) {
    throw UnimplementedError();
  }

  @override
  Future<Medico> actualizarMedico(Medico medico) {
    throw UnimplementedError();
  }

  @override
  Future<Especialidad> crearEspecialidad(Especialidad especialidad) {
    throw UnimplementedError();
  }

  @override
  Future<Especialidad> actualizarEspecialidad(Especialidad especialidad) {
    throw UnimplementedError();
  }
}

void main() {
  group('TurnosAdminViewModel.cancelarTurno Tests', () {
    late FakeRepositorioGestionTurnos repoTurnos;
    late FakeRepositorioMedicos repoMedicos;
    late TurnosAdminViewModel vm;

    setUp(() {
      repoTurnos = FakeRepositorioGestionTurnos();
      repoMedicos = FakeRepositorioMedicos();
      vm = TurnosAdminViewModel(repoTurnos, repoMedicos);
    });

    test('Éxito al cancelarTurno llama cambiarEstadoTurno con CANCELADO y recarga', () async {
      final res = await vm.cancelarTurno(repoTurnos.turnoPrueba);

      expect(res, isTrue);
      expect(repoTurnos.estadoCambiado, equals(EstadoTurno.cancelado));
      expect(vm.errorAccion, isNull);
    });

    test('Error 409 o del servidor muestra mensajeServidor en errorAccion', () async {
      repoTurnos.simularError409 = true;

      final res = await vm.cancelarTurno(repoTurnos.turnoPrueba);

      expect(res, isFalse);
      expect(vm.errorAccion, equals('Transición de estado inválida.'));
    });

    test('Sin conexión muestra mensaje adecuado en errorAccion', () async {
      repoTurnos.simularSinConexion = true;

      final res = await vm.cancelarTurno(repoTurnos.turnoPrueba);

      expect(res, isFalse);
      expect(vm.errorAccion, equals('Necesitás conexión con el servidor para rechazar el turno.'));
    });
  });
}
