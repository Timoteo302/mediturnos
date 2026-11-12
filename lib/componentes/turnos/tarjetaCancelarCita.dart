import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta para la cancelación del turno asignado.
class TarjetaCancelarCita extends StatelessWidget {
  final VoidCallback onCancelar;

  const TarjetaCancelarCita({
    super.key,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626), size: 22),
              SizedBox(width: 8),
              Text(
                '¿Necesitás cancelar la cita médica?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Al cancelar, el cupo quedará libre para otro paciente. Esta acción no se puede deshacer.',
            style: TextStyle(
              fontSize: 12,
              color: ColoresApp.textoSecundario,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onCancelar,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text(
                'Cancelar este turno',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
