import 'package:flutter/material.dart';

import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';
import 'dialogoAsistenciaTurno.dart';

// Tarjeta que muestra un turno en la lista de "Mis Turnos" del paciente.
// Permite confirmar asistencia si el turno es dentro de las 24 hs y no fue respondido.
class TarjetaTurnoPaciente extends StatelessWidget {
  final TurnoDetalle turno;
  final bool esHistorial;
  final VoidCallback alVerDetalle;
  final VoidCallback? alCancelar;

  const TarjetaTurnoPaciente({
    super.key,
    required this.turno,
    this.esHistorial = false,
    required this.alVerDetalle,
    this.alCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final desde24h = turno.fechaHora.subtract(const Duration(hours: 24));
    final dentroDe24h = DateTime.now().isAfter(desde24h) && DateTime.now().isBefore(turno.fechaHora);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  turno.medico.especialidad.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: turno.errorSincronizacion != null
                      ? Colors.red.withValues(alpha: 0.1)
                      : !turno.sincronizado
                      ? Colors.orange.withValues(alpha: 0.1)
                      : turno.estado.fondo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      turno.errorSincronizacion != null
                          ? Icons.error_outline
                          : !turno.sincronizado
                          ? Icons.sync
                          : turno.estado.icono,
                      size: 14,
                      color: turno.errorSincronizacion != null
                          ? Colors.red
                          : !turno.sincronizado
                          ? Colors.orange
                          : turno.estado.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      turno.errorSincronizacion != null
                          ? 'Error de sincronización'
                          : !turno.sincronizado
                          ? 'Pendiente de sincronización'
                          : turno.estado.etiqueta,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: turno.errorSincronizacion != null
                            ? Colors.red
                            : !turno.sincronizado
                            ? Colors.orange[800]
                            : turno.estado.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            turno.medico.nombreCompleto,
            style: const TextStyle(
              fontSize: 13,
              color: ColoresApp.textoSecundario,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: ColoresApp.primario,
              ),
              const SizedBox(width: 6),
              Text(
                '${turno.fecha.day}/${turno.fecha.month}/${turno.fecha.year} - ${turno.hora} hs',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
              ),
            ],
          ),
          if (turno.errorSincronizacion != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No se pudo registrar este turno:',
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
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!esHistorial && dentroDe24h && turno.respuestaPaciente == 'SIN_RESPUESTA')
                ElevatedButton.icon(
                  onPressed: () {
                    final fechaTexto = '${turno.fecha.day}/${turno.fecha.month}/${turno.fecha.year}';
                    showDialog(
                      context: context,
                      builder: (context) => DialogoAsistenciaTurno(
                        turnoId: turno.id,
                        medicoNombre: turno.medico.nombreCompleto,
                        fechaTexto: fechaTexto,
                        hora: turno.hora,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 15),
                  label: const Text('Confirmar asistencia', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  TextButton(
                    onPressed: alVerDetalle,
                    child: const Text('Ver detalle'),
                  ),
                  if (!esHistorial && alCancelar != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: alCancelar,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
