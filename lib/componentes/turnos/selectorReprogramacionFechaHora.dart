import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Componente para la selección de nuevo día y hora al reprogramar un turno.
class SelectorReprogramacionFechaHora extends StatelessWidget {
  final int diaSeleccionadoIndex;
  final String horarioSeleccionado;
  final ValueChanged<int> alSeleccionarDia;
  final ValueChanged<String> alSeleccionarHorario;

  const SelectorReprogramacionFechaHora({
    super.key,
    required this.diaSeleccionadoIndex,
    required this.horarioSeleccionado,
    required this.alSeleccionarDia,
    required this.alSeleccionarHorario,
  });

  @override
  Widget build(BuildContext context) {
    final String diaTextoActual =
        diaSeleccionadoIndex == 0 ? 'Viernes 25 Octubre' : 'Lunes 28 Octubre';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.refresh, color: ColoresApp.primario, size: 20),
            SizedBox(width: 8),
            Text(
              'Reprogramar para otra fecha',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Elegí una nueva fecha y horario disponible. Si el nuevo turno no se confirma, tu turno actual seguirá reservado.',
          style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
        ),

        const SizedBox(height: 16),

        // Paso 1: Seleccionar día disponible
        const Text(
          '1. Seleccionar día disponible',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Día 1
            Expanded(
              child: GestureDetector(
                onTap: () => alSeleccionarDia(0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: diaSeleccionadoIndex == 0
                          ? ColoresApp.primario
                          : ColoresApp.bordeCampo,
                      width: diaSeleccionadoIndex == 0 ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Más próximo',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: ColoresApp.primario,
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.check_circle,
                              size: 18, color: ColoresApp.primario),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Viernes 25 Octubre',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '2 cupos libres',
                        style: TextStyle(
                            fontSize: 11, color: ColoresApp.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Día 2
            Expanded(
              child: GestureDetector(
                onTap: () => alSeleccionarDia(1),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: diaSeleccionadoIndex == 1
                          ? ColoresApp.primario
                          : ColoresApp.bordeCampo,
                      width: diaSeleccionadoIndex == 1 ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Semana próxima',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: ColoresApp.textoSecundario)),
                          Icon(Icons.radio_button_unchecked,
                              size: 18, color: ColoresApp.textoSecundario),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Lunes 28 Octubre',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '3 cupos libres',
                        style: TextStyle(
                            fontSize: 11, color: ColoresApp.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Paso 2: Horarios disponibles
        Text(
          '2. Horarios disponibles para el $diaTextoActual',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Horario 1 (09:30 hs)
            Expanded(
              child: GestureDetector(
                onTap: () => alSeleccionarHorario('09:30 hs'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: horarioSeleccionado == '09:30 hs'
                        ? ColoresApp.fondoIcono
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: horarioSeleccionado == '09:30 hs'
                          ? ColoresApp.primario
                          : ColoresApp.bordeCampo,
                      width: horarioSeleccionado == '09:30 hs' ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.access_time,
                              size: 18, color: ColoresApp.primario),
                          SizedBox(width: 8),
                          Text(
                            '09:30 hs',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.textoTitulo,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColoresApp.bordeCampo),
                        ),
                        child: const Text('Libre',
                            style: TextStyle(
                                fontSize: 10,
                                color: ColoresApp.primario,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Horario 2 (11:15 hs)
            Expanded(
              child: GestureDetector(
                onTap: () => alSeleccionarHorario('11:15 hs'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: horarioSeleccionado == '11:15 hs'
                        ? ColoresApp.fondoIcono
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: horarioSeleccionado == '11:15 hs'
                          ? ColoresApp.primario
                          : ColoresApp.bordeCampo,
                      width: horarioSeleccionado == '11:15 hs' ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.access_time,
                              size: 18, color: ColoresApp.textoSecundario),
                          SizedBox(width: 8),
                          Text(
                            '11:15 hs',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.textoTitulo,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ColoresApp.bordeCampo),
                        ),
                        child: const Text('Libre',
                            style: TextStyle(
                                fontSize: 10,
                                color: ColoresApp.textoSecundario,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
