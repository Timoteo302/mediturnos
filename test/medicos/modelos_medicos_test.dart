import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/medicos/datos/modelos/especialidad.dart';
import 'package:mediturnos/medicos/datos/modelos/horarioAtencion.dart';
import 'package:mediturnos/medicos/datos/modelos/franjaHoraria.dart';

void main() {
  group('Modelos de Médicos Tests', () {
    test('Especialidad fromJson con y sin descripcion', () {
      final json1 = {'id': 1, 'nombre': 'Cardiología', 'descripcion': 'Médica', 'activo': true};
      final esp1 = Especialidad.fromJson(json1);
      expect(esp1.id, 1);
      expect(esp1.nombre, 'Cardiología');
      expect(esp1.descripcion, 'Médica');
      expect(esp1.activo, true);

      final json2 = {'id': 2, 'nombre': 'Pediatría', 'activo': false};
      final esp2 = Especialidad.fromJson(json2);
      expect(esp2.descripcion, isNull);
      expect(esp2.activo, false);
    });

    test('Medico fromJson con tildes y matricula null', () {
      final json = {
        'id': 10,
        'nombre': 'María',
        'apellido': 'Gómez',
        'matricula': null,
        'activo': true,
        'especialidad': {'id': 1, 'nombre': 'Cardiología', 'activo': true}
      };
      final medico = Medico.fromJson(json);
      expect(medico.id, 10);
      expect(medico.nombreCompleto, 'María Gómez');
      expect(medico.matricula, isNull);
      expect(medico.iniciales, 'MG');
      expect(medico.especialidad.nombre, 'Cardiología');
    });

    test('HorarioAtencion recorta segundos de horaInicio y horaFin', () {
      final json = {
        'id': 1,
        'diaSemana': 1,
        'horaInicio': '08:30:00',
        'horaFin': '12:30:00',
        'duracionTurno': 30,
        'activo': true,
      };
      final horario = HorarioAtencion.fromJson(json);
      expect(horario.horaInicio, '08:30');
      expect(horario.horaFin, '12:30');
    });

    test('FranjaHoraria getters y consultasPosibles', () {
      final franja = FranjaHoraria(
        inicioMin: FranjaHoraria.horaMinutosAEntero('08:30'),
        finMin: FranjaHoraria.horaMinutosAEntero('12:30'),
      );
      expect(franja.texto, '08:30 a 12:30');
      expect(franja.etiqueta, 'Turno mañana');
      expect(franja.consultasPosibles(30), 8);

      final franjaTarde = FranjaHoraria(
        inicioMin: FranjaHoraria.horaMinutosAEntero('14:00'),
        finMin: FranjaHoraria.horaMinutosAEntero('18:00'),
      );
      expect(franjaTarde.etiqueta, 'Turno tarde');

      final franjaNoche = FranjaHoraria(
        inicioMin: FranjaHoraria.horaMinutosAEntero('20:00'),
        finMin: FranjaHoraria.horaMinutosAEntero('22:00'),
      );
      expect(franjaNoche.etiqueta, 'Turno noche');
    });
  });
}
