import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../configuracion/estilosTexto.dart';

class BarraAccionesGestionMedicos extends StatelessWidget {
  final VoidCallback alAgregarMedico;
  final VoidCallback alAbrirEspecialidades;

  const BarraAccionesGestionMedicos({
    super.key,
    required this.alAgregarMedico,
    required this.alAbrirEspecialidades,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: alAgregarMedico,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.primarioBoton,
              foregroundColor: ColoresApp.textoBoton,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.person_add_outlined, size: 20),
            label: const Text('Agregar médico', style: EstilosTexto.textoBotonPrincipal),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: alAbrirEspecialidades,
          style: OutlinedButton.styleFrom(
            foregroundColor: ColoresApp.primario,
            side: const BorderSide(color: ColoresApp.primario),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.category_outlined, size: 20),
          label: const Text('Especialidades', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
