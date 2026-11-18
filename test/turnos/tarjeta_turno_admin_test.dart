import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/componentes/admin/tarjetaTurnoAdmin.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';

void main() {
  TurnoDetalle crearTurnoConEstado(EstadoTurno estado) {
    return TurnoDetalle(
      id: 1,
      estado: estado,
      fecha: DateTime(2026, 1, 1),
      hora: '10:00',
      paciente: PacienteDetalle(id: 1, nombre: 'Lucas', apellido: 'González', dni: '38450123'),
      medico: MedicoDetalle(
        id: 2,
        nombre: 'Dr. Perez',
        apellido: '',
        especialidad: EspecialidadDetalle(id: 3, nombre: 'Cardiología'),
      ),
    );
  }

  Widget crearWidgetPrueba(TurnoDetalle turno) {
    return MaterialApp(
      home: Scaffold(
        body: TarjetaTurnoAdmin(
          turno: turno,
          alVerDetalle: () {},
          alLlamar: () {},
          alConfirmar: () {},
          alMarcarAtendido: () {},
          alRechazar: () {},
        ),
      ),
    );
  }

  testWidgets('Muestra botón "Rechazar" cuando el turno está PENDIENTE', (tester) async {
    final turno = crearTurnoConEstado(EstadoTurno.pendiente);
    await tester.pumpWidget(crearWidgetPrueba(turno));

    expect(find.text('Rechazar'), findsOneWidget);
    expect(find.text('Cancelar'), findsNothing);
  });

  testWidgets('Muestra botón "Cancelar" cuando el turno está CONFIRMADO', (tester) async {
    final turno = crearTurnoConEstado(EstadoTurno.confirmado);
    await tester.pumpWidget(crearWidgetPrueba(turno));

    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Rechazar'), findsNothing);
  });

  testWidgets('No muestra "Rechazar" ni "Cancelar" en estado CANCELADO', (tester) async {
    final turno = crearTurnoConEstado(EstadoTurno.cancelado);
    await tester.pumpWidget(crearWidgetPrueba(turno));

    expect(find.text('Rechazar'), findsNothing);
    expect(find.text('Cancelar'), findsNothing);
  });

  testWidgets('No muestra "Rechazar" ni "Cancelar" en estado ATENDIDO', (tester) async {
    final turno = crearTurnoConEstado(EstadoTurno.atendido);
    await tester.pumpWidget(crearWidgetPrueba(turno));

    expect(find.text('Rechazar'), findsNothing);
    expect(find.text('Cancelar'), findsNothing);
  });
}
