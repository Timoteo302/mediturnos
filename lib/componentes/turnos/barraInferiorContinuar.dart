import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Barra inferior flotante para confirmar el horario seleccionado y continuar.
class BarraInferiorContinuar extends StatelessWidget {
  final String resumenTurno;
  final String pasoTexto;
  final VoidCallback onContinuar;

  const BarraInferiorContinuar({
    super.key,
    required this.resumenTurno,
    this.pasoTexto = 'Paso 2 de 3',
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Turno seleccionado',
                      style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resumenTurno,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    pasoTexto,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primario,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BotonPrincipal(
              texto: 'Continuar ➔',
              onPressed: onContinuar,
            ),
          ],
        ),
      ),
    );
  }
}