import 'package:flutter/material.dart';

import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';

// Tarjeta que representa un turno en la vista del administrador con sus acciones asociadas.
class TarjetaTurnoAdmin extends StatelessWidget {
  final TurnoDetalle turno;
  final VoidCallback alConfirmar;
  final VoidCallback? alAtender;
  final VoidCallback? alMarcarAtendido;
  final VoidCallback? alCancelar;
  final VoidCallback? alRechazar;
  final VoidCallback? alReagendar;
  final VoidCallback? alLlamar;
  final VoidCallback? alVerDetalle;
  final bool procesando;

  const TarjetaTurnoAdmin({
    super.key,
    required this.turno,
    required this.alConfirmar,
    this.alAtender,
    this.alMarcarAtendido,
    this.alCancelar,
    this.alRechazar,
    this.alReagendar,
    this.alLlamar,
    this.alVerDetalle,
    this.procesando = false,
  });

  Widget? _construirChipRespuestaPaciente(DateTime desde24h) {
    if (turno.respuestaPaciente == 'ASISTIRA') {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 13, color: Color(0xFF166534)),
            SizedBox(width: 4),
            Text(
              'Paciente asistirá',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF166534),
              ),
            ),
          ],
        ),
      );
    } else if (turno.respuestaPaciente == 'NO_ASISTIRA') {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 13, color: Color(0xFF991B1B)),
            SizedBox(width: 4),
            Text(
              'Paciente no asistirá',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF991B1B),
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  Widget? _construirChipCuentaPendiente() {
    if (!turno.pacienteCuentaPendiente) return null;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 13, color: Color(0xFF64748B)),
          SizedBox(width: 4),
          Text(
            'Cuenta sin activar',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desde24h = turno.fechaHora.subtract(const Duration(hours: 24));
    final diaStr = desde24h.day.toString().padLeft(2, '0');
    final mesStr = desde24h.month.toString().padLeft(2, '0');
    final horaStr = desde24h.hour.toString().padLeft(2, '0');
    final minStr = desde24h.minute.toString().padLeft(2, '0');
    final chipRespuesta = _construirChipRespuestaPaciente(desde24h);
    final chipCuenta = _construirChipCuentaPendiente();

    final actionAtender = alAtender ?? alMarcarAtendido;
    final actionCancelar = alCancelar ?? alRechazar;

    return GestureDetector(
      onTap: alVerDetalle,
      child: Container(
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
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: ColoresApp.primario),
                    const SizedBox(width: 6),
                    Text(
                      '${turno.hora} hs',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: turno.estado.fondo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(turno.estado.icono, size: 12, color: turno.estado.color),
                      const SizedBox(width: 3),
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
            const Divider(color: ColoresApp.bordeCampo, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: ColoresApp.textoSecundario),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turno.paciente.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                      if (turno.paciente.dni.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'DNI: ${turno.paciente.dni}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        turno.medico.iniciales,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primario,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turno.medico.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          turno.medico.especialidad.nombre,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (chipCuenta != null) chipCuenta,
            if (chipRespuesta != null) chipRespuesta,
            const SizedBox(height: 14),
            if (procesando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (turno.estado == EstadoTurno.pendiente) ...[
              Row(
                children: [
                  if (alLlamar != null) ...[
                    OutlinedButton.icon(
                      onPressed: alLlamar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColoresApp.primario,
                        side: const BorderSide(color: ColoresApp.primario),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.phone_outlined, size: 16),
                      label: const Text('Llamar', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: turno.puedeConfirmarse ? alConfirmar : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primario,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Confirmar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (actionCancelar != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: actionCancelar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rechazar', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
              if (!turno.puedeConfirmarse) ...[
                const SizedBox(height: 6),
                Text(
                  'Se puede confirmar desde el $diaStr/$mesStr a las $horaStr:$minStr',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: ColoresApp.textoSecundario,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ] else if (turno.estado == EstadoTurno.confirmado) ...[
              Row(
                children: [
                  if (actionAtender != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: actionAtender,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.medical_services_outlined, size: 16),
                        label: const Text('Atendido', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (alReagendar != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: alReagendar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColoresApp.primario,
                        side: const BorderSide(color: ColoresApp.primario),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                      label: const Text('Reagendar', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  if (actionCancelar != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: actionCancelar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
