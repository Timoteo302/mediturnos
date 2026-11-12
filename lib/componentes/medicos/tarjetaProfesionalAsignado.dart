import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';

class TarjetaProfesionalAsignado extends StatelessWidget {
  final String iniciales;
  final String nombreCompleto;
  final String especialidad;
  final VoidCallback? alTocar;

  const TarjetaProfesionalAsignado({
    super.key,
    required this.iniciales,
    required this.nombreCompleto,
    required this.especialidad,
    this.alTocar,
  });

  const TarjetaProfesionalAsignado.sinSeleccion({
    super.key,
    required VoidCallback this.alTocar,
  })  : iniciales = '?',
        nombreCompleto = 'Seleccioná un médico',
        especialidad = 'Toca aquí para elegir';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alTocar,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.bordeCampo),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: ColoresApp.fondoIcono,
              child: Text(
                iniciales,
                style: const TextStyle(
                  color: ColoresApp.primario,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreCompleto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    especialidad,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (alTocar != null)
              const Icon(Icons.chevron_right, color: ColoresApp.textoSecundario),
          ],
        ),
      ),
    );
  }
}
