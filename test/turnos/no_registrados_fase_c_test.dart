import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/turnos/datos/fuentes/clienteTurnosApi.dart';
import 'package:mediturnos/turnos/datos/fuentes/local/almacenTurnosLocal.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnosOfflineFirst.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioTurnosImpl.dart';
import 'package:mediturnos/componentes/turnos/tarjetaTurnoPaciente.dart';

class FakeClienteTurnosApi extends Fake implements ClienteTurnosApi {
  List<TurnoDetalle> turnosServidor = [];

  @override
  Future<List<TurnoDetalle>> obtenerTurnos({
    int? pacienteId,
    int? medicoId,
    DateTime? fecha,
    EstadoTurno? estado,
  }) async {
    return turnosServidor;
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('obtenerTurnos como admin (pacienteId null) con conexión: no incluye turnos locales no sincronizados', () async {
    final clienteApi = FakeClienteTurnosApi();
    final almacenLocal = AlmacenTurnosLocal();

    final serverTurno = TurnoDetalle(
      id: 100,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 12, 1),
      hora: '09:00',
      paciente: PacienteDetalle(id: 1, nombre: 'ServerUser', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 1, nombre: 'Dr. Test', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );
    clienteApi.turnosServidor = [serverTurno];

    final localTurno = TurnoDetalle(
      id: -5,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 12, 1),
      hora: '10:00',
      sincronizado: false,
      paciente: PacienteDetalle(id: 2, nombre: 'LocalUser', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 1, nombre: 'Dr. Test', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );
    await almacenLocal.guardarTurnos([localTurno]);

    final repo = RepositorioGestionTurnosOfflineFirst(clienteApi, almacenLocal);

    final resultado = await repo.obtenerTurnos(pacienteId: null);

    expect(resultado.length, equals(1));
    expect(resultado.first.id, equals(100));
  });

  test('obtenerTurnos como paciente con fecha filtrada: locales de otra fecha y de otro paciente no aparecen', () async {
    final clienteApi = FakeClienteTurnosApi();
    final almacenLocal = AlmacenTurnosLocal();

    final turnoTarget = TurnoDetalle(
      id: -10,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 11, 25),
      hora: '10:00',
      sincronizado: false,
      paciente: PacienteDetalle(id: 10, nombre: 'Ana', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 1, nombre: 'Dr. Test', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );

    final turnoOtraFecha = TurnoDetalle(
      id: -11,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 11, 26),
      hora: '11:00',
      sincronizado: false,
      paciente: PacienteDetalle(id: 10, nombre: 'Ana', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 1, nombre: 'Dr. Test', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );

    final turnoOtroPaciente = TurnoDetalle(
      id: -12,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 11, 25),
      hora: '12:00',
      sincronizado: false,
      paciente: PacienteDetalle(id: 99, nombre: 'Pedro', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 1, nombre: 'Dr. Test', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );

    await almacenLocal.guardarTurnos([turnoTarget, turnoOtraFecha, turnoOtroPaciente]);

    final repo = RepositorioGestionTurnosOfflineFirst(clienteApi, almacenLocal);

    final resultado = await repo.obtenerTurnos(
      pacienteId: 10,
      fecha: DateTime(2026, 11, 25),
    );

    expect(resultado.length, equals(1));
    expect(resultado.first.id, equals(-10));
  });

  test('Turno CREAR con error: noRegistrado true, su horario vuelve a estar libre, no cuenta como próximo', () async {
    final almacenLocal = AlmacenTurnosLocal();
    final repoLegacy = RepositorioTurnosImpl();

    final fechaTest = DateTime(2026, 12, 10);
    const horaTest = '14:00';
    const medicoIdTest = 5;

    await almacenLocal.guardarDisponibilidad(medicoIdTest, fechaTest, [
      HorarioDisponible(hora: horaTest, disponible: false),
    ]);

    final turnoFallido = TurnoDetalle(
      id: -123,
      estado: EstadoTurno.pendiente,
      fecha: fechaTest,
      hora: horaTest,
      sincronizado: false,
      errorSincronizacion: 'HORARIO_OCUPADO: El horario no está disponible',
      paciente: PacienteDetalle(id: 10, nombre: 'Carlos', apellido: '', dni: ''),
      medico: MedicoDetalle(id: medicoIdTest, nombre: 'Dr. Garcia', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );

    expect(turnoFallido.noRegistrado, isTrue);
    expect(turnoFallido.esProximo, isFalse);

    await almacenLocal.guardarTurnos([turnoFallido]);
    await repoLegacy.marcarErrorSincronizacion(-123, 'HORARIO_OCUPADO');

    final disponibilidades = await almacenLocal.obtenerDisponibilidad(medicoIdTest, fechaTest);
    expect(disponibilidades.any((h) => h.hora == horaTest && h.disponible), isTrue);
  });

  test('eliminarTurnoLocal: borra un turno con id negativo y NO borra uno sincronizado', () async {
    final almacenLocal = AlmacenTurnosLocal();

    final turnoLocal = TurnoDetalle(
      id: -55,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 12, 15),
      hora: '08:00',
      sincronizado: false,
      paciente: PacienteDetalle(id: 1, nombre: 'User', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 1, nombre: 'Doctor', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );

    final turnoServidor = TurnoDetalle(
      id: 200,
      estado: EstadoTurno.pendiente,
      fecha: DateTime(2026, 12, 15),
      hora: '09:00',
      sincronizado: true,
      paciente: PacienteDetalle(id: 1, nombre: 'User', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 1, nombre: 'Doctor', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );

    await almacenLocal.guardarTurnos([turnoLocal, turnoServidor]);

    final borradoServer = await almacenLocal.eliminarTurnoLocal(200);
    expect(borradoServer, equals(0));
    final tServerGuardado = await almacenLocal.obtenerTurnoPorId(200);
    expect(tServerGuardado, isNotNull);

    final borradoLocal = await almacenLocal.eliminarTurnoLocal(-55);
    expect(borradoLocal, equals(1));
    final tLocalGuardado = await almacenLocal.obtenerTurnoPorId(-55);
    expect(tLocalGuardado, isNull);
  });

  testWidgets('Tarjeta con noRegistrado: no muestra Confirmar asistencia ni Modificar; sí muestra Elegir otro horario y Quitar', (tester) async {
    final turnoNoReg = TurnoDetalle(
      id: -99,
      estado: EstadoTurno.pendiente,
      fecha: DateTime.now().add(const Duration(hours: 2)),
      hora: '10:00',
      sincronizado: false,
      errorSincronizacion: 'Horario ocupado',
      respuestaPaciente: 'SIN_RESPUESTA',
      paciente: PacienteDetalle(id: 1, nombre: 'Ana', apellido: '', dni: ''),
      medico: MedicoDetalle(id: 2, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarjetaTurnoPaciente(
            turno: turnoNoReg,
            alVerDetalle: () {},
          ),
        ),
      ),
    );

    expect(find.text('No registrado'), findsOneWidget);
    expect(find.text('Elegir otro horario'), findsOneWidget);
    expect(find.text('Quitar'), findsOneWidget);

    expect(find.text('Confirmar asistencia'), findsNothing);
    expect(find.text('Modificar'), findsNothing);
    expect(find.text('Cancelar'), findsNothing);
  });
}
