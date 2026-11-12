import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta con estado del turno, fecha/hora y número de reserva.
class TarjetaEstadoReserva extends StatelessWidget {
  final String estadoTexto;
  final String tiempoRestante;
  final String diaSemanaCorto;
  final String numeroDia;
  final String fechaCompleta;
  final String horaDuracion;
  final String numeroReserva;

  const TarjetaEstadoReserva({
    super.key,
    this.estadoTexto = 'Confirmado',
    this.tiempoRestante = 'Faltan 4 días',
    this.diaSemanaCorto = 'VIE',
    this.numeroDia = '24',
    this.fechaCompleta = 'Viernes, 24 de Noviembre',
    this.horaDuracion = '🕒 10:30 hs • Duración aprox. 30m',
    this.numeroReserva = '#MED-2023-9941',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila de Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      estadoTexto,
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ColoresApp.fondoIcono,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tiempoRestante,
                  style: const TextStyle(
                    color: ColoresApp.primario,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Caja fecha y hora
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColoresApp.bordeCampo),
                  ),
                  child: Column(
                    children: [
                      Text(
                        diaSemanaCorto,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primario,
                        ),
                      ),
                      Text(
                        numeroDia,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fechaCompleta,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        horaDuracion,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColoresApp.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: ColoresApp.bordeCampo, height: 1),
          const SizedBox(height: 14),

          // Número de reserva y botón Copiar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Número de reserva',
                    style: TextStyle(
                        fontSize: 11, color: ColoresApp.textoSecundario),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    numeroReserva,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColoresApp.primario,
                  side: const BorderSide(color: ColoresApp.primario),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                ),
                icon: const Icon(Icons.copy_outlined, size: 14),
                label: const Text('Copiar',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
