import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';

/// Tarjeta que resume los datos del médico seleccionado para la reserva del turno.
class TarjetaDoctorResumen extends StatelessWidget {
  final String nombre;
  final String especialidad;
  final String? matricula;

  const TarjetaDoctorResumen({
    super.key,
    required this.nombre,
    required this.especialidad,
    this.matricula,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE8F3FF),
            child: Text(
              nombre.isNotEmpty ? nombre.substring(0, 2).toUpperCase() : 'DR',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColoresApp.primario,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  especialidad,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColoresApp.primario,
                  ),
                ),
                if (matricula != null && matricula!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Matrícula: $matricula',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColoresApp.textoSecundario,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
