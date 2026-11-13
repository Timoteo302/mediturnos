import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';

/// Tarjeta que muestra el turno actualmente asignado antes de modificarlo.
class TarjetaTurnoActualAsignado extends StatelessWidget {
  final TurnoDetalle turno;

  const TarjetaTurnoActualAsignado({
    super.key,
    required this.turno,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_today_outlined, color: ColoresApp.primario, size: 20),
                SizedBox(width: 8),
                Text(
                  'Turno actual asignado',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: turno.estado.fondo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(turno.estado.icono, size: 12, color: turno.estado.color),
                  const SizedBox(width: 4),
                  Text(
                    turno.estado.etiqueta,
                    style: TextStyle(
                      color: turno.estado.color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColoresApp.bordeCampo),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medical_services_outlined, color: ColoresApp.primario, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turno.medico.nombreCompleto,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          turno.medico.especialidad.nombre,
                          style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                        ),
                        if (turno.medico.matricula != null && turno.medico.matricula!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Matrícula: ${turno.medico.matricula}',
                            style: const TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColoresApp.fondoIcono.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: ColoresApp.primario),
                    const SizedBox(width: 8),
                    Text(
                      '${turno.fecha.day}/${turno.fecha.month}/${turno.fecha.year}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                    ),
                    const Text('  |  ', style: TextStyle(color: ColoresApp.textoSecundario)),
                    Text(
                      '${turno.hora} hs',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
