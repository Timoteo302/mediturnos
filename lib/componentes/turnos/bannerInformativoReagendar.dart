import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Banner informativo que explica que la reserva actual se mantiene hasta confirmar el nuevo horario.
class BannerInformativoReagendar extends StatelessWidget {
  const BannerInformativoReagendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: ColoresApp.primario, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Podés reagendar tu consulta sin perder la reserva vigente hasta que selecciones y confirmes un nuevo horario.',
              style: TextStyle(
                fontSize: 12,
                color: ColoresApp.textoSecundario,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
