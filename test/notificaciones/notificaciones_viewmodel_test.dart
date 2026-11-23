import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/notificaciones/datos/modelos/notificacion.dart';
import 'package:mediturnos/notificaciones/datos/repositorios/repositorioNotificaciones.dart';
import 'package:mediturnos/notificaciones/presentacion/viewmodels/notificacionesViewModel.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';

// Repositorios falsos para probar las funcionalidades de NotificacionesViewModel.
class FakeRepositorioNotificaciones implements RepositorioNotificaciones {
  int noLeidasCount = 2;
  bool marcarLeidaLlamado = false;
  bool marcarTodasLlamado = false;

  final List<Notificacion> notificacionesPrueba = [
    Notificacion(
      id: 1,
      tipo: TipoNotificacion.recordatorioAsistencia,
      titulo: 'Recordatorio 1',
      mensaje: 'Mensaje 1',
      leida: false,
      fechaCreacion: DateTime.now(),
      turnoId: 10,
    ),
    Notificacion(
      id: 2,
      tipo: TipoNotificacion.turnoConfirmado,
      titulo: 'Confirmación 2',
      mensaje: 'Mensaje 2',
      leida: false,
      fechaCreacion: DateTime.now(),
      turnoId: 11,
    ),
  ];

  @override
  Future<int> obtenerCantidadNoLeidas({required int usuarioId}) async => noLeidasCount;

  @override
  Future<List<Notificacion>> obtenerNotificaciones({required int usuarioId}) async => notificacionesPrueba;

  @override
  Future<void> marcarLeida({required int id}) async {
    marcarLeidaLlamado = true;
    if (noLeidasCount > 0) noLeidasCount--;
  }

  @override
  Future<void> marcarTodasLeidas({required int usuarioId}) async {
    marcarTodasLlamado = true;
    noLeidasCount = 0;
  }
}

class FakeRepositorioGestionTurnosNotif extends Fake implements RepositorioGestionTurnos {
  int? turnoIdAsistencia;
  bool? asistiraRespuesta;

  final TurnoDetalle turnoPrueba = TurnoDetalle(
    id: 10,
    estado: EstadoTurno.pendiente,
    fecha: DateTime(2026, 7, 1),
    hora: '09:00',
    paciente: PacienteDetalle(id: 1, nombre: 'Ana', apellido: 'Gomez', dni: '12345'),
    medico: MedicoDetalle(id: 2, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
  );

  @override
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira}) async {
    turnoIdAsistencia = turnoId;
    asistiraRespuesta = asistira;
    return turnoPrueba;
  }

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) async => [turnoPrueba];

  @override
  Future<TurnoDetalle> obtenerTurno(int id) async => turnoPrueba;

  @override
  Future<List<HorarioDisponible>> obtenerDisponibilidad({required int medicoId, required DateTime fecha}) async => [];

  @override
  Future<TurnoDetalle> solicitarTurno({required int pacienteId, required int medicoId, required DateTime fecha, required String hora, required String claveSolicitud}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> reprogramarTurno({required int turnoId, required DateTime fecha, required String hora}) async => turnoPrueba;

  @override
  Future<TurnoDetalle> cambiarEstadoTurno({required int turnoId, required EstadoTurno estado, String? origen}) async => turnoPrueba;
}

class FakeRepositorioAutenticacionNotif implements RepositorioAutenticacion {
  final Usuario usuarioPrueba = Usuario(
    id: 100,
    nombre: 'Test',
    apellido: 'User',
    email: 'test@user.com',
    rol: RolUsuario.paciente,
    activo: true,
    fechaCreacion: '2026-01-01',
  );

  @override
  Future<Usuario?> obtenerUsuarioActual() async => usuarioPrueba;

  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async => usuarioPrueba;

  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<Usuario> registrarPaciente({required String nombre, required String apellido, required String dni, required String telefono, required String email, required String contrasena}) async => usuarioPrueba;

  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) => throw UnimplementedError();

  @override
  Future<void> restablecerContrasena({required String idRecuperacion, required String codigo, required String nuevaContrasena}) async {}

  @override
  Future<void> actualizarCopiaLocal(Usuario usuario) async {}
}

class FakeServicioSincNotif extends ServicioMonitoreoSincronizacion {
  @override
  Future<void> iniciar() async {}
  @override
  void detener() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeRepositorioNotificaciones repoNotif;
  late FakeRepositorioGestionTurnosNotif repoTurnos;
  late FakeRepositorioAutenticacionNotif repoAuth;
  late AutenticacionViewModel authVm;
  late EstadoConexionViewModel conexionVm;
  late NotificacionesViewModel vm;

  setUp(() async {
    repoNotif = FakeRepositorioNotificaciones();
    repoTurnos = FakeRepositorioGestionTurnosNotif();
    repoAuth = FakeRepositorioAutenticacionNotif();
    authVm = AutenticacionViewModel(repoAuth);
    await authVm.actualizarUsuarioActual(repoAuth.usuarioPrueba);
    conexionVm = EstadoConexionViewModel(FakeServicioSincNotif(), verificadorConexion: () async => true);

    vm = NotificacionesViewModel(
      repositorioNotificaciones: repoNotif,
      repositorioTurnos: repoTurnos,
      authVm: authVm,
      conexionVm: conexionVm,
    );
  });

  tearDown(() {
    vm.dispose();
    conexionVm.dispose();
  });

  test('NotificacionesViewModel cuenta notificaciones no leídas correctamente', () async {
    await vm.consultarCantidadNoLeidas();
    expect(vm.cantidadNoLeidas, equals(2));
  });

  test('marcarLeida disminuye el contador de no leídas', () async {
    await vm.cargar();
    expect(vm.cantidadNoLeidas, equals(2));

    await vm.marcarLeida(1);

    expect(repoNotif.marcarLeidaLlamado, isTrue);
    expect(vm.cantidadNoLeidas, equals(1));
  });

  test('responderAsistencia(false) llama al repositorio de turnos con asistira = false', () async {
    final resultado = await vm.responderAsistencia(10, false);

    expect(resultado, isNotNull);
    expect(repoTurnos.turnoIdAsistencia, equals(10));
    expect(repoTurnos.asistiraRespuesta, isFalse);
  });
}
