import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/excepcionTurnos.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/medicos/datos/modelos/especialidad.dart';
import 'package:mediturnos/medicos/datos/modelos/horarioAtencion.dart';
import 'package:mediturnos/medicos/datos/repositorios/repositorioMedicos.dart';
import 'package:mediturnos/turnos/presentacion/viewmodels/turnosAdminViewModel.dart';

class FakeRepositorioGestionTurnos extends Fake implements RepositorioGestionTurnos {
  bool simularSinConexion = false;
  bool simularError409 = false;
  bool simularConfirmacionAnticipada = false;
  EstadoTurno? estadoCambiado;
  String? origenCambiado;

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
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado, String? origen}) async {
    if (simularSinConexion) {
      throw ExcepcionTurnos(ErrorTurnos.sinConexion);
    }
    if (simularConfirmacionAnticipada) {
      throw ExcepcionTurnos(ErrorTurnos.confirmacionAnticipada);
    }
    if (simularError409) {
      throw ExcepcionTurnos(
        ErrorTurnos.errorServidor,
        mensajeServidor: 'Transición de estado inválida.',
      );
    }
    estadoCambiado = estado;
    origenCambiado = origen;
    return turnoPrueba;
  }
}

class FakeRepositorioMedicos implements RepositorioMedicos {
  @override
  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false}) async => [];

  @override
  Future<Medico> crearMedico({required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo}) {
    throw UnimplementedError();
  }

  @override
  Future<Medico> actualizarMedico(int id, {required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo}) {
    throw UnimplementedError();
  }

  @override
  Future<Medico> cambiarEstadoMedico(int id, bool activo) {
    throw UnimplementedError();
  }

  @override
  Future<List<Especialidad>> obtenerEspecialidades({bool incluirInactivas = false}) async => [];

  @override
  Future<Especialidad> crearEspecialidad({required String nombre, String? descripcion}) {
    throw UnimplementedError();
  }

  @override
  Future<Especialidad> actualizarEspecialidad(int id, {required String nombre, String? descripcion}) {
    throw UnimplementedError();
  }

  @override
  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo) {
    throw UnimplementedError();
  }

  @override
  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) async => [];

  @override
  Future<List<HorarioAtencion>> guardarHorarios(int medicoId, List<HorarioAtencion> horarios) async => [];
}

void main() {
  group('TurnosAdminViewModel Tests', () {
    late FakeRepositorioGestionTurnos repoTurnos;
    late FakeRepositorioMedicos repoMedicos;
    late TurnosAdminViewModel vm;

    setUp(() {
      repoTurnos = FakeRepositorioGestionTurnos();
      repoMedicos = FakeRepositorioMedicos();
      vm = TurnosAdminViewModel(repoTurnos, repoMedicos);
    });

    test('Éxito al cancelarTurno llama cambiarEstadoTurno con CANCELADO y origen CENTRO', () async {
      final res = await vm.cancelarTurno(repoTurnos.turnoPrueba);

      expect(res, isTrue);
      expect(repoTurnos.estadoCambiado, equals(EstadoTurno.cancelado));
      expect(repoTurnos.origenCambiado, equals('CENTRO'));
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

    test('Confirmar con error CONFIRMACION_ANTICIPADA mapea mensaje en errorAccion', () async {
      repoTurnos.simularConfirmacionAnticipada = true;

      final res = await vm.confirmar(repoTurnos.turnoPrueba);

      expect(res, isFalse);
      expect(vm.errorAccion, equals('Solo podés confirmar turnos que empiezan en las próximas 24 horas.'));
    });

    test('fechaInicial inicializa la fecha seleccionada en ViewModel', () {
      final fechaPrueba = DateTime(2026, 5, 20);
      final vmConFecha = TurnosAdminViewModel(repoTurnos, repoMedicos, fechaInicial: fechaPrueba);

      expect(vmConFecha.fechaSeleccionada.year, equals(2026));
      expect(vmConFecha.fechaSeleccionada.month, equals(5));
      expect(vmConFecha.fechaSeleccionada.day, equals(20));
    });
  });
}
