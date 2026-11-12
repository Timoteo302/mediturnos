import 'package:flutter/material.dart';

/// Cuadro de aviso ámbar sobre la revisión de la solicitud de turno.
class AvisoImportanteRevision extends StatelessWidget {
  const AvisoImportanteRevision({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: Color(0xFFD97706), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aviso importante sobre tu solicitud',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Al presionar confirmar, tu solicitud ingresará en revisión de agenda. El turno quedará pendiente hasta que el sistema y el centro médico verifiquen la disponibilidad definitiva.',
                  style: TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
