import 'package:flutter/material.dart';

/// Muestra un SnackBar/Banner flotante M3 de confirmación ("Cambios guardados").
void mostrarNotificacionCambiosGuardados(
    BuildContext context, {
      String titulo = 'Cambios guardados',
      String mensaje = 'La información se actualizó correctamente.',
      VoidCallback? onDeshacer,
    }) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF86EFAC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF166534),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mensaje,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
            if (onDeshacer != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onDeshacer();
                },
                child: const Text(
                  'Deshacer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF166534)),
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ],
        ),
      ),
    ),
  );
}