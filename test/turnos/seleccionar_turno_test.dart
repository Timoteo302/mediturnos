import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/configuracion/clavesGlobales.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/medicos/datos/modelos/especialidad.dart';
import 'package:mediturnos/medicos/datos/repositorios/repositorioMedicos.dart';
import 'package:mediturnos/medicos/datos/modelos/horarioAtencion.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaSeleccionarTurno.dart';

// Repositorios falsos para probar la selección de turno.
class FakeRepositorioGestionTurnosSeleccion extends Fake implements RepositorioGestionTurnos {
  @override
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha}) async {
    return [HorarioDisponible(hora: '09:00', disponible: true)];
  }

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) async => [];

  @override
  Future<TurnoDetalle> obtenerTurno(int id) async => throw UnimplementedError();

  @override
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud}) async => throw UnimplementedError();

  @override
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora}) async => throw UnimplementedError();

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado, String? origen}) async => throw UnimplementedError();

  @override
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira}) async => throw UnimplementedError();
}

class FakeRepositorioMedicosSeleccion implements RepositorioMedicos {
  @override
  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) async => [];

  @override
  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false}) async => [];

  @override
  Future<Medico> crearMedico({required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo}) => throw UnimplementedError();

  @override
  Future<Medico> actualizarMedico(int id, {required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo}) => throw UnimplementedError();

  @override
  Future<Medico> cambiarEstadoMedico(int id, bool activo) => throw UnimplementedError();

  @override
  Future<List<Especialidad>> obtenerEspecialidades({bool incluirInactivas = false}) async => [];

  @override
  Future<Especialidad> crearEspecialidad({required String nombre, String? descripcion}) => throw UnimplementedError();

  @override
  Future<Especialidad> actualizarEspecialidad(int id, {required String nombre, String? descripcion}) => throw UnimplementedError();

  @override
  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo) => throw UnimplementedError();

  @override
  Future<List<HorarioAtencion>> guardarHorarios(int medicoId, List<HorarioAtencion> horarios) => throw UnimplementedError();
}

class FakeServicioMonitoreoSincronizacion extends ServicioMonitoreoSincronizacion {
  @override
  Future<void> iniciar() async {}
  @override
  void detener() {}
}

void main() {
  testWidgets('Continuar sin seleccionar horario muestra notificación "Elegí un horario"', (tester) async {
    final medicoPrueba = Medico(
      id: 1,
      nombre: 'Carlos',
      apellido: 'Perez',
      matricula: '12345',
      activo: true,
      especialidad: Especialidad(id: 1, nombre: 'Cardiología', activo: true),
    );

    final repoTurnos = FakeRepositorioGestionTurnosSeleccion();
    final repoMedicos = FakeRepositorioMedicosSeleccion();
    final servicioSinc = FakeServicioMonitoreoSincronizacion();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<RepositorioGestionTurnos>.value(value: repoTurnos),
          Provider<RepositorioMedicos>.value(value: repoMedicos),
          ChangeNotifierProvider<EstadoConexionViewModel>(
            create: (_) => EstadoConexionViewModel(servicioSinc, verificadorConexion: () async => true),
          ),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: PantallaSeleccionarTurno(medico: medicoPrueba),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tocamos el botón "Continuar" sin haber seleccionado una hora en la grilla.
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.text('Elegí un horario'), findsOneWidget);
  });
}
