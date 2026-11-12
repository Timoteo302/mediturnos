import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../medicos/datos/modelos/franjaHoraria.dart';

class TarjetaFranjaHoraria extends StatelessWidget {
  final FranjaHoraria franja;
  final int duracionTurno;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TarjetaFranjaHoraria({
    super.key,
    required this.franja,
    required this.duracionTurno,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final consultas = franja.consultasPosibles(duracionTurno);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  franja.etiqueta,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  franja.texto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Intervalo: $duracionTurno min ($consultas consultas posibles)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: ColoresApp.primario, size: 20),
                onPressed: onEditar,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onEliminar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
