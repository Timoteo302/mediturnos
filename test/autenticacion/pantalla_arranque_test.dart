import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenSesionLocal.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaArranque.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/configuracion/clavesGlobales.dart';
import 'package:mediturnos/inicio/presentacion/pantallas/pantallaInicioAdmin.dart';
import 'package:mediturnos/inicio/presentacion/pantallas/pantallaInicioPaciente.dart';
import 'package:mediturnos/inicio/presentacion/viewmodels/inicioPacienteViewModel.dart';
import 'package:mediturnos/inicio/presentacion/viewmodels/panelAdminViewModel.dart';
import 'package:mediturnos/medicos/datos/modelos/especialidad.dart';
import 'package:mediturnos/medicos/datos/modelos/horarioAtencion.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/medicos/datos/repositorios/repositorioMedicos.dart';
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

class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> datos = {};
  bool simularExcepcion = false;

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
    if (simularExcepcion) throw Exception('Error en storage');
    if (value != null) {
      datos[key] = value;
    } else {
      datos.remove(key);
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
    if (simularExcepcion) throw Exception('Error en storage');
    return datos[key];
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
    if (simularExcepcion) throw Exception('Error en storage');
    datos.remove(key);
  }
}

class AlmacenSesionLocalMemory implements AlmacenSesionLocal {
  final Map<String, Map<String, dynamic>> _sesiones = {};

  @override
  Future<void> guardar(Usuario usuario, String contrasenaHash) async {
    _sesiones[usuario.email] = {
      'email': usuario.email,
      'contrasena_hash': contrasenaHash,
      'usuario_json': json.encode(usuario.toJson()),
    };
  }

  @override
  Future<void> actualizarDatosUsuario(Usuario usuario) async {}

  @override
  Future<Map<String, dynamic>?> obtener(String email) async => _sesiones[email];

  @override
  Future<Map<String, dynamic>?> obtenerPorUsuarioId(int usuarioId) async {
    for (final s in _sesiones.values) {
      final map = json.decode(s['usuario_json']) as Map<String, dynamic>;
      if (map['id'] == usuarioId) return s;
    }
    return null;
  }

  @override
  Future<void> borrar(String email) async {
    _sesiones.remove(email);
  }
}

class RepositorioAutenticacionFake implements RepositorioAutenticacion {
  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async => throw UnimplementedError();
  @override
  Future<Usuario> registrarPaciente({required String nombre, required String apellido, required String dni, required String telefono, required String email, required String contrasena}) async => throw UnimplementedError();
  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) async => throw UnimplementedError();
  @override
  Future<void> restablecerContrasena({required String idRecuperacion, required String codigo, required String nuevaContrasena}) async {}
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

class RepositorioMedicosFake implements RepositorioMedicos {
  @override
  Future<List<Medico>> obtenerMedicos({int? especialidadId, bool? incluirInactivos}) async => [];
  @override
  Future<List<Especialidad>> obtenerEspecialidades({bool? incluirInactivas}) async => [];
  @override
  Future<List<HorarioAtencion>> obtenerHorariosAtencion(int medicoId) async => [];
  @override
  Future<Medico> crearMedico({required String nombre, required String apellido, required String matricula, required int especialidadId, required bool activo}) async => throw UnimplementedError();
  @override
  Future<Medico> actualizarMedico(int id, {required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo}) async => throw UnimplementedError();
  @override
  Future<Medico> modificarMedico({required int id, required String nombre, required String apellido, required String matricula, required int especialidadId, required bool activo}) async => throw UnimplementedError();
  @override
  Future<Medico> cambiarEstadoMedico(int id, bool activo) async => throw UnimplementedError();
  @override
  Future<Especialidad> crearEspecialidad({required String nombre, String? descripcion}) async => throw UnimplementedError();
  @override
  Future<Especialidad> actualizarEspecialidad(int id, {required String nombre, String? descripcion}) async => throw UnimplementedError();
  @override
  Future<Especialidad> modificarEspecialidad({required int id, required String nombre, String? descripcion}) async => throw UnimplementedError();
  @override
  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo) async => throw UnimplementedError();
  @override
  Future<List<HorarioAtencion>> reemplazarAgenda({required int medicoId, required List<HorarioAtencion> horarios}) async => [];
  @override
  Future<List<HorarioAtencion>> guardarHorarios(int medicoId, List<HorarioAtencion> horarios) async => [];
  @override
  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) async => [];
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
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late FakeFlutterSecureStorage storageFake;
  late AlmacenToken almacenToken;
  late AlmacenSesionLocalMemory sesionLocal;
  late EstadoConexionViewModel conexionVm;
  late AutenticacionViewModel authVm;
  late RepositorioGestionTurnosFake repoGestion;

  setUp(() {
    storageFake = FakeFlutterSecureStorage();
    almacenToken = AlmacenToken(storage: storageFake);
    sesionLocal = AlmacenSesionLocalMemory();
    conexionVm = EstadoConexionViewModel(ServicioSincronizacionFake(), verificadorConexion: () async => true);
    authVm = AutenticacionViewModel(RepositorioAutenticacionFake(), almacenToken: almacenToken, limpiezaLocal: () async {});
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
    final repoMedicos = RepositorioMedicosFake();

    return MultiProvider(
      providers: [
        Provider<AlmacenToken>.value(value: almacenToken),
        Provider<AlmacenSesionLocal>.value(value: sesionLocal),
        Provider<http.Client>.value(value: http.Client()),
        ChangeNotifierProvider<EstadoConexionViewModel>.value(value: conexionVm),
        ChangeNotifierProvider<AutenticacionViewModel>.value(value: authVm),
        Provider<RepositorioAutenticacion>(create: (_) => RepositorioAutenticacionFake()),
        Provider<RepositorioGestionTurnos>.value(value: repoGestion),
        Provider<RepositorioMedicos>.value(value: repoMedicos),
        ChangeNotifierProvider<InicioPacienteViewModel>(
          create: (_) => InicioPacienteViewModel(repoGestion, pacienteId: 1, nombreUsuario: 'Juan'),
        ),
        ChangeNotifierProvider<PanelAdminViewModel>(
          create: (ctx) => PanelAdminViewModel(repoGestion, repoMedicos),
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
        navigatorKey: claveNavegacionGlobal,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: home,
      ),
    );
  }

  testWidgets('Usuario guardado + token paciente vigente -> va al inicio paciente', (tester) async {
    final usuario = Usuario.fromJson({'id': 1, 'nombre': 'Juan', 'apellido': 'Perez', 'email': 'juan@test.com', 'rol': 'PACIENTE'});
    await sesionLocal.guardar(usuario, 'hash123');
    await almacenToken.guardar('token-paciente-valido', DateTime.now().add(const Duration(days: 5)), usuarioId: 1);

    await tester.pumpWidget(crearAppConPila(home: const PantallaArranque()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PantallaInicioPaciente), findsOneWidget);
  });

  testWidgets('Usuario guardado + token admin vigente -> va al inicio admin', (tester) async {
    final usuarioAdmin = Usuario.fromJson({'id': 2, 'nombre': 'Admin', 'apellido': 'Sistema', 'email': 'admin@test.com', 'rol': 'ADMIN'});
    await sesionLocal.guardar(usuarioAdmin, 'hash123');
    await almacenToken.guardar('token-admin-valido', DateTime.now().add(const Duration(days: 5)), usuarioId: 2);

    await tester.pumpWidget(crearAppConPila(home: const PantallaArranque()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PantallaInicioAdmin), findsOneWidget);
  });

  testWidgets('Usuario guardado + token vencido -> va al login con aviso', (tester) async {
    final usuario = Usuario.fromJson({'id': 1, 'nombre': 'Juan', 'apellido': 'Perez', 'email': 'juan@test.com', 'rol': 'PACIENTE'});
    await sesionLocal.guardar(usuario, 'hash123');
    await almacenToken.guardar('token-vencido', DateTime.now().subtract(const Duration(days: 1)), usuarioId: 1);

    await tester.pumpWidget(crearAppConPila(home: const PantallaArranque()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.text('Tu sesión venció'), findsOneWidget);
  });

  testWidgets('Sin usuario guardado ni token -> va al login sin aviso', (tester) async {
    await tester.pumpWidget(crearAppConPila(home: const PantallaArranque()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.text('Tu sesión venció'), findsNothing);
  });

  testWidgets('Token vigente pero usuarioId sin fila en sesiones_locales -> va al login', (tester) async {
    await almacenToken.guardar('token-sin-fila', DateTime.now().add(const Duration(days: 5)), usuarioId: 999);

    await tester.pumpWidget(crearAppConPila(home: const PantallaArranque()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  testWidgets('Error leyendo el almacenamiento -> va al login sin lanzar excepción', (tester) async {
    storageFake.simularExcepcion = true;

    await tester.pumpWidget(crearAppConPila(home: const PantallaArranque()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  testWidgets('Después de cerrarSesion(), al arrancar -> va al login sin aviso', (tester) async {
    final usuario = Usuario.fromJson({'id': 1, 'nombre': 'Juan', 'apellido': 'Perez', 'email': 'juan@test.com', 'rol': 'PACIENTE'});
    await sesionLocal.guardar(usuario, 'hash123');
    await almacenToken.guardar('token-valido', DateTime.now().add(const Duration(days: 5)), usuarioId: 1);

    await authVm.cerrarSesion();

    await tester.pumpWidget(crearAppConPila(home: const PantallaArranque()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.text('Tu sesión venció'), findsNothing);
  });
}
