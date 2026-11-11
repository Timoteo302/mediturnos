import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaDetalleTurno.dart';

/// Tarjeta destacada del próximo turno programado.
class TarjetaProximoTurno extends StatelessWidget {
  final String especialidad;
  final String medico;
  final String fechaHora;
  final String lugar;
  final String tiempoRestante;
  final VoidCallback? onVerDetalle;

  const TarjetaProximoTurno({
    super.key,
    this.especialidad = 'Cardiología',
    this.medico = 'Dr. Juan Manuel Gómez',
    this.fechaHora = 'Jueves 24 de Octubre - 10:30 hs',
    this.lugar = 'Consultorio 4 - Sede Central',
    this.tiempoRestante = 'En 24 hs',
    this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Próximo turno',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
            Text(
              tiempoRestante,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColoresApp.primario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monitor_heart_outlined,
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
                          especialidad,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          medico,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Color(0xFF166534),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Confirmado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: ColoresApp.primario,
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
                          size: 16,
                          color: ColoresApp.textoSecundario,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lugar,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: onVerDetalle ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PantallaDetalleTurno(),
                          ),
                        );
                      },
                  icon: const Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: ColoresApp.primario,
                  ),
                  label: const Text(
                    'Ver detalle del turno',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primario,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}