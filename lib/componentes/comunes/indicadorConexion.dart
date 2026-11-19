import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../servicios/estadoConexionViewModel.dart';
import 'notificacionApp.dart';

// Muestra el estado de la conexión con el servidor mediante un ícono circular en la barra superior.
class IndicadorConexion extends StatelessWidget {
  const IndicadorConexion({super.key});

  @override
  Widget build(BuildContext context) {
    final conectado = context.watch<EstadoConexionViewModel>().conectado;

    Color bgColor;
    Color iconColor;
    IconData icon;
    String textoEstado;

    if (conectado == true) {
      bgColor = const Color(0xFFDCFCE7);
      iconColor = const Color(0xFF166534); // Verde oscuro para visibilidad
      icon = Icons.wifi;
      textoEstado = 'Conectado al servidor';
    } else if (conectado == false) {
      bgColor = const Color(0xFFFEE2E2);
      iconColor = const Color(0xFF991B1B); // Rojo oscuro
      icon = Icons.wifi_off;
      textoEstado = 'No se puede conectar con el servidor. Tus cambios se guardan en el celular y se envían cuando vuelva la conexión.';
    } else {
      bgColor = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF64748B); // Gris
      icon = Icons.wifi_find;
      textoEstado = 'Comprobando la conexión con el servidor...';
    }

    return Semantics(
      label: textoEstado,
      child: Tooltip(
        message: textoEstado,
        child: GestureDetector(
          onTap: () {
            mostrarNotificacionApp(
              context,
              tipo: conectado == false ? TipoNotificacionApp.advertencia : TipoNotificacionApp.informacion,
              titulo: conectado == true ? 'Conectado al servidor' : (conectado == false ? 'Sin conexión al servidor' : 'Comprobando conexión'),
              mensaje: textoEstado,
            );
          },
          child: Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
