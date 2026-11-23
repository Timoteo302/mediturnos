import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';
import '../../turnos/logica/formatoFechaEspanol.dart';

/// Tarjeta con estado del turno, fecha/hora y número de reserva.
class TarjetaEstadoReserva extends StatelessWidget {
  final TurnoDetalle turno;

  const TarjetaEstadoReserva({
    super.key,
    required this.turno,
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: turno.noRegistrado
                      ? Colors.red.withValues(alpha: 0.1)
                      : turno.estado.fondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      turno.noRegistrado
                          ? Icons.error_outline
                          : turno.estado.icono,
                      size: 14,
                      color: turno.noRegistrado ? Colors.red : turno.estado.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      turno.noRegistrado ? 'No registrado' : turno.estado.etiqueta,
                      style: TextStyle(
                        color: turno.noRegistrado ? Colors.red : turno.estado.color,
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
                  FormatoFechaEspanol.textoTiempoRestante(turno.fecha, turno.hora),
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColoresApp.bordeCampo.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColoresApp.bordeCampo),
                  ),
                  child: Column(
                    children: [
                      Text(
                        FormatoFechaEspanol.diaSemanaCorto(turno.fecha),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primario,
                        ),
                      ),
                      Text(
                        '${turno.fecha.day}',
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
                        FormatoFechaEspanol.fechaLarga(turno.fecha),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '🕒 ${turno.hora} hs',
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
          if (turno.errorSincronizacion != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explicación del error:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    turno.errorSincronizacion!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: ColoresApp.bordeCampo, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Número de reserva',
                    style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    turno.noRegistrado
                        ? 'Sin número (no se registró)'
                        : '#${turno.id}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: turno.noRegistrado ? Colors.red : ColoresApp.textoTitulo,
                    ),
                  ),
                ],
              ),
              if (!turno.noRegistrado)
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.primario,
                    side: const BorderSide(color: ColoresApp.primario),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  icon: const Icon(Icons.copy_outlined, size: 14),
                  label: const Text('Copiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
