import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaOlvideContrasena.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/medicos/datos/repositorios/repositorioMedicos.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';

class FakeRepositorioAutenticacion implements RepositorioAutenticacion {
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
    return SolicitudRecuperacion(
      idRecuperacion: 'solicitud-123',
      venceEnMinutos: 10,
      codigoDemostracion: '123456',
    );
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

class FakeRepositorioGestionTurnos implements RepositorioGestionTurnos {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRepositorioMedicos implements RepositorioMedicos {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late EstadoConexionViewModel conexionVm;
  late AutenticacionViewModel authVm;
  late FakeRepositorioAutenticacion repoAuth;

  setUp(() {
    repoAuth = FakeRepositorioAutenticacion();
    conexionVm = EstadoConexionViewModel(
      ServicioSincronizacionFake(),
      verificadorConexion: () async => true,
    );
    authVm = AutenticacionViewModel(repoAuth);
  });

  tearDown(() {
    conexionVm.dispose();
    authVm.dispose();
  });

  Widget crearWidgetTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EstadoConexionViewModel>.value(value: conexionVm),
        ChangeNotifierProvider<AutenticacionViewModel>.value(value: authVm),
        Provider<RepositorioAutenticacion>.value(value: repoAuth),
        Provider<RepositorioGestionTurnos>(create: (_) => FakeRepositorioGestionTurnos()),
        Provider<RepositorioMedicos>(create: (_) => FakeRepositorioMedicos()),
      ],
      child: const MaterialApp(
        home: PantallaLogin(),
      ),
    );
  }

  testWidgets('Flujo: Login -> ¿Olvidaste tu contraseña? -> restablecer exitoso -> vuelve a PantallaLogin', (tester) async {
    await tester.pumpWidget(crearWidgetTest());

    // 1. Verificar que estamos en PantallaLogin
    expect(find.byType(PantallaLogin), findsOneWidget);

    // 2. Tocar en "¿Olvidaste tu contraseña?"
    final enlaceOlvide = find.text('¿Olvidaste tu contraseña?');
    expect(enlaceOlvide, findsOneWidget);
    await tester.tap(enlaceOlvide);
    await tester.pumpAndSettle();

    // 3. Verificar que estamos en PantallaOlvideContrasena
    expect(find.byType(PantallaOlvideContrasena), findsOneWidget);

    // 4. Ingresar correo para solicitar código
    final campoCorreo = find.widgetWithText(TextField, 'Correo electrónico registrado');
    expect(campoCorreo, findsOneWidget);
    await tester.enterText(campoCorreo, 'usuario@test.com');

    // 5. Presionar botón "Enviar código de recuperación"
    final botonEnviar = find.text('Enviar código de recuperación');
    expect(botonEnviar, findsOneWidget);
    await tester.ensureVisible(botonEnviar);
    await tester.tap(botonEnviar);
    await tester.pumpAndSettle();

    // 6. Cerrar el diálogo del código de demostración si aparece
    final botonAceptarDialogo = find.text('Aceptar');
    if (botonAceptarDialogo.evaluate().isNotEmpty) {
      await tester.tap(botonAceptarDialogo);
      await tester.pumpAndSettle();
    }

    // 7. En el paso de restablecer, ingresar código de 6 dígitos y la nueva contraseña
    final campoCodigo = find.widgetWithText(TextField, 'Código de 6 dígitos');
    expect(campoCodigo, findsOneWidget);
    await tester.enterText(campoCodigo, '123456');

    final campoNuevaClave = find.widgetWithText(TextField, 'Nueva contraseña');
    expect(campoNuevaClave, findsOneWidget);
    await tester.enterText(campoNuevaClave, '12345678');

    final campoConfirmarClave = find.widgetWithText(TextField, 'Confirmar contraseña');
    expect(campoConfirmarClave, findsOneWidget);
    await tester.enterText(campoConfirmarClave, '12345678');

    // 8. Presionar botón "Cambiar contraseña"
    final botonCambiar = find.text('Cambiar contraseña');
    expect(botonCambiar, findsOneWidget);
    await tester.ensureVisible(botonCambiar);
    await tester.pumpAndSettle();
    await tester.tap(botonCambiar);
    await tester.pumpAndSettle();

    // 9. Verificar que volvimos a PantallaLogin y PantallaOlvideContrasena ya no está
    expect(find.byType(PantallaOlvideContrasena), findsNothing);
    expect(find.byType(PantallaLogin), findsOneWidget);
  });
}
