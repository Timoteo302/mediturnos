import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../turnos/datos/repositorios/repositorioTurnosImpl.dart';
import 'servicioSincronizacion.dart';

class ServicioMonitoreoSincronizacion {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _suscripcion;

  final ServicioSincronizacion _servicioSincronizacion =
      ServicioSincronizacion(RepositorioTurnosImpl());

  Future<void> iniciar() async {
    _suscripcion = _connectivity.onConnectivityChanged.listen(
      (resultados) {
        if (resultados.any(
          (resultado) => resultado != ConnectivityResult.none,
        )) {
          _servicioSincronizacion.sincronizar();
        }
      },
    );

    final estado = await _connectivity.checkConnectivity();

    if (estado.any(
      (resultado) => resultado != ConnectivityResult.none,
    )) {
      await _servicioSincronizacion.sincronizar();
    }
  }

  void detener() {
    _suscripcion?.cancel();
  }

  void sincronizarAhora() {
  _servicioSincronizacion.sincronizar();
}
}