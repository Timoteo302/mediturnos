import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Barra de selectores superiores para filtrar por fecha y médico en la grilla del administrador.
class BarraSelectoresAdmin extends StatelessWidget {
  final String textoFecha;
  final String textoMedico;
  final VoidCallback onTapFecha;
  final VoidCallback onTapMedico;

  const BarraSelectoresAdmin({
    super.key,
    required this.textoFecha,
    required this.textoMedico,
    required this.onTapFecha,
    required this.onTapMedico,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onTapFecha,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: ColoresApp.primario),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      textoFecha,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.primario,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      size: 18, color: ColoresApp.primario),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onTapMedico,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: ColoresApp.textoSecundario),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      textoMedico,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      size: 18, color: ColoresApp.textoSecundario),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
