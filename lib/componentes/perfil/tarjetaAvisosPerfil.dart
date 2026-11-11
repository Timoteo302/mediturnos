import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Fila con interruptor de configuración (Switch) para notificaciones.
class ItemAvisoSwitch extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const ItemAvisoSwitch({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: ColoresApp.textoSecundario, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: ColoresApp.primario,
          ),
        ],
      ),
    );
  }
}