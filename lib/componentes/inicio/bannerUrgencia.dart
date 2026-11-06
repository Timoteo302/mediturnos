import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Banner informativo de urgencias médicas.
class BannerUrgencia extends StatelessWidget {
  final String numeroUrgencia;

  const BannerUrgencia({
    super.key,
    this.numeroUrgencia = '107',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.health_and_safety_outlined,
            color: ColoresApp.primario,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(text: '¿Tenés una urgencia médica? Llamá al '),
                  TextSpan(
                    text: numeroUrgencia,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primario,
                    ),
                  ),
                  const TextSpan(
                    text: ' o acercate a la guardia central de inmediato.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}