import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta azul con instrucciones e indicaciones para el paciente antes de asistir a la consulta.
class TarjetaIndicacionesPaciente extends StatelessWidget {
  const TarjetaIndicacionesPaciente({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoIcono,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: ColoresApp.primario, size: 20),
              SizedBox(width: 8),
              Text(
                'Indicaciones para el paciente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Llegar 10 minutos antes con DNI y credencial médica física o digital. En caso de no poder asistir, por favor cancelar con al menos 24 hs de anticipación.',
            style: TextStyle(
              fontSize: 12,
              color: ColoresApp.textoSecundario,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFBFDBFE), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.apartment_outlined,
                      size: 16, color: ColoresApp.textoSecundario),
                  SizedBox(width: 6),
                  Text(
                    'Presentarse en Recepción Piso 3',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColoresApp.textoSecundario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Text(
                'Sin copago',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primario,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
