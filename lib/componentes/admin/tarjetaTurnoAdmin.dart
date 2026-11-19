import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';

// Tarjeta de turno reutilizable para la grilla de administración.
// Muestra reglas de confirmación anticipada y estado de respuesta del paciente.
class TarjetaTurnoAdmin extends StatelessWidget {
  final TurnoDetalle turno;
  final VoidCallback? alConfirmar;
  final VoidCallback? alMarcarAtendido;
  final VoidCallback? alRechazar;
  final VoidCallback alVerDetalle;
  final VoidCallback alLlamar;
  final bool procesando;

  const TarjetaTurnoAdmin({
    super.key,
    required this.turno,
    this.alConfirmar,
    this.alMarcarAtendido,
    this.alRechazar,
    required this.alVerDetalle,
    required this.alLlamar,
    this.procesando = false,
  });

  // Muestra un chip verde si el paciente confirmó asistencia, o gris si está dentro de las 24 hs sin respuesta.
  Widget? _construirChipRespuestaPaciente(DateTime desde24h) {
    final dentroDe24h = DateTime.now().isAfter(desde24h);

    if (turno.respuestaPaciente == 'ASISTIRA') {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF166534)),
            SizedBox(width: 4),
            Text(
              'Paciente confirmó asistencia',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF166534),
              ),
            ),
          ],
        ),
      );
    } else if (turno.respuestaPaciente == 'SIN_RESPUESTA' && dentroDe24h) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.help_outline, size: 14, color: Color(0xFF475569)),
            SizedBox(width: 4),
            Text(
              'Sin respuesta del paciente',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final desde24h = turno.fechaHora.subtract(const Duration(hours: 24));
    final diaStr = desde24h.day.toString().padLeft(2, '0');
    final mesStr = desde24h.month.toString().padLeft(2, '0');
    final horaStr = desde24h.hour.toString().padLeft(2, '0');
    final minStr = desde24h.minute.toString().padLeft(2, '0');
    final chipRespuesta = _construirChipRespuestaPaciente(desde24h);

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
                    const SizedBox(height: 2),
                    Text(
                      'DNI: ${turno.paciente.dni}',
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeCampo.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      turno.medico.iniciales,
                      style: const TextStyle(
                        color: ColoresApp.primario,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                OutlinedButton.icon(
                  onPressed: alLlamar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.primario,
                    side: const BorderSide(color: ColoresApp.primario),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Llamar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: alVerDetalle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColoresApp.textoTitulo,
                      side: const BorderSide(color: ColoresApp.bordeCampo),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Ver detalle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: alRechazar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rechazar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: turno.puedeConfirmarse ? alConfirmar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: turno.puedeConfirmarse ? ColoresApp.primarioBoton : Colors.grey[300],
                      foregroundColor: turno.puedeConfirmarse ? ColoresApp.textoBoton : Colors.grey[600],
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Confirmar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            if (!turno.puedeConfirmarse) ...[
              const SizedBox(height: 6),
              Text(
                'Se puede confirmar desde el $diaStr/$mesStr a las $horaStr:$minStr',
                style: const TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
              ),
            ],
          ] else if (turno.estado == EstadoTurno.confirmado) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: alVerDetalle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColoresApp.textoTitulo,
                      side: const BorderSide(color: ColoresApp.bordeCampo),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Ver detalle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: alRechazar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancelar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: alMarcarAtendido,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primarioBoton,
                      foregroundColor: ColoresApp.textoBoton,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Asistió', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: alVerDetalle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColoresApp.textoTitulo,
                      side: const BorderSide(color: ColoresApp.bordeCampo),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Ver detalle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
