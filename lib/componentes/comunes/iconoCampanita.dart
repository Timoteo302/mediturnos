import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../notificaciones/presentacion/viewmodels/notificacionesViewModel.dart';
import '../../notificaciones/presentacion/pantallas/pantallaNotificaciones.dart';

// Botón de campanita para el encabezado con contador rojo de notificaciones pendientes (máximo "9+").
class IconoCampanita extends StatelessWidget {
  const IconoCampanita({super.key});

  @override
  Widget build(BuildContext context) {
    final cantidad = context.watch<NotificacionesViewModel>().cantidadNoLeidas;
    final String textoContador = cantidad > 9 ? '9+' : '$cantidad';

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            size: 24,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PantallaNotificaciones()),
            );
          },
        ),
        if (cantidad > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  textoContador,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
