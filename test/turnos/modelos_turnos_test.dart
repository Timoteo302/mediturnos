import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/turnos/datos/modelos/estadoTurno.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';
import 'package:mediturnos/turnos/logica/formatoFechaEspanol.dart';

void main() {
  group('Modelos y Lógica de Turnos Tests', () {
    test('TurnoDetalle.fromJson con tildes y teléfono null', () {
      final json = {
        'id': 12,
        'estado': 'PENDIENTE',
        'fecha': '2026-11-13',
        'hora': '09:30:00',
        'claveSolicitud': 'uuid-1234',
        'sincronizado': true,
        'paciente': {
          'id': 1,
          'nombre': 'María',
          'apellido': 'Gómez',
          'dni': '36782904',
          'telefono': null,
        },
        'medico': {
          'id': 3,
          'nombre': 'Ramiro',
          'apellido': 'Vaca',
          'matricula': '98712',
          'especialidad': {'id': 6, 'nombre': 'Traumatología'}
        }
      };

      final turno = TurnoDetalle.fromJson(json);
      expect(turno.id, 12);
      expect(turno.estado, EstadoTurno.pendiente);
      expect(turno.paciente.nombreCompleto, 'María Gómez');
      expect(turno.paciente.telefono, isNull);
      expect(turno.medico.nombreCompleto, 'Ramiro Vaca');
      expect(turno.medico.iniciales, 'RV');
      expect(turno.hora, '09:30');
    });

    test('EstadoTurno fromJson y aTextoApi', () {
      expect(EstadoTurnoExtension.desdeTexto('confirmado'), EstadoTurno.confirmado);
      expect(EstadoTurno.confirmado.aTextoApi(), 'CONFIRMADO');
      expect(EstadoTurno.pendiente.etiqueta, 'Pendiente');
    });

    test('FormatoFechaEspanol fechaLarga y textoTiempoRestante', () {
      final fecha = DateTime(2026, 11, 13);
      expect(FormatoFechaEspanol.nombreDia(fecha), 'Viernes');
      expect(FormatoFechaEspanol.fechaLarga(fecha), 'Viernes, 13 de Noviembre');
    });
  });
}
