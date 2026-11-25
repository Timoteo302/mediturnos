import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mediturnos/configuracion/baseDatosLocal.dart';
import 'package:mediturnos/servicios/servicioSincronizacion.dart';
import 'package:mediturnos/turnos/datos/modelos/turno.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioTurnos.dart';

class RepositorioTurnosSincronizacionFake implements RepositorioTurnos {
  final List<Turno> _turnos = [];
  final Map<int, String> errores = {};

  @override
  Future<List<Turno>> obtenerTurnos() async => _turnos;

  @override
  Future<void> guardarTurno(Turno turno) async {
    _turnos.add(turno);
  }

  @override
  Future<void> marcarErrorSincronizacion(int id, String error) async {
    errores[id] = error;
  }

  @override
  Future<void> modificarTurno(Turno turno) async {}

  @override
  Future<void> eliminarTurno(int id) async {}

  @override
  Future<void> reemplazarTurno(int idAnterior, Turno turno) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await BaseDatosLocal.obtenerBaseDatos();
    await db.delete('turnos');
  });

  test('Un 401 durante sincronización interrumpe sin marcar turnos como error', () async {
    final repo = RepositorioTurnosSincronizacionFake();
    final turnoPendiente = Turno(
      id: -1,
      paciente: 'Paciente Test',
      medico: 'Medico Test',
      especialidad: 'Cardiología',
      fecha: '2026-11-25',
      hora: '10:00',
      estado: 'PENDIENTE',
      sincronizado: false,
      pacienteId: 1,
      medicoId: 1,
      claveSolicitud: 'clave-123',
    );
    await repo.guardarTurno(turnoPendiente);

    final mockClient = MockClient((request) async {
      return http.Response('{"codigo":"NO_AUTENTICADO"}', 401);
    });

    final servicio = ServicioSincronizacion(repo, clienteHttp: mockClient);
    await servicio.sincronizar();

    expect(repo.errores.isEmpty, isTrue);
  });
}
