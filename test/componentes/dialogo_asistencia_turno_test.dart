import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/configuracion/clavesGlobales.dart';
import 'package:mediturnos/notificaciones/datos/modelos/notificacion.dart';
import 'package:mediturnos/notificaciones/datos/repositorios/repositorioNotificaciones.dart';
import 'package:mediturnos/notificaciones/presentacion/viewmodels/notificacionesViewModel.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'package:mediturnos/componentes/turnos/dialogoAsistenciaTurno.dart';

// Clases de prueba falsas para instanciar el diálogo de asistencia a turnos.
class FakeRepositorioNotificacionesDialogo implements RepositorioNotificaciones {
  @override
  Future<int> obtenerCantidadNoLeidas({required int usuarioId}) async => 0;
  @override
  Future<List<Notificacion>> obtenerNotificaciones({required int usuarioId}) async => [];
  @override
  Future<void> marcarLeida({required int id}) async {}
  @override
  Future<void> marcarTodasLeidas({required int usuarioId}) async {}
}

class FakeRepositorioGestionTurnosDialogo implements RepositorioGestionTurnos {
  final TurnoDetalle turnoPrueba = TurnoDetalle(
    id: 5,
    estado: EstadoTurno.cancelado,
    fecha: DateTime(2026, 8, 10),
    hora: '11:00',
    paciente: PacienteDetalle(id: 1, nombre: 'Juan', apellido: 'Perez', dni: '123'),
    medico: MedicoDetalle(id: 2, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
  );

  @override
  Future<TurnoDetalle> responderAsistencia({required int turnoId, required bool asistira}) async => turnoPrueba;

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({int? pacienteId, int? medicoId, DateTime? fecha, EstadoTurno? estado}) async => [];

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

class FakeRepositorioAutenticacionDialogo implements RepositorioAutenticacion {
  final Usuario usuarioPrueba = Usuario(id: 1, nombre: 'J', apellido: 'P', email: 'j@p.com', rol: RolUsuario.paciente, activo: true, fechaCreacion: '2026-01-01');

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

class FakeServicioSincDialogo extends ServicioMonitoreoSincronizacion {
  @override
  Future<void> iniciar() async {}
  @override
  void detener() {}
}

void main() {
  testWidgets('Tocar "No puedo ir" en DialogoAsistenciaTurno abre un segundo diálogo pidiendo confirmación de cancelación', (tester) async {
    final repoNotif = FakeRepositorioNotificacionesDialogo();
    final repoTurnos = FakeRepositorioGestionTurnosDialogo();
    final authVm = AutenticacionViewModel(FakeRepositorioAutenticacionDialogo());
    final conexionVm = EstadoConexionViewModel(FakeServicioSincDialogo(), verificadorConexion: () async => true);

    final notifVm = NotificacionesViewModel(
      repositorioNotificaciones: repoNotif,
      repositorioTurnos: repoTurnos,
      authVm: authVm,
      conexionVm: conexionVm,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificacionesViewModel>.value(value: notifVm),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: Scaffold(
            body: DialogoAsistenciaTurno(
              turnoId: 5,
              medicoNombre: 'Dr. Lopez',
              fechaTexto: '10/8/2026',
              hora: '11:00',
            ),
          ),
        ),
      ),
    );

    expect(find.text('¿Vas a asistir a tu turno?'), findsOneWidget);

    // Tocamos "No puedo ir"
    await tester.tap(find.text('No puedo ir'));
    await tester.pumpAndSettle();

    // Verificamos que se despliega la segunda confirmación aclarando que el turno se cancela.
    expect(find.text('Tu turno se va a cancelar y el horario queda libre.'), findsOneWidget);
    expect(find.text('Sí, cancelar'), findsOneWidget);

    // Limpiamos los viewmodels para cancelar timers pendientes
    notifVm.dispose();
    conexionVm.dispose();
  });
}
