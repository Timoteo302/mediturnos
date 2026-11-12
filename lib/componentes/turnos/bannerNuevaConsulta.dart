import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Banner promocional para invitar al paciente a reservar un nuevo turno.
class BannerNuevaConsulta extends StatelessWidget {
  final VoidCallback onReservar;

  const BannerNuevaConsulta({
    super.key,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoIcono,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: ColoresApp.primario,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '¿Buscás una nueva consulta?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sacá turno con tu especialista en minutos',
                  style: TextStyle(
                    fontSize: 11,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onReservar,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.primario,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Reservar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
