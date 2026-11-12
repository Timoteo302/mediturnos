import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';

class TarjetaParametrosAtencion extends StatelessWidget {
  final int duracionMinutos;
  final List<int> opcionesDuracion;
  final ValueChanged<int> alCambiarDuracion;

  const TarjetaParametrosAtencion({
    super.key,
    required this.duracionMinutos,
    required this.opcionesDuracion,
    required this.alCambiarDuracion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.timer_outlined, color: ColoresApp.primario, size: 20),
              SizedBox(width: 8),
              Text(
                'Duración del turno',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Seleccioná el tiempo asignado por cada consulta médica:',
            style: TextStyle(fontSize: 13, color: ColoresApp.textoSecundario),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opcionesDuracion.map((minutos) {
              final seleccionado = minutos == duracionMinutos;
              return ChoiceChip(
                label: Text('$minutos min'),
                selected: seleccionado,
                onSelected: (_) => alCambiarDuracion(minutos),
                selectedColor: ColoresApp.fondoIcono,
                labelStyle: TextStyle(
                  color: seleccionado ? ColoresApp.primario : ColoresApp.textoTitulo,
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: seleccionado ? ColoresApp.primario : ColoresApp.bordeCampo,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
