import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Item de franja horaria individual (Libre, Ocupado, Elegido).
class SelectorHoraTurno extends StatelessWidget {
  final String hora;
  final bool estaDisponible;
  final bool estaSeleccionado;
  final VoidCallback onTap;

  const SelectorHoraTurno({
    super.key,
    required this.hora,
    required this.estaDisponible,
    required this.estaSeleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!estaDisponible) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hora,
              style: const TextStyle(
                fontSize: 14,
                color: ColoresApp.textoHint,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Ocupado',
                style: TextStyle(fontSize: 10, color: ColoresApp.textoSecundario),
              ),
            ),
          ],
        ),
      );
    }

    if (estaSeleccionado) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF60B2FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hora,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Elegido',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hora,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Libre',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ColoresApp.primario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}