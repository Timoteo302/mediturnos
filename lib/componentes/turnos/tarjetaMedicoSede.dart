import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';

/// Tarjeta que muestra los datos del médico del turno.
class TarjetaMedicoSede extends StatelessWidget {
  final MedicoDetalle medico;

  const TarjetaMedicoSede({
    super.key,
    required this.medico,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresApp.bordeCampo),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                medico.iniciales,
                style: const TextStyle(
                  color: ColoresApp.primario,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      medico.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: ColoresApp.primario),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  medico.especialidad.nombre,
                  style: const TextStyle(fontSize: 13, color: ColoresApp.textoSecundario),
                ),
                if (medico.matricula != null && medico.matricula!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Matrícula: ${medico.matricula}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: ColoresApp.textoSecundario,
                        fontWeight: FontWeight.w500,
                      ),
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
