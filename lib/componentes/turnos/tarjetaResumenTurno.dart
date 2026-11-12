import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta principal de resumen del turno (médico, fecha/hora, sede y paciente).
class TarjetaResumenTurno extends StatelessWidget {
  final String nombreMedico;
  final String especialidad;
  final String matricula;
  final String fechaFormateada;
  final String hora;
  final String modalidad;
  final String sedeConsultorio;
  final String direccion;
  final String nombrePaciente;
  final String dniPaciente;
  final String obraSocial;
  final String credencial;

  const TarjetaResumenTurno({
    super.key,
    this.nombreMedico = 'Dr. Juan Manuel Gómez',
    this.especialidad = 'Cardiología',
    this.matricula = 'Matrícula Nacional: MN 114.820',
    this.fechaFormateada = 'Jueves 24 de Octubre de 2024',
    this.hora = '10:30 hs',
    this.modalidad = 'Presencial',
    this.sedeConsultorio = 'Sede Central - Consultorio 4',
    this.direccion = 'Av. Corrientes 3450, CABA',
    this.nombrePaciente = 'Sofía Martínez',
    this.dniPaciente = '36.120.455',
    this.obraSocial = 'OSDE 210',
    this.credencial = 'Credencial Nº 4410293',
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
          // 1. Sección Médico
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ColoresApp.fondoIcono,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: ColoresApp.primario,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColoresApp.fondoIcono,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '• $especialidad',
                        style: const TextStyle(
                          color: ColoresApp.primario,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nombreMedico,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      matricula,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: ColoresApp.bordeCampo, height: 1),
          const SizedBox(height: 16),

          // 2. Sección Fecha y Hora
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: ColoresApp.primario,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fechaFormateada,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hora,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColoresApp.bordeCampo),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_city_outlined,
                        size: 14,
                        color: ColoresApp.textoSecundario,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        modalidad,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColoresApp.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Sección Ubicación
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: ColoresApp.primario,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sedeConsultorio,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      direccion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: ColoresApp.bordeCampo, height: 1),
          const SizedBox(height: 16),

          // 4. Sección Datos del Paciente
          const Text(
            'DATOS DEL PACIENTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoSecundario,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paciente:',
                  style: TextStyle(
                      color: ColoresApp.textoSecundario, fontSize: 13)),
              Text(nombrePaciente,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DNI:',
                  style: TextStyle(
                      color: ColoresApp.textoSecundario, fontSize: 13)),
              Text(dniPaciente,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cobertura médica:',
                  style: TextStyle(
                      color: ColoresApp.textoSecundario, fontSize: 13)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(obraSocial,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                          fontSize: 13)),
                  Text(credencial,
                      style: const TextStyle(
                          color: ColoresApp.textoSecundario, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
