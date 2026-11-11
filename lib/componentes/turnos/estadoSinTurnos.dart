import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Componente para mostrar el estado vacío cuando el paciente no tiene turnos programados.
class EstadoSinTurnos extends StatelessWidget {
  final VoidCallback onSolicitarTurno;

  const EstadoSinTurnos({
    super.key,
    required this.onSolicitarTurno,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono de calendario en círculo azul claro
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: ColoresApp.primario,
              size: 32,
            ),
          ),

          const SizedBox(height: 18),

          // Título del estado vacío
          const Text(
            'Todavía no tenés turnos\nprogramados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoTitulo,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Texto descriptivo
          const Text(
            'Cuando reserves una consulta médica con un especialista, vas a poder ver la fecha, horario e indicaciones acá.',
            style: TextStyle(
              fontSize: 13,
              color: ColoresApp.textoSecundario,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 22),

          // Botón principal: + Solicitar un turno
          BotonPrincipal(
            texto: '+ Solicitar un turno',
            onPressed: onSolicitarTurno,
          ),
        ],
      ),
    );
  }
}