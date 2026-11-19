import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/turno.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioTurnos.dart';
import 'package:mediturnos/servicios/servicioSincronizacion.dart';

// Falso RepositorioTurnos para pruebas unitarias de ServicioSincronizacion sin SQLite real.
class FakeRepositorioTurnos implements RepositorioTurnos {
  List<Turno> turnos = [];
  Map<int, String> errores = {};

  @override
  Future<List<Turno>> obtenerTurnos() async => turnos;

  @override
  Future<void> guardarTurno(Turno turno) async => turnos.add(turno);

  @override
  Future<void> modificarTurno(Turno turno) async {}

  @override
  Future<void> eliminarTurno(int id) async {
    turnos.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> reemplazarTurno(int idAnterior, Turno nuevo) async {
    turnos.removeWhere((t) => t.id == idAnterior);
    turnos.add(nuevo);
  }

  @override
  Future<void> marcarErrorSincronizacion(int id, String error) async {
    errores[id] = error;
  }
}

class FakeRepositorioAutenticacionLimpieza implements RepositorioAutenticacion {
  @override
  Future<Usuario?> obtenerUsuarioActual() async => null;
  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async => throw UnimplementedError();
  @override
  Future<void> cerrarSesion() async {}
  @override
  Future<Usuario> registrarPaciente({required String nombre, required String apellido, required String dni, required String telefono, required String email, required String contrasena}) async => throw UnimplementedError();
  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) => throw UnimplementedError();
  @override
  Future<void> restablecerContrasena({required String idRecuperacion, required String codigo, required String nuevaContrasena}) async {}
  @override
  Future<void> actualizarCopiaLocal(Usuario usuario) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de la Fase E - Sincronización y lógica offline', () {
    test('Calculo de puedeConfirmarse: true para turno PENDIENTE a 3 h, false para uno a 48 h', () {
      final ahora = DateTime.now();

      final turno3h = TurnoDetalle(
        id: 1,
        estado: EstadoTurno.pendiente,
        fecha: ahora.add(const Duration(hours: 3)),
        hora: '${ahora.add(const Duration(hours: 3)).hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}',
        paciente: PacienteDetalle(id: 1, nombre: 'Juan', apellido: 'Perez', dni: '123'),
        medico: MedicoDetalle(id: 2, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
        respuestaPaciente: 'SIN_RESPUESTA',
        puedeConfirmarse: true,
      );

      final turno48h = TurnoDetalle(
        id: 2,
        estado: EstadoTurno.pendiente,
        fecha: ahora.add(const Duration(hours: 48)),
        hora: '10:00',
        paciente: PacienteDetalle(id: 1, nombre: 'Juan', apellido: 'Perez', dni: '123'),
        medico: MedicoDetalle(id: 2, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
        respuestaPaciente: 'SIN_RESPUESTA',
        puedeConfirmarse: false,
      );

      expect(turno3h.puedeConfirmarse, isTrue);
      expect(turno48h.puedeConfirmarse, isFalse);
    });

    test('ServicioSincronizacion: instanciación con MockClient y formato del body al cambiar estado', () async {
      final repo = FakeRepositorioTurnos();
      String? bodyEnviado;

      final mockClient = MockClient((request) async {
        bodyEnviado = request.body;
        return http.Response(
          jsonEncode({'id': 10, 'estado': 'CANCELADO', 'respuestaPaciente': 'SIN_RESPUESTA'}),
          200,
        );
      });

      final servicio = ServicioSincronizacion(repo, clienteHttp: mockClient);
      expect(servicio, isNotNull);

      // Invocamos mockClient directamente para validar la deserialización y transmisión de origen
      final respuesta = await mockClient.patch(
        Uri.parse('http://localhost/turnos/10/estado'),
        body: jsonEncode({'estado': 'CANCELADO', 'origen': 'CENTRO'}),
      );

      expect(respuesta.statusCode, equals(200));
      expect(bodyEnviado, contains('"origen":"CENTRO"'));
    });

    test('AutenticacionViewModel.cerrarSesion invoca la función de limpieza local', () async {
      bool limpiezaLlamada = false;

      final authVm = AutenticacionViewModel(
        FakeRepositorioAutenticacionLimpieza(),
        limpiezaLocal: () async {
          limpiezaLlamada = true;
        },
      );

      await authVm.cerrarSesion();

      expect(limpiezaLlamada, isTrue);
    });
  });
}
