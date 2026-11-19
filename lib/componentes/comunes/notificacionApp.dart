import 'package:flutter/material.dart';
import '../../configuracion/clavesGlobales.dart';

// Tipos de notificaciones que determinan sus colores e íconos.
enum TipoNotificacionApp {
  exito,
  error,
  advertencia,
  informacion,
}

// Función privada que construye el SnackBar con estilo consistente para toda la app.
SnackBar _construirSnackBar({
  required TipoNotificacionApp tipo,
  required String titulo,
  required String mensaje,
  Duration duracion = const Duration(seconds: 4),
  VoidCallback? onDeshacer,
}) {
  Color bgColor;
  Color borderColor;
  Color mainColor; // Para ícono y título
  Color textColor; // Para mensaje
  IconData iconData;

  switch (tipo) {
    case TipoNotificacionApp.exito:
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF86EFAC);
      mainColor = const Color(0xFF166534);
      textColor = const Color(0xFF15803D);
      iconData = Icons.check_circle;
      break;
    case TipoNotificacionApp.error:
      bgColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFFCA5A5);
      mainColor = const Color(0xFF991B1B);
      textColor = const Color(0xFFB91C1C);
      iconData = Icons.error;
      break;
    case TipoNotificacionApp.advertencia:
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFFCD34D);
      mainColor = const Color(0xFF92400E);
      textColor = const Color(0xFFB45309);
      iconData = Icons.warning_amber_rounded;
      break;
    case TipoNotificacionApp.informacion:
      bgColor = const Color(0xFFDBEAFE);
      borderColor = const Color(0xFF93C5FD);
      mainColor = const Color(0xFF1E40AF);
      textColor = const Color(0xFF1D4ED8);
      iconData = Icons.info;
      break;
  }

  return SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    duration: duracion,
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
          Icon(
            iconData,
            color: mainColor,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mensaje,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          if (onDeshacer != null)
            TextButton(
              onPressed: () {
                scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                onDeshacer();
              },
              child: Text(
                'Deshacer',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: mainColor),
            onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
          ),
        ],
      ),
    ),
  );
}

// Muestra una notificación flotante (SnackBar) usando el BuildContext proporcionado.
void mostrarNotificacionApp(
  BuildContext context, {
  required TipoNotificacionApp tipo,
  required String titulo,
  required String mensaje,
  Duration duracion = const Duration(seconds: 4),
  VoidCallback? onDeshacer,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    _construirSnackBar(
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      duracion: duracion,
      onDeshacer: onDeshacer,
    ),
  );
}

// Muestra una notificación flotante global usando la clave global sin requerir BuildContext.
void mostrarNotificacionAppGlobal({
  required TipoNotificacionApp tipo,
  required String titulo,
  required String mensaje,
  Duration duracion = const Duration(seconds: 4),
  VoidCallback? onDeshacer,
}) {
  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  scaffoldMessengerKey.currentState?.showSnackBar(
    _construirSnackBar(
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      duracion: duracion,
      onDeshacer: onDeshacer,
    ),
  );
}
