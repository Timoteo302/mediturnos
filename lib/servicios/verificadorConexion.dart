import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediturnos/configuracion/configuracionServidor.dart';
import 'package:mediturnos/configuracion/clavesGlobales.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaSinConexion.dart';

// Permite comprobar la conectividad del dispositivo con el servidor backend y desplegar alertas.
class VerificadorConexion {
  VerificadorConexion._();

  static Timer? _timerMonitoreo;
  static bool _pantallaSinConexionAbierta = false;

  // Inicia la comprobación periódica de red en segundo plano.
  static void iniciarMonitoreoGlobal() {
    _timerMonitoreo?.cancel();
    _timerMonitoreo = Timer.periodic(const Duration(seconds: 4), (_) async {
      final bool conectado = await tieneConexionReal();

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

  // Verifica conectividad real enviando una solicitud HTTP GET liviana al endpoint /salud del servidor backend.
  static Future<bool> tieneConexionReal({http.Client? clienteHttp}) async {
    final resultados = await Connectivity().checkConnectivity();
    if (resultados.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

    try {
      final cliente = clienteHttp ?? http.Client();
      // Consultamos la ruta GET /salud para verificar la disponibilidad real del servidor backend de forma liviana y rápida.
      final respuesta = await cliente
          .get(Uri.parse('${ConfiguracionServidor.urlBase}/salud'))
          .timeout(const Duration(seconds: 3));
      if (clienteHttp == null) {
        cliente.close();
      }
      return respuesta.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
