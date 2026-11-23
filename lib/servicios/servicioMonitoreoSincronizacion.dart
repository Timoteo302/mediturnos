import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../turnos/datos/repositorios/repositorioTurnosImpl.dart';
import 'servicioSincronizacion.dart';

class ServicioMonitoreoSincronizacion {
  final Connectivity _connectivity = Connectivity();
  final ServicioSincronizacion? _servicioSincronizacion;

  StreamSubscription<List<ConnectivityResult>>? _suscripcion;

  ServicioMonitoreoSincronizacion({http.Client? clienteHttp})
      : _servicioSincronizacion = clienteHttp != null
            ? ServicioSincronizacion(
                RepositorioTurnosImpl(),
                clienteHttp: clienteHttp,
              )
            : null;

  Future<void> iniciar() async {
    _suscripcion = _connectivity.onConnectivityChanged.listen(
      (resultados) {
        if (resultados.any(
          (resultado) => resultado != ConnectivityResult.none,
        )) {
          _servicioSincronizacion?.sincronizar();
        }
      },
    );

    final estado = await _connectivity.checkConnectivity();

    if (estado.any(
      (resultado) => resultado != ConnectivityResult.none,
    )) {
      await _servicioSincronizacion?.sincronizar();
    }
  }

  void detener() {
    _suscripcion?.cancel();
  }

  void sincronizarAhora() {
    _servicioSincronizacion?.sincronizar();
  }
}
