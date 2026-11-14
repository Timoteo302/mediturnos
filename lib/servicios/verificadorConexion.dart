import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediturnos/configuracion/configuracionServidor.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaSinConexion.dart';

final GlobalKey<NavigatorState> claveNavegacionGlobal = GlobalKey<NavigatorState>();

class VerificadorConexion {
  VerificadorConexion._();

  static Timer? _timerMonitoreo;
  static bool _pantallaSinConexionAbierta = false;

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

  static Future<bool> tieneConexionReal() async {
    final resultados = await Connectivity().checkConnectivity();
    if (resultados.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

    try {
      final respuesta = await http
          .get(Uri.parse(ConfiguracionServidor.urlBase))
          .timeout(const Duration(seconds: 3));
      return respuesta.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}