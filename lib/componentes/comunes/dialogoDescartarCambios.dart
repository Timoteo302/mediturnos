import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Muestra un diálogo modal M3 de confirmación antes de descartar cambios.
/// Retorna `true` si el usuario confirma descartar, o `false` si decide seguir editando.
Future<bool?> mostrarDialogoDescartarCambios(BuildContext context) {
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
              // Ícono de advertencia ámbar
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '¿Descartar los cambios?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              const Text(
                'Acción requerida para salir',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Los datos que modificaste no se guardarán. Si salís ahora, perderás la selección de médico y horario.',
                style: TextStyle(
                  fontSize: 13,
                  color: ColoresApp.textoSecundario,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Botón primario: Seguir editando
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false), // No descarta
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.textoBoton,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Seguir editando',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Botón secundario: Descartar
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true), // Descarta
                  child: const Text(
                    'Descartar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
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