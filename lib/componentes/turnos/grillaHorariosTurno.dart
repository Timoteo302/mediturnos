import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/turnos/selectorHoraTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Componente de grillas de horarios por turno (Mañana y Tarde).
class GrillaHorariosTurno extends StatelessWidget {
  final String horaSeleccionada;
  final ValueChanged<String> alSeleccionarHora;

  const GrillaHorariosTurno({
    super.key,
    required this.horaSeleccionada,
    required this.alSeleccionarHora,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Turno Mañana
        const Row(
          children: [
            Icon(Icons.wb_sunny_outlined, size: 16, color: ColoresApp.textoSecundario),
            SizedBox(width: 6),
            Text(
              'Turno mañana',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoSecundario),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _construirFilaHorarios('09:00 hs', true, '09:30 hs', true),
        const SizedBox(height: 10),
        _construirFilaHorarios('10:00 hs', false, '10:30 hs', true),
        const SizedBox(height: 10),
        _construirFilaHorarios('11:15 hs', true, '11:45 hs', false),

        const SizedBox(height: 16),

        // Turno Tarde
        const Row(
          children: [
            Icon(Icons.nights_stay_outlined, size: 16, color: ColoresApp.textoSecundario),
            SizedBox(width: 6),
            Text(
              'Turno tarde',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoSecundario),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _construirFilaHorarios('16:00 hs', true, '16:45 hs', true),
        const SizedBox(height: 10),
        _construirFilaHorarios('17:15 hs', false, null, false),
      ],
    );
  }

  Widget _construirFilaHorarios(String hora1, bool disp1, String? hora2, bool disp2) {
    return Row(
      children: [
        Expanded(
          child: SelectorHoraTurno(
            hora: hora1,
            estaDisponible: disp1,
            estaSeleccionado: horaSeleccionada == hora1,
            onTap: () => alSeleccionarHora(hora1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: hora2 != null
              ? SelectorHoraTurno(
            hora: hora2,
            estaDisponible: disp2,
            estaSeleccionado: horaSeleccionada == hora2,
            onTap: () => alSeleccionarHora(hora2),
          )
              : const SizedBox(),
        ),
      ],
    );
  }
}