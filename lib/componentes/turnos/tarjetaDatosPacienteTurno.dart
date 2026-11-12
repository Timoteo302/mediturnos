import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta que muestra la ficha de datos del paciente y cobertura médica.
class TarjetaDatosPacienteTurno extends StatelessWidget {
  final String nombrePaciente;
  final String dniPaciente;
  final String obraSocialPlan;
  final String numeroAfiliado;

  const TarjetaDatosPacienteTurno({
    super.key,
    this.nombrePaciente = 'Matías E. Romero',
    this.dniPaciente = '36.782.904',
    this.obraSocialPlan = 'OSDE 310 • Plan Médico Personal',
    this.numeroAfiliado = 'Afiliado Nº: 48-992384-01',
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
            children: const [
              Text(
                'Datos del paciente',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo),
              ),
              Text(
                'Titular',
                style: TextStyle(
                    fontSize: 12,
                    color: ColoresApp.textoSecundario,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Paciente y DNI
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoIcono.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: ColoresApp.bordeCampo.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Paciente',
                          style: TextStyle(
                              fontSize: 11,
                              color: ColoresApp.textoSecundario)),
                      const SizedBox(height: 2),
                      Text(nombrePaciente,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoIcono.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: ColoresApp.bordeCampo.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DNI',
                          style: TextStyle(
                              fontSize: 11,
                              color: ColoresApp.textoSecundario)),
                      const SizedBox(height: 2),
                      Text(dniPaciente,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Cobertura médica
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: ColoresApp.bordeCampo.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cobertura médica',
                        style: TextStyle(
                            fontSize: 11, color: ColoresApp.textoSecundario)),
                    const SizedBox(height: 2),
                    Text(obraSocialPlan,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo)),
                    const SizedBox(height: 2),
                    Text(numeroAfiliado,
                        style: const TextStyle(
                            fontSize: 11, color: ColoresApp.textoSecundario)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '✓ Activa',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
