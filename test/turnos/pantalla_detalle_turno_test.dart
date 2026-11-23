import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/paciente.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaDetalleTurno.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';

// Clases falsas de repositorio para testear el detalle de turno según el rol de usuario.
class FakeRepositorioAutenticacion implements RepositorioAutenticacion {
  Usuario? usuarioActual;

  @override
  Future<Usuario?> obtenerUsuarioActual() async => usuarioActual;

  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async => throw UnimplementedError();

  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<Usuario> registrarPaciente({required String nombre, required String apellido, required String dni, required String telefono, required String email, required String contrasena}) => throw UnimplementedError();

  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) => throw UnimplementedError();

  @override
  Future<void> restablecerContrasena({required String idRecuperacion, required String codigo, required String nuevaContrasena}) => throw UnimplementedError();

  @override
  Future<void> actualizarCopiaLocal(Usuario usuario) async {}
}

class FakeRepositorioGestionTurnosDetalle extends Fake implements RepositorioGestionTurnos {
  final TurnoDetalle turnoPrueba = TurnoDetalle(
    id: 1,
    estado: EstadoTurno.pendiente,
    fecha: DateTime(2026, 6, 15),
    hora: '10:00',
    paciente: PacienteDetalle(id: 10, nombre: 'Ana', apellido: 'Perez', dni: '40123456'),
    medico: MedicoDetalle(id: 20, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'Pediatría')),
  );

  @override
  Future<TurnoDetalle> obtenerTurno(int id) async => turnoPrueba;

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) async => [turnoPrueba];

  @override
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha}) async => [];

  @override
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado, String? origen}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira}) async => turnoPrueba;
}

class FakeServicioSincDetalle extends ServicioMonitoreoSincronizacion {
  @override
  Future<void> iniciar() async {}
  @override
  void detener() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeRepositorioAutenticacion repoAuth;
  late FakeRepositorioGestionTurnosDetalle repoTurnos;

  setUp(() {
    repoAuth = FakeRepositorioAutenticacion();
    repoTurnos = FakeRepositorioGestionTurnosDetalle();
  });

  testWidgets('Paciente NO ve los datos del paciente (DNI) en PantallaDetalleTurno', (tester) async {
    final usuario = Usuario(
      id: 1,
      nombre: 'Ana',
      apellido: 'Perez',
      email: 'ana@ejemplo.com',
      rol: RolUsuario.paciente,
      activo: true,
      fechaCreacion: '2026-01-01',
      paciente: Paciente(id: 10, dni: '40123456', telefono: '123456'),
    );
    repoAuth.usuarioActual = usuario;

    final authVm = AutenticacionViewModel(repoAuth);
    await authVm.actualizarUsuarioActual(usuario);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<RepositorioGestionTurnos>.value(value: repoTurnos),
          ChangeNotifierProvider<AutenticacionViewModel>.value(value: authVm),
          ChangeNotifierProvider<EstadoConexionViewModel>(
            create: (_) => EstadoConexionViewModel(FakeServicioSincDetalle(), verificadorConexion: () async => true),
          ),
        ],
        child: MaterialApp(
          home: PantallaDetalleTurno(turno: repoTurnos.turnoPrueba),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que el DNI del paciente no es visible para rol Paciente.
    expect(find.textContaining('DNI: 40123456'), findsNothing);
  });

  testWidgets('Admin SÍ ve la tarjeta de datos del paciente con DNI en PantallaDetalleTurno', (tester) async {
    final usuario = Usuario(
      id: 2,
      nombre: 'Admin',
      apellido: 'Sistema',
      email: 'admin@ejemplo.com',
      rol: RolUsuario.admin,
      activo: true,
      fechaCreacion: '2026-01-01',
    );
    repoAuth.usuarioActual = usuario;

    final authVm = AutenticacionViewModel(repoAuth);
    await authVm.actualizarUsuarioActual(usuario);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<RepositorioGestionTurnos>.value(value: repoTurnos),
          ChangeNotifierProvider<AutenticacionViewModel>.value(value: authVm),
          ChangeNotifierProvider<EstadoConexionViewModel>(
            create: (_) => EstadoConexionViewModel(FakeServicioSincDetalle(), verificadorConexion: () async => true),
          ),
        ],
        child: MaterialApp(
          home: PantallaDetalleTurno(turno: repoTurnos.turnoPrueba),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que el DNI del paciente sí se muestra en la pantalla de detalle para rol Admin.
    expect(find.textContaining('40123456'), findsOneWidget);
  });
}
