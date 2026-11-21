import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaCrearCuenta.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/inicio/presentacion/pantallas/pantallaInicioPaciente.dart';
import 'package:mediturnos/inicio/presentacion/viewmodels/inicioPacienteViewModel.dart';
import 'package:mediturnos/invitado/presentacion/pantallas/pantallaActivarCuenta.dart';
import 'package:mediturnos/notificaciones/datos/modelos/notificacion.dart';
import 'package:mediturnos/notificaciones/datos/repositorios/repositorioNotificaciones.dart';
import 'package:mediturnos/notificaciones/presentacion/viewmodels/notificacionesViewModel.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/modelos/turno.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioTurnos.dart';
import 'package:mediturnos/turnos/logica/casosDeUsoTurnos.dart';
import 'package:mediturnos/turnos/presentacion/controladores/controladorTurnos.dart';

class FakeStorageForNavTest extends Fake implements FlutterSecureStorage {
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

class RepositorioAutenticacionFake implements RepositorioAutenticacion {
  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async => throw UnimplementedError();

  @override
  Future<Usuario> registrarPaciente({
    required String nombre,
    required String apellido,
    required String dni,
    required String telefono,
    required String email,
    required String contrasena,
  }) async => throw UnimplementedError();

  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) async => throw UnimplementedError();

  @override
  Future<void> restablecerContrasena({
    required String idRecuperacion,
    required String codigo,
    required String nuevaContrasena,
  }) async {}

  @override
  Future<void> actualizarCopiaLocal(Usuario usuario) async {}
}

class ServicioSincronizacionFake implements ServicioMonitoreoSincronizacion {
  @override
  Future<void> sincronizarAhora() async {}

  @override
  Future<void> iniciar() async {}

  @override
  void detener() {}
}

class RepositorioGestionTurnosFake implements RepositorioGestionTurnos {
  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) async => [];

  @override
  Future<TurnoDetalle> obtenerTurno(int id) async => throw UnimplementedError();

  @override
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha}) async => [];

  @override
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud}) async => throw UnimplementedError();

  @override
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora}) async => throw UnimplementedError();

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado, String? origen}) async => throw UnimplementedError();

  @override
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira}) async => throw UnimplementedError();
}

class RepositorioTurnosFake implements RepositorioTurnos {
  @override
  Future<List<Turno>> obtenerTurnos() async => [];

  @override
  Future<void> guardarTurno(Turno turno) async {}

  @override
  Future<void> modificarTurno(Turno turno) async {}

  @override
  Future<void> eliminarTurno(int id) async {}

  @override
  Future<void> reemplazarTurno(int idAnterior, Turno turno) async {}

  @override
  Future<void> marcarErrorSincronizacion(int id, String error) async {}
}

class RepositorioNotificacionesFake implements RepositorioNotificaciones {
  @override
  Future<List<Notificacion>> obtenerNotificaciones({required int usuarioId}) async => [];

  @override
  Future<int> obtenerCantidadNoLeidas({required int usuarioId}) async => 0;

  @override
  Future<void> marcarLeida({required int id}) async {}

  @override
  Future<void> marcarTodasLeidas({required int usuarioId}) async {}
}

void main() {
  late EstadoConexionViewModel conexionVm;
  late AutenticacionViewModel authVm;
  late RepositorioGestionTurnosFake repoGestion;
  late AlmacenToken almacenToken;

  setUp(() {
    almacenToken = AlmacenToken(storage: FakeStorageForNavTest());
    conexionVm = EstadoConexionViewModel(
      ServicioSincronizacionFake(),
      verificadorConexion: () async => true,
    );
    authVm = AutenticacionViewModel(RepositorioAutenticacionFake(), almacenToken: almacenToken);
    repoGestion = RepositorioGestionTurnosFake();
  });

  tearDown(() {
    conexionVm.dispose();
    authVm.dispose();
  });

  Widget crearAppConPila({required Widget home}) {
    final repoTurnos = RepositorioTurnosFake();
    final casosDeUso = CasosDeUsoTurnos(repoTurnos);
    final controladorTurnos = ControladorTurnos(casosDeUso);

    return MultiProvider(
      providers: [
        Provider<AlmacenToken>.value(value: almacenToken),
        Provider<http.Client>.value(value: http.Client()),
        ChangeNotifierProvider<EstadoConexionViewModel>.value(value: conexionVm),
        ChangeNotifierProvider<AutenticacionViewModel>.value(value: authVm),
        Provider<RepositorioAutenticacion>(create: (_) => RepositorioAutenticacionFake()),
        Provider<RepositorioGestionTurnos>.value(value: repoGestion),
        ChangeNotifierProvider<InicioPacienteViewModel>(
          create: (_) => InicioPacienteViewModel(
            repoGestion,
            pacienteId: 1,
            nombreUsuario: 'Juan',
          ),
        ),
        ChangeNotifierProvider<NotificacionesViewModel>(
          create: (_) => NotificacionesViewModel(
            repositorioNotificaciones: RepositorioNotificacionesFake(),
            repositorioTurnos: repoGestion,
            authVm: authVm,
            conexionVm: conexionVm,
          ),
        ),
        Provider<ControladorTurnos>.value(value: controladorTurnos),
      ],
      child: MaterialApp(
        home: home,
      ),
    );
  }

  testWidgets('Desde inicio modo invitado, tocar "Crear cuenta" y flecha volver muestra PantallaLogin', (tester) async {
    authVm.entrarComoInvitado();

    await tester.pumpWidget(crearAppConPila(home: const PantallaInicioPaciente()));
    await tester.pumpAndSettle();

    final botonCrearCuenta = find.text('Crear cuenta');
    expect(botonCrearCuenta, findsOneWidget);

    await tester.tap(botonCrearCuenta);
    await tester.pumpAndSettle();

    expect(find.text('Completá tus datos para registrarte como paciente'), findsOneWidget);

    final botonVolver = find.byIcon(Icons.arrow_back);
    expect(botonVolver, findsOneWidget);

    await tester.tap(botonVolver);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.text('Accedé a tu gestión de turnos médicos'), findsOneWidget);
  });

  testWidgets('Abrir PantallaCrearCuenta como única ruta y tocar volver muestra PantallaLogin', (tester) async {
    await tester.pumpWidget(crearAppConPila(home: const PantallaCrearCuenta()));
    await tester.pumpAndSettle();

    expect(find.text('Completá tus datos para registrarte como paciente'), findsOneWidget);

    final botonVolver = find.byIcon(Icons.arrow_back);
    await tester.tap(botonVolver);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.text('Accedé a tu gestión de turnos médicos'), findsOneWidget);
  });

  testWidgets('El login muestra "¿Reservaste como invitado? Activá tu cuenta" y al tocarlo abre PantallaActivarCuenta', (tester) async {
    await tester.pumpWidget(crearAppConPila(home: const PantallaLogin()));
    await tester.pumpAndSettle();

    final enlaceActivar = find.text('¿Reservaste como invitado? Activá tu cuenta');
    expect(enlaceActivar, findsOneWidget);

    await tester.tap(enlaceActivar);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaActivarCuenta), findsOneWidget);
  });
}
