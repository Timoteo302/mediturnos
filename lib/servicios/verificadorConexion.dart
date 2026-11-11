import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaSinConexion.dart';

/// Clave de navegación global para abrir pantallas desde cualquier lugar de la app.
final GlobalKey<NavigatorState> claveNavegacionGlobal = GlobalKey<NavigatorState>();

/// Servicio de monitoreo continuo de red a nivel global.
class VerificadorConexion {
  VerificadorConexion._();

  static Timer? _timerMonitoreo;
  static bool _pantallaSinConexionAbierta = false;

  /// Inicia la vigilancia continua de red en segundo plano para toda la app.
  static void iniciarMonitoreoGlobal() {
    _timerMonitoreo?.cancel();
    _timerMonitoreo = Timer.periodic(const Duration(seconds: 2), (_) async {
      final bool conectado = await tieneConexionReal();

      // Si se cortó la red y la pantalla "Sin conexión" no está abierta, la abre automáticamente.
      if (!conectado && !_pantallaSinConexionAbierta) {
        if (claveNavegacionGlobal.currentState != null) {
          _pantallaSinConexionAbierta = true;
          claveNavegacionGlobal.currentState
              ?.push(
            MaterialPageRoute(
              builder: (context) => const PantallaSinConexion(),
            ),
          )
              .then((_) {
            _pantallaSinConexionAbierta = false;
          });
        }
      }
    });
  }

  /// Comprueba en tiempo real si el celular tiene acceso activo e instantáneo a internet.
  static Future<bool> tieneConexionReal() async {
  try {
    final socket = await Socket.connect(
      '8.8.8.8',
      53,
      timeout: const Duration(seconds: 2),
    );
    socket.destroy();
    return true;
  } catch (_) {
    try {
      final resultado = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return resultado.isNotEmpty && resultado[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
}