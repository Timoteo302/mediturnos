import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta que muestra los datos del médico y la sede/consultorio.
class TarjetaMedicoSede extends StatelessWidget {
  final String iniciales;
  final String nombreMedico;
  final String especialidad;
  final String matriculas;
  final String sedeNombre;
  final String direccion;
  final String consultorio;

  const TarjetaMedicoSede({
    super.key,
    this.iniciales = 'GP',
    this.nombreMedico = 'Dra. Gabriela Pellegrini',
    this.especialidad = 'Cardiología Clínica',
    this.matriculas = 'M.N. 142.890 • M.P. 44.512',
    this.sedeNombre = 'Sede Central Palermo',
    this.direccion = 'Av. Coronel Díaz 2450, Piso 3',
    this.consultorio = 'Consultorio 304 (Ala B)',
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
          // Datos del doctor
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ColoresApp.fondoIcono,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    iniciales,
                    style: const TextStyle(
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          nombreMedico,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            size: 16, color: ColoresApp.primario),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      especialidad,
                      style: const TextStyle(
                          fontSize: 13, color: ColoresApp.textoSecundario),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        matriculas,
                        style: const TextStyle(
                            fontSize: 10,
                            color: ColoresApp.textoSecundario,
                            fontWeight: FontWeight.w500),
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

          // Sede y Consultorio
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: ColoresApp.primario, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sedeNombre,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      direccion,
                      style: const TextStyle(
                          fontSize: 12, color: ColoresApp.textoSecundario),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColoresApp.fondoIcono,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.door_sliding_outlined,
                              size: 14, color: ColoresApp.primario),
                          const SizedBox(width: 6),
                          Text(
                            consultorio,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primario),
                          ),
                        ],
                      ),
                    ),
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
