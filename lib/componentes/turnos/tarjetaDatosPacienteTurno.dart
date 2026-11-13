import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../turnos/datos/modelos/turnoDetalle.dart';

/// Tarjeta que muestra los datos del paciente asociado al turno.
class TarjetaDatosPacienteTurno extends StatelessWidget {
  final PacienteDetalle paciente;

  const TarjetaDatosPacienteTurno({
    super.key,
    required this.paciente,
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
                  color: ColoresApp.textoTitulo,
                ),
              ),
              Text(
                'Titular',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoIcono.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Paciente', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
                      const SizedBox(height: 2),
                      Text(paciente.nombreCompleto,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
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
                    border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DNI', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
                      const SizedBox(height: 2),
                      Text(paciente.dni,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
                    ],
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
