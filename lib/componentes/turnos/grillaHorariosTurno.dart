import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/horarioDisponible.dart';

/// Grilla interactiva para seleccionar la hora del turno entre los horarios disponibles.
class GrillaHorariosTurno extends StatelessWidget {
  final List<HorarioDisponible> horarios;
  final String? horaSeleccionada;
  final ValueChanged<String> alSeleccionarHora;
  final bool cargando;

  const GrillaHorariosTurno({
    super.key,
    required this.horarios,
    required this.horaSeleccionada,
    required this.alSeleccionarHora,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (horarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            'No hay horarios disponibles para esta fecha.',
            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: horarios.length,
      itemBuilder: (context, index) {
        final h = horarios[index];
        final seleccionado = h.hora == horaSeleccionada;
        final disponible = h.disponible;

        return InkWell(
          onTap: disponible ? () => alSeleccionarHora(h.hora) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: seleccionado
                  ? ColoresApp.primario
                  : disponible
                      ? Colors.white
                      : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: seleccionado
                    ? ColoresApp.primario
                    : disponible
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              h.hora,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: seleccionado
                    ? Colors.white
                    : disponible
                        ? ColoresApp.textoTitulo
                        : ColoresApp.textoHint,
              ),
            ),
          ),
        );
      },
    );
  }
}
