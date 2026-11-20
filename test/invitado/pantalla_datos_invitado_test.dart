import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/turnos/tarjetaResumenTurno.dart';
import 'package:mediturnos/invitado/datos/modelos/resultadoReservaInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitado.dart';
import 'package:mediturnos/invitado/presentacion/pantallas/pantallaDatosInvitado.dart';
import 'package:mediturnos/medicos/datos/modelos/especialidad.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';

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

class RepositorioInvitadoWidgetFake implements RepositorioInvitado {
  @override
  Future<ResultadoReservaInvitado> reservarComoInvitado({
    required String nombre,
    required String apellido,
    required String dni,
    required String email,
    required String telefono,
    required int medicoId,
    required DateTime fecha,
    required String hora,
    required String claveSolicitud,
  }) async {
    return ResultadoReservaInvitado(
      turno: TurnoDetalle(
        id: 1,
        estado: EstadoTurno.pendiente,
        fecha: fecha,
        hora: hora,
        paciente: PacienteDetalle(id: 1, nombre: nombre, apellido: apellido, dni: dni),
        medico: MedicoDetalle(
          id: medicoId,
          nombre: 'Dr. Lopez',
          apellido: '',
          especialidad: EspecialidadDetalle(id: 1, nombre: 'Pediatría'),
        ),
      ),
      email: email,
      venceEnDias: 3,
    );
  }

  @override
  Future<Map<String, dynamic>> confirmarActivacion({
    required String email,
    required String codigo,
    required String contrasena,
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> reenviarActivacion({required String email}) async {
    return {};
  }
}

void main() {
  late EstadoConexionViewModel conexionVm;
  late AutenticacionViewModel authVm;

  setUp(() {
    conexionVm = EstadoConexionViewModel(
      ServicioSincronizacionFake(),
      verificadorConexion: () async => true,
    );
    authVm = AutenticacionViewModel(RepositorioAutenticacionFake());
  });

  tearDown(() {
    conexionVm.dispose();
    authVm.dispose();
  });

  Widget crearWidgetTest({required bool conectado, required EstadoConexionViewModel conexionModel}) {
    final medico = Medico(
      id: 1,
      nombre: 'Dr. Lopez',
      apellido: '',
      matricula: '12345',
      activo: true,
      especialidad: Especialidad(id: 1, nombre: 'Pediatría', activo: true),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EstadoConexionViewModel>.value(value: conexionModel),
        ChangeNotifierProvider<AutenticacionViewModel>.value(value: authVm),
        Provider<RepositorioInvitado>(create: (_) => RepositorioInvitadoWidgetFake()),
      ],
      child: MaterialApp(
        home: PantallaDatosInvitado(
          medico: medico,
          fecha: DateTime(2026, 12, 10),
          hora: '09:00',
        ),
      ),
    );
  }

  testWidgets('Muestra el resumen del turno en PantallaDatosInvitado', (tester) async {
    await tester.pumpWidget(crearWidgetTest(conectado: true, conexionModel: conexionVm));

    expect(find.byType(TarjetaResumenTurno), findsOneWidget);
    expect(find.textContaining('Dr. Lopez'), findsWidgets);
    expect(find.textContaining('09:00'), findsOneWidget);
  });

  testWidgets('Bloquea el botón de confirmar turno si conectado es false', (tester) async {
    final conexionVmOffline = EstadoConexionViewModel(
      ServicioSincronizacionFake(),
      verificadorConexion: () async => false,
    );
    await conexionVmOffline.chequearConexionParaTest(esInicial: true);

    await tester.pumpWidget(crearWidgetTest(conectado: false, conexionModel: conexionVmOffline));

    expect(find.textContaining('Necesitás conexión para crear tu cuenta'), findsOneWidget);

    final botonFinder = find.widgetWithText(BotonPrincipal, 'Confirmar turno');
    expect(botonFinder, findsOneWidget);
    final BotonPrincipal boton = tester.widget(botonFinder);
    expect(boton.onPressed, isNull);

    conexionVmOffline.dispose();
  });
}
