import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';

class SelectorDiasSemanaAgenda extends StatelessWidget {
  final Set<int> diasActivos;
  final ValueChanged<int> alAlternarDia;

  const SelectorDiasSemanaAgenda({
    super.key,
    required this.diasActivos,
    required this.alAlternarDia,
  });

  static const _dias = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _dias.entries.map((entry) {
        final diaId = entry.key;
        final nombreDia = entry.value;
        final activo = diasActivos.contains(diaId);

        return FilterChip(
          label: Text(nombreDia),
          selected: activo,
          onSelected: (_) => alAlternarDia(diaId),
          selectedColor: ColoresApp.fondoIcono,
          checkmarkColor: ColoresApp.primario,
          labelStyle: TextStyle(
            color: activo ? ColoresApp.primario : ColoresApp.textoTitulo,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: activo ? ColoresApp.primario : ColoresApp.bordeCampo,
            ),
          ),
        );
      }).toList(),
    );
  }
}
