import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';
import '../../turnos/datos/modelos/estadoTurno.dart';
import '../../turnos/presentacion/estadoTurnoUi.dart';

/// Tarjeta de turno reutilizable para la grilla de administración.
class TarjetaTurnoAdmin extends StatelessWidget {
  final TurnoDetalle turno;
  final VoidCallback? alConfirmar;
  final VoidCallback? alMarcarAtendido;
  final VoidCallback alVerDetalle;
  final VoidCallback alLlamar;
  final bool procesando;

  const TarjetaTurnoAdmin({
    super.key,
    required this.turno,
    this.alConfirmar,
    this.alMarcarAtendido,
    required this.alVerDetalle,
    required this.alLlamar,
    this.procesando = false,
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
              color: ColoresApp.fondoIcono.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.4)),
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
          const SizedBox(height: 14),
          Row(
            children: [
              if (turno.estado == EstadoTurno.pendiente) ...[
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
              ],
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
              if (turno.estado == EstadoTurno.pendiente || turno.estado == EstadoTurno.confirmado) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: procesando
                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : ElevatedButton.icon(
                          onPressed: turno.estado == EstadoTurno.pendiente ? alConfirmar : alMarcarAtendido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.primarioBoton,
                            foregroundColor: ColoresApp.textoBoton,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: Text(
                            turno.estado == EstadoTurno.pendiente ? 'Confirmar' : 'Asistió',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
