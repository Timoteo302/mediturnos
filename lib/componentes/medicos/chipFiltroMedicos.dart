import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Chip de filtro por categoría de médicos (Todos, Activos, Inactivos).
class ChipFiltroMedicos extends StatelessWidget {
  final String texto;
  final bool estaSeleccionado;
  final VoidCallback onTap;

  const ChipFiltroMedicos({
    super.key,
    required this.texto,
    required this.estaSeleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: estaSeleccionado ? ColoresApp.primario : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: estaSeleccionado
                ? ColoresApp.primario
                : ColoresApp.bordeCampo,
          ),
        ),
        child: Row(
          children: [
            if (estaSeleccionado) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: estaSeleccionado
                    ? Colors.white
                    : ColoresApp.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
