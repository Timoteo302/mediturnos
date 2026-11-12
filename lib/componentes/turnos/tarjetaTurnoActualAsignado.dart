import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta que muestra el turno actualmente asignado al paciente antes de modificarlo.
class TarjetaTurnoActualAsignado extends StatelessWidget {
  final String nombreMedico;
  final String especialidad;
  final String matricula;
  final String fecha;
  final String hora;
  final String consultorioSede;

  const TarjetaTurnoActualAsignado({
    super.key,
    this.nombreMedico = 'Dr. Juan Manuel Gómez',
    this.especialidad = 'Cardiología Clínica',
    this.matricula = 'Matrícula Nac. 104.920',
    this.fecha = 'Jueves 24 de Octubre',
    this.hora = '10:30 hs',
    this.consultorioSede =
        'Consultorio 4, Sede Central (Av. Pueyrredón 1443, CABA)',
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
                Icon(Icons.calendar_today_outlined,
                    color: ColoresApp.primario, size: 20),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_outline,
                      size: 12, color: Color(0xFF10B981)),
                  SizedBox(width: 4),
                  Text(
                    'Confirmado',
                    style: TextStyle(
                      color: Color(0xFF10B981),
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
                    child: const Icon(Icons.medical_services_outlined,
                        color: ColoresApp.primario, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreMedico,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          especialidad,
                          style: const TextStyle(
                              fontSize: 12, color: ColoresApp.textoSecundario),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          matricula,
                          style: const TextStyle(
                              fontSize: 11, color: ColoresApp.textoSecundario),
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
                  color: ColoresApp.fondoIcono.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: ColoresApp.primario),
                        const SizedBox(width: 8),
                        Text(
                          fecha,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo),
                        ),
                        const Text('  |  ',
                            style:
                                TextStyle(color: ColoresApp.textoSecundario)),
                        Text(
                          hora,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.primario),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: ColoresApp.textoSecundario),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            consultorioSede,
                            style: const TextStyle(
                                fontSize: 12,
                                color: ColoresApp.textoSecundario),
                          ),
                        ),
                      ],
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
