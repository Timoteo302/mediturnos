import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../servicios/estadoConexionViewModel.dart';

// Banner que alerta sobre la falta de conexión antes de solicitar o editar un turno.
class BannerSinConexionTurno extends StatelessWidget {
  const BannerSinConexionTurno({super.key});

  @override
  Widget build(BuildContext context) {
    final conectado = context.watch<EstadoConexionViewModel>().conectado;

    // Solo se muestra cuando no hay conexión.
    if (conectado == null || conectado) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF3C7),
        border: Border(bottom: BorderSide(color: Color(0xFFFCD34D))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFF92400E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Estás sin conexión',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Los horarios pueden no estar actualizados. Podés reservar igual: tu turno se guarda en el celular y se envía cuando vuelva la conexión. Si ese horario ya fue tomado, te avisamos para que elijas otro.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB45309),
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
