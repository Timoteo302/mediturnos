import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Chip reutilizable para filtros por categoría o especialidad.
class FiltroCategoriaChip extends StatelessWidget {
  final String texto;
  final bool estaSeleccionado;
  final VoidCallback onTap;

  const FiltroCategoriaChip({
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
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: estaSeleccionado ? const Color(0xFFE8F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: estaSeleccionado ? ColoresApp.primario : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (estaSeleccionado) ...[
              const Icon(Icons.check, size: 16, color: ColoresApp.primario),
              const SizedBox(width: 4),
            ],
            Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.normal,
                color: estaSeleccionado ? ColoresApp.primario : ColoresApp.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}