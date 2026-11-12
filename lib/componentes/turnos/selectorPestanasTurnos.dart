import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Selector tipo "Pill" para alternar entre "Próximos" e "Historial" en Mis Turnos.
class SelectorPestanasTurnos extends StatelessWidget {
  final bool verProximos;
  final int cantProximos;
  final VoidCallback onSeleccionarProximos;
  final VoidCallback onSeleccionarHistorial;

  const SelectorPestanasTurnos({
    super.key,
    required this.verProximos,
    required this.cantProximos,
    required this.onSeleccionarProximos,
    required this.onSeleccionarHistorial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSeleccionarProximos,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: verProximos ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: verProximos
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Próximos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: verProximos
                            ? ColoresApp.textoTitulo
                            : ColoresApp.textoSecundario,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: verProximos
                            ? ColoresApp.primario
                            : ColoresApp.textoSecundario,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$cantProximos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSeleccionarHistorial,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !verProximos ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: !verProximos
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Historial',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !verProximos
                          ? ColoresApp.textoTitulo
                          : ColoresApp.textoSecundario,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
