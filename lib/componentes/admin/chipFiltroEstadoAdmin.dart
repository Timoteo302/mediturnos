import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Chip de filtro por estado (Todos, Pendientes, Confirmados) con contador para el administrador.
class ChipFiltroEstadoAdmin extends StatelessWidget {
  final String etiqueta;
  final String cantidad;
  final bool seleccionado;
  final VoidCallback onTap;

  const ChipFiltroEstadoAdmin({
    super.key,
    required this.etiqueta,
    required this.cantidad,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? ColoresApp.textoTitulo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? ColoresApp.textoTitulo : ColoresApp.bordeCampo,
          ),
        ),
        child: Row(
          children: [
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: seleccionado ? Colors.white : ColoresApp.textoTitulo,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: seleccionado ? ColoresApp.primario : ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                cantidad,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: seleccionado ? Colors.white : ColoresApp.primario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
