import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/turnos/dialogoCancelarTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/turnos/datos/modelos/turno.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaDetalleTurno.dart';

/// Tarjeta reutilizable para mostrar un turno del paciente (próximo o de historial).
class TarjetaTurnoPaciente extends StatelessWidget {
  final Turno turno;
  final bool esHistorial;

  const TarjetaTurnoPaciente({
    super.key,
    required this.turno,
    this.esHistorial = false,
  });

  @override
  Widget build(BuildContext context) {
    final estadoLower = turno.estado.toLowerCase().trim();
    Color estadoColor;
    Color estadoFondo;
    IconData estadoIcono;

    if (estadoLower == 'atendido') {
      estadoColor = const Color(0xFF64748B);
      estadoFondo = const Color(0xFFF1F5F9);
      estadoIcono = Icons.check;
    } else if (estadoLower == 'cancelado') {
      estadoColor = const Color(0xFFDC2626);
      estadoFondo = const Color(0xFFFEF2F2);
      estadoIcono = Icons.cancel_outlined;
    } else if (!turno.sincronizado) {
      estadoColor = const Color(0xFFD97706);
      estadoFondo = const Color(0xFFFEF3C7);
      estadoIcono = Icons.cloud_upload_outlined;
    } else {
      estadoColor = const Color(0xFF10B981);
      estadoFondo = const Color(0xFFD1FAE5);
      estadoIcono = Icons.check_circle_outline;
    }

    final String estadoTexto = !turno.sincronizado
        ? 'Pendiente de sincronización'
        : turno.estado;

    final fechaHora = '${turno.fecha} • ${turno.hora} hs';
    const ubicacion = 'Sede Central';

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
          // Cabecera: Doctor e Indicador de estado
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
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: ColoresApp.primario,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turno.medico,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      turno.especialidad,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: estadoFondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(estadoIcono, size: 12, color: estadoColor),
                    const SizedBox(width: 4),
                    Text(
                      estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Caja interna con Fecha, Hora y Ubicación
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: ColoresApp.textoSecundario,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fechaHora,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: ColoresApp.textoSecundario,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ubicacion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Botones inferiores de acción
          Row(
            mainAxisAlignment: esHistorial
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!esHistorial)
                TextButton.icon(
                  onPressed: () async {
                    await mostrarDialogoCancelarTurno(
                      context: context,
                      doctor: turno.medico,
                      especialidad: turno.especialidad,
                      fechaHora: fechaHora,
                      consultorio: ubicacion,
                    );
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaDetalleTurno(
                        soloLectura: esHistorial,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioBoton,
                  foregroundColor: ColoresApp.textoBoton,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ver detalle',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoBoton,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
