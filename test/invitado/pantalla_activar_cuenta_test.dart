import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/turnos/tarjetaResumenTurno.dart';
import 'package:mediturnos/invitado/presentacion/pantallas/pantallaActivarCuenta.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';

class FakeStorageForActivarCuentaTest extends Fake implements FlutterSecureStorage {
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
  Future<Usuario> iniciarSesion(String email, String contrasena) async {
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
    throw UnimplementedError();
  }

  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) async {
    throw UnimplementedError();
  }

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

class RepositorioGestionTurnosFake extends Fake implements RepositorioGestionTurnos {
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

void main() {
  late EstadoConexionViewModel conexionVm;
  late AutenticacionViewModel authVm;
  late AlmacenToken almacenToken;

  setUp(() {
    almacenToken = AlmacenToken(storage: FakeStorageForActivarCuentaTest());
    conexionVm = EstadoConexionViewModel(
      ServicioSincronizacionFake(),
      verificadorConexion: () async => true,
    );
    authVm = AutenticacionViewModel(RepositorioAutenticacionFake(), almacenToken: almacenToken);
  });

  tearDown(() {
    conexionVm.dispose();
    authVm.dispose();
  });

  Widget crearWidgetTest({
    required String email,
    required int venceEnDias,
    TurnoDetalle? turno,
    String? codigoDemostracion,
    bool vieneDeLogin = false,
  }) {
    return MultiProvider(
      providers: [
        Provider<AlmacenToken>.value(value: almacenToken),
        Provider<http.Client>.value(value: http.Client()),
        ChangeNotifierProvider<EstadoConexionViewModel>.value(value: conexionVm),
        ChangeNotifierProvider<AutenticacionViewModel>.value(value: authVm),
        Provider<RepositorioGestionTurnos>(create: (_) => RepositorioGestionTurnosFake()),
      ],
      child: MaterialApp(
        home: PantallaActivarCuenta(
          email: email,
          venceEnDias: venceEnDias,
          turno: turno,
          codigoDemostracion: codigoDemostracion,
          vieneDeLogin: vieneDeLogin,
        ),
      ),
    );
  }

  testWidgets('Muestra el banner de Modo demostración si viene codigoDemostracion', (tester) async {
    await tester.pumpWidget(crearWidgetTest(
      email: 'test@ejemplo.com',
      venceEnDias: 3,
      codigoDemostracion: '123456',
    ));

    expect(find.textContaining('Modo demostración: tu código es 123456'), findsOneWidget);
  });

  testWidgets('Muestra TarjetaResumenTurno solo si viene un turno', (tester) async {
    await tester.pumpWidget(crearWidgetTest(
      email: 'test@ejemplo.com',
      venceEnDias: 3,
    ));
    expect(find.byType(TarjetaResumenTurno), findsNothing);

    final turnoMock = TurnoDetalle(
      id: 1,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 12, 1),
      hora: '10:00',
      paciente: PacienteDetalle(id: 1, nombre: 'Ana', apellido: 'Perez', dni: '38450123'),
      medico: MedicoDetalle(
        id: 1,
        nombre: 'Dr. Lopez',
        apellido: '',
        especialidad: EspecialidadDetalle(id: 1, nombre: 'Cardiología'),
      ),
    );

    await tester.pumpWidget(crearWidgetTest(
      email: 'test@ejemplo.com',
      venceEnDias: 3,
      turno: turnoMock,
    ));

    expect(find.byType(TarjetaResumenTurno), findsOneWidget);
    expect(find.text('¡Turno reservado!'), findsOneWidget);
  });

  testWidgets('Boton "Lo hago después" regresa al inicio', (tester) async {
    authVm.entrarComoInvitado();

    await tester.pumpWidget(crearWidgetTest(
      email: 'test@ejemplo.com',
      venceEnDias: 3,
    ));

    final botonLoHagoDespues = find.text('Lo hago después');
    expect(botonLoHagoDespues, findsOneWidget);

    await tester.tap(botonLoHagoDespues);
    await tester.pumpAndSettle();

    expect(find.text('Activar Cuenta'), findsNothing);
  });

  testWidgets('Con email vacío muestra el botón "Enviarme el código"', (tester) async {
    await tester.pumpWidget(crearWidgetTest(
      email: '',
      venceEnDias: 7,
      vieneDeLogin: true,
    ));

    expect(find.text('Enviarme el código'), findsOneWidget);
  });
}
