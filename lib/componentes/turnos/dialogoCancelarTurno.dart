import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Muestra el diálogo modal de confirmación para cancelar un turno.
/// Retorna `true` si el usuario confirma la cancelación, o `false` si mantiene el turno.
Future<bool?> mostrarDialogoCancelarTurno({
  required BuildContext context,
  String doctor = 'Dra. Gabriela Pellegrini',
  String especialidad = 'Cardiología',
  String fechaHora = 'Jueves 24 Oct · 10:30 hs',
  String consultorio = 'Consultorio 4',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de calendario cancelado en rojo
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  color: Color(0xFFDC2626),
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              // Título y mensaje de advertencia
              const Text(
                '¿Cancelar este turno?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'El turno con $doctor para el $fechaHora se cancelará. Esta acción no se puede deshacer y el cupo quedará liberado para otro paciente.',
                style: const TextStyle(
                  fontSize: 13,
                  color: ColoresApp.textoSecundario,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // Recuadro interior con el resumen del turno a cancelar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          size: 16,
                          color: ColoresApp.primario,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$doctor - $especialidad',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 15,
                              color: ColoresApp.primario,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              fechaHora,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primario,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          consultorio,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botón primario de cancelación (Rojo)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true), // Retorna 'true' (Confirmó cancelar)
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Sí, cancelar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Botón secundario para conservar el turno
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false), // Retorna 'false' (Mantiene turno)
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.textoTitulo,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Mantener turno',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                    ),
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