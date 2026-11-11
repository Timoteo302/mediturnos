import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Diálogo modal M3 que salta cuando el horario seleccionado fue ocupado por otra persona.
Future<void> mostrarDialogoHorarioOcupado(
    BuildContext context, {
      required VoidCallback onVerOtrosHorarios,
    }) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de reloj ocupado
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: Color(0xFFD97706),
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'El horario ya no está disponible',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              const Text(
                'Otra persona acaba de reservar las 10:30 hs. No te preocupes, elegí otro horario para continuar con tu médico.',
                style: TextStyle(
                  fontSize: 13,
                  color: ColoresApp.textoSecundario,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Caja de sugerencias de turnos cercanos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Turnos cercanos disponibles hoy: Martes 14 May',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.primario,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _construirChipHorario('11:00 hs', false),
                        _construirChipHorario('11:30 hs', true),
                        _construirChipHorario('12:15 hs', false),
                        _construirChipHorario('16:00 hs', false),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botón primario: Ver horarios disponibles
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onVerOtrosHorarios();
                  },
                  icon: const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF0F2942)),
                  label: const Text(
                    'Ver horarios disponibles',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2942),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60B2FA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar y volver a la búsqueda',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _construirChipHorario(String hora, bool seleccionado) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: seleccionado ? const Color(0xFFE8F3FF) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: seleccionado ? ColoresApp.primario : const Color(0xFFCBD5E1),
      ),
    ),
    child: Text(
      hora,
      style: TextStyle(
        fontSize: 11,
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        color: seleccionado ? ColoresApp.primario : ColoresApp.textoTitulo,
      ),
    ),
  );
}