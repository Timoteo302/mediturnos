import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';
import '../../turnos/presentacion/pantallas/pantallaSeleccionarTurno.dart';
import '../../medicos/datos/modelos/medico.dart';
import '../../medicos/datos/modelos/especialidad.dart';
import 'dialogoAsistenciaTurno.dart';

// Tarjeta que muestra un turno en la lista de "Mis Turnos" del paciente.
// Si el turno es noRegistrado (error de sincronización en creación con ID negativo), muestra etiqueta "No registrado" y opciones para elegir otro horario o quitar.
class TarjetaTurnoPaciente extends StatelessWidget {
  final TurnoDetalle turno;
  final bool esHistorial;
  final VoidCallback alVerDetalle;
  final VoidCallback? alCancelar;
  final VoidCallback? alEliminar;

  const TarjetaTurnoPaciente({
    super.key,
    required this.turno,
    this.esHistorial = false,
    required this.alVerDetalle,
    this.alCancelar,
    this.alEliminar,
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
                  color: turno.noRegistrado
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
                      turno.noRegistrado
                          ? Icons.error_outline
                          : !turno.sincronizado
                          ? Icons.sync
                          : turno.estado.icono,
                      size: 14,
                      color: turno.noRegistrado
                          ? Colors.red
                          : !turno.sincronizado
                          ? Colors.orange
                          : turno.estado.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      turno.noRegistrado
                          ? 'No registrado'
                          : !turno.sincronizado
                          ? 'Pendiente de sincronización'
                          : turno.estado.etiqueta,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: turno.noRegistrado
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
          if (turno.noRegistrado)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final medicoObj = Medico(
                      id: turno.medico.id,
                      nombre: turno.medico.nombre,
                      apellido: turno.medico.apellido,
                      especialidad: Especialidad(
                        id: turno.medico.especialidad.id,
                        nombre: turno.medico.especialidad.nombre,
                        activo: true,
                      ),
                      activo: true,
                    );
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaSeleccionarTurno(medico: medicoObj),
                      ),
                    );
                    if (res == true && context.mounted) {
                      await context.read<RepositorioGestionTurnos>().eliminarTurnoLocal(turno.id);
                      alEliminar?.call();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.primario,
                    side: const BorderSide(color: ColoresApp.primario),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined, size: 15),
                  label: const Text('Elegir otro horario', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Quitar turno no registrado?'),
                        content: const Text('¿Estás seguro de que deseas eliminar esta solicitud de turno de tu dispositivo?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Quitar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmar == true && context.mounted) {
                      await context.read<RepositorioGestionTurnos>().eliminarTurnoLocal(turno.id);
                      alEliminar?.call();
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Quitar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          else
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
