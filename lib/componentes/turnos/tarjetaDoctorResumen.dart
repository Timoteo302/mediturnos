import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta de resumen de información del médico seleccionado para la reserva.
class TarjetaDoctorResumen extends StatelessWidget {
  final String nombre;
  final String especialidad;
  final String sedeConsultorio;
  final String matricula;
  final String tipoConsulta;

  const TarjetaDoctorResumen({
    super.key,
    this.nombre = 'Dr. Juan Manuel Gómez',
    this.especialidad = 'Cardiología',
    this.sedeConsultorio = 'Sede Central - Consultorio 4',
    this.matricula = 'MN 114.820',
    this.tipoConsulta = 'Consulta presencial (45 min) Particular y Obras Sociales',
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
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: ColoresApp.primario,
                      size: 26,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: ColoresApp.primario,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            especialidad,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.primario,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: ColoresApp.textoSecundario),
                        const SizedBox(width: 4),
                        Text(
                          sedeConsultorio,
                          style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 13, color: ColoresApp.textoSecundario),
                        const SizedBox(width: 4),
                        Text(
                          'Matrícula Nacional: $matricula',
                          style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.medical_services_outlined, size: 15, color: ColoresApp.primario),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tipoConsulta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}