import 'package:flutter/material.dart';

import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';

/// Tarjeta que muestra un turno en la lista de "Mis Turnos" del paciente.
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
                      ? Colors.red.withOpacity(0.1)
                      : !turno.sincronizado
                      ? Colors.orange.withOpacity(0.1)
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
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
    );
  }
}
