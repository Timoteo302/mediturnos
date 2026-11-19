import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mediturnos/configuracion/baseDatosLocal.dart';
import 'package:mediturnos/turnos/datos/fuentes/local/almacenTurnosLocal.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/horarioDisponible.dart';
import 'package:mediturnos/servicios/servicioLimpiezaLocal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AlmacenTurnosLocal almacen;

  setUp(() async {
    await BaseDatosLocal.reiniciarParaTests(ruta: inMemoryDatabasePath);
    almacen = AlmacenTurnosLocal();
  });

  tearDown(() async {
    await BaseDatosLocal.reiniciarParaTests();
  });

  group('Pruebas SQLite Real - AlmacenTurnosLocal y Limpieza', () {
    test('AlmacenTurnosLocal: guardar y leer respuestaPaciente correctamente en SQLite', () async {
      final turno = TurnoDetalle(
        id: 1,
        estado: EstadoTurno.pendiente,
        fecha: DateTime(2026, 7, 20),
        hora: '11:00',
        paciente: PacienteDetalle(id: 10, nombre: 'Laura', apellido: 'Gomez', dni: '99999'),
        medico: MedicoDetalle(id: 20, nombre: 'Dr. Ruiz', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'Dermatología')),
        sincronizado: false,
        respuestaPaciente: 'ASISTIRA',
      );

      await almacen.guardarTurnos([turno]);

      final recuperados = await almacen.obtenerTurnos();
      expect(recuperados.length, equals(1));
      expect(recuperados.first.id, equals(1));
      expect(recuperados.first.respuestaPaciente, equals('ASISTIRA'));
    });

    test('AlmacenTurnosLocal: reprogramar turno CONFIRMADO sin conexión lo deja PENDIENTE y respuesta SIN_RESPUESTA', () async {
      final turnoConfirmado = TurnoDetalle(
        id: 2,
        estado: EstadoTurno.confirmado,
        fecha: DateTime(2026, 7, 20),
        hora: '11:00',
        paciente: PacienteDetalle(id: 10, nombre: 'Laura', apellido: 'Gomez', dni: '99999'),
        medico: MedicoDetalle(id: 20, nombre: 'Dr. Ruiz', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'Dermatología')),
        sincronizado: true,
        respuestaPaciente: 'ASISTIRA',
      );

      await almacen.guardarTurnos([turnoConfirmado]);

      // Reprogramamos la fecha y hora sin conexión
      final actualizado = await almacen.actualizarTurnoOffline(
        turnoId: 2,
        nuevaFecha: DateTime(2026, 7, 21),
        nuevaHora: '12:00',
        operacionPendiente: 'REPROGRAMAR',
      );

      expect(actualizado, isNotNull);
      expect(actualizado!.estado, equals(EstadoTurno.pendiente));
      expect(actualizado.respuestaPaciente, equals('SIN_RESPUESTA'));
      expect(actualizado.sincronizado, isFalse);
    });

    test('AlmacenTurnosLocal: marcarHorarioLocal ocupa y libera un horario en SQLite', () async {
      final medicoId = 5;
      final fecha = DateTime(2026, 8, 1);

      await almacen.guardarDisponibilidad(medicoId, fecha, [
        HorarioDisponible(hora: '09:00', disponible: true),
        HorarioDisponible(hora: '09:30', disponible: true),
      ]);

      // Ocupamos la franja de las 09:00 (disponible = false)
      await almacen.marcarHorarioLocal(medicoId, fecha, '09:00', disponible: false);

      var disponibilidades = await almacen.obtenerDisponibilidad(medicoId, fecha);
      expect(disponibilidades.firstWhere((h) => h.hora == '09:00').disponible, isFalse);

      // Liberamos nuevamente la franja de las 09:00 (disponible = true)
      await almacen.marcarHorarioLocal(medicoId, fecha, '09:00', disponible: true);

      disponibilidades = await almacen.obtenerDisponibilidad(medicoId, fecha);
      expect(disponibilidades.firstWhere((h) => h.hora == '09:00').disponible, isTrue);
    });

    test('limpiarDatosAlCerrarSesion: borra los turnos con sincronizado = 1 y disponibilidades, dejando los de sincronizado = 0', () async {
      final turnoGuardadoSincronizado = TurnoDetalle(
        id: 10,
        estado: EstadoTurno.confirmado,
        fecha: DateTime(2026, 9, 1),
        hora: '10:00',
        paciente: PacienteDetalle(id: 1, nombre: 'Ana', apellido: 'Perez', dni: '111'),
        medico: MedicoDetalle(id: 2, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
        sincronizado: true,
      );

      final turnoPendienteOffline = TurnoDetalle(
        id: -1,
        estado: EstadoTurno.pendiente,
        fecha: DateTime(2026, 9, 2),
        hora: '11:00',
        paciente: PacienteDetalle(id: 1, nombre: 'Ana', apellido: 'Perez', dni: '111'),
        medico: MedicoDetalle(id: 2, nombre: 'Dr. Lopez', apellido: '', especialidad: EspecialidadDetalle(id: 1, nombre: 'General')),
        sincronizado: false,
      );

      await almacen.guardarTurnos([turnoGuardadoSincronizado]);
      await almacen.guardarTurnos([turnoPendienteOffline], operacionPendiente: 'CREAR');

      await almacen.guardarDisponibilidad(2, DateTime(2026, 9, 1), [
        HorarioDisponible(hora: '10:00', disponible: false),
      ]);

      // Ejecutamos la limpieza al cerrar sesión
      await limpiarDatosAlCerrarSesion();

      final turnosRestantes = await almacen.obtenerTurnos();
      expect(turnosRestantes.length, equals(1));
      expect(turnosRestantes.first.id, equals(-1));
      expect(turnosRestantes.first.sincronizado, isFalse);

      final disponibilidadesRestantes = await almacen.obtenerDisponibilidad(2, DateTime(2026, 9, 1));
      expect(disponibilidadesRestantes, isEmpty);
    });
  });
}
