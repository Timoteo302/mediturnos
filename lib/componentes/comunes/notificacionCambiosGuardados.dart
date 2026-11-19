import 'package:flutter/material.dart';
import 'notificacionApp.dart';

// Muestra una notificación de confirmación específica ("Cambios guardados").
// Utiliza internamente la notificación genérica de éxito para mantener compatibilidad con las pantallas que la usan.
void mostrarNotificacionCambiosGuardados(
  BuildContext context, {
  String titulo = 'Cambios guardados',
  String mensaje = 'La información se actualizó correctamente.',
  VoidCallback? onDeshacer,
}) {
  mostrarNotificacionApp(
    context,
    tipo: TipoNotificacionApp.exito,
    titulo: titulo,
    mensaje: mensaje,
    onDeshacer: onDeshacer,
  );
}
