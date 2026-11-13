import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';

/// Tarjeta que resume los datos esenciales del turno al confirmar o detallar.
class TarjetaResumenTurno extends StatelessWidget {
  final MedicoDetalle medico;
  final DateTime fecha;
  final String hora;

  const TarjetaResumenTurno({
    super.key,
    required this.medico,
    required this.fecha,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE8F3FF),
                child: Text(
                  medico.iniciales,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primario,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medico.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medico.especialidad.nombre,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ColoresApp.primario,
                      ),
                    ),
                    if (medico.matricula != null && medico.matricula!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Matrícula: ${medico.matricula}',
                        style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: ColoresApp.primario),
              const SizedBox(width: 8),
              Text(
                'Fecha: ${fecha.day}/${fecha.month}/${fecha.year}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 16, color: ColoresApp.primario),
              const SizedBox(width: 8),
              Text(
                'Hora: $hora hs',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
