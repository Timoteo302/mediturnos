import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Encabezado con título del paso de revisión y temporizador de reserva.
class HeaderReservaTemporal extends StatelessWidget {
  final String tiempoReserva;

  const HeaderReservaTemporal({
    super.key,
    this.tiempoReserva = '09:42',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Paso final: Revisión',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoTitulo,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: ColoresApp.fondoIcono,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '• Reserva ($tiempoReserva)',
            style: const TextStyle(
              color: ColoresApp.primario,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
