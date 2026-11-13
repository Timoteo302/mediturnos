import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Item de día para el carrusel de selección de fecha.
class SelectorDiaTurno extends StatelessWidget {
  final String diaSemana;
  final String numeroDia;
  final bool estaSeleccionado;
  final bool estaHabilitado;
  final VoidCallback onTap;

  const SelectorDiaTurno({
    super.key,
    required this.diaSemana,
    required this.numeroDia,
    required this.estaSeleccionado,
    this.estaHabilitado = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color colorFondo = Colors.white;
    Color colorBorde = const Color(0xFFE2E8F0);
    Color colorTexto = ColoresApp.textoTitulo;

    if (!estaHabilitado) {
      colorFondo = const Color(0xFFFAFAFA);
      colorTexto = ColoresApp.textoHint;
    } else if (estaSeleccionado) {
      colorFondo = ColoresApp.primario;
      colorBorde = ColoresApp.primario;
      colorTexto = Colors.white;
    }

    return GestureDetector(
      onTap: estaHabilitado ? onTap : null,
      child: Container(
        width: 62,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorBorde, width: estaSeleccionado ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(
              diaSemana,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: estaSeleccionado ? Colors.white : ColoresApp.textoSecundario,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              numeroDia,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
