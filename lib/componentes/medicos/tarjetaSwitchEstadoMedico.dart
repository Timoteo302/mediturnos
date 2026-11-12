import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta con Switch para activar o desactivar al médico.
class TarjetaSwitchEstadoMedico extends StatelessWidget {
  final bool activo;
  final ValueChanged<bool> alCambiar;

  const TarjetaSwitchEstadoMedico({
    super.key,
    required this.activo,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoIcono,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined,
              color: ColoresApp.primario, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Médico activo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Disponible para asignación de turnos y agenda online',
                  style: TextStyle(
                    fontSize: 11,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: activo,
            activeColor: ColoresApp.primario,
            onChanged: alCambiar,
          ),
        ],
      ),
    );
  }
}
