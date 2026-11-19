import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../componentes/comunes/notificacionApp.dart';
import 'verificadorConexion.dart';
import 'servicioMonitoreoSincronizacion.dart';

// ViewModel global para monitorear el estado de la conexión a internet.
// Evita parpadeos requiriendo 2 fallos consecutivos para cambiar a "sin conexión" y notifica los cambios.
class EstadoConexionViewModel extends ChangeNotifier {
  final ServicioMonitoreoSincronizacion _servicioSincronizacion;
  final void Function(bool conectado)? alCambiarConexion;
  final Future<bool> Function()? verificadorConexion;

  bool? _conectado;
  bool? _estadoAnterior;
  int _fallosConsecutivos = 0;
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _descartado = false;

  bool? get conectado => _conectado;

  EstadoConexionViewModel(
    this._servicioSincronizacion, {
    this.alCambiarConexion,
    this.verificadorConexion,
  }) {
    _iniciarMonitoreo();
  }

  void _iniciarMonitoreo() {
    _chequearConexion(esInicial: true);

    // Chequeo periódico cada 10 segundos.
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _chequearConexion());

    // Chequeo por cambios en la red reportados por el sistema operativo.
    _subscription = Connectivity().onConnectivityChanged.listen((_) => _chequearConexion());
  }

  @visibleForTesting
  Future<void> chequearConexionParaTest({bool esInicial = false}) => _chequearConexion(esInicial: esInicial);

  Future<void> _chequearConexion({bool esInicial = false}) async {
    final funcionVerificar = verificadorConexion ?? VerificadorConexion.tieneConexionReal;
    final tieneConexion = await funcionVerificar();
    if (_descartado) return;

    if (tieneConexion) {
      _fallosConsecutivos = 0;
      if (_conectado != true) {
        final estabaDesconectado = _conectado == false;
        _conectado = true;
        notifyListeners();

        // Si recuperó la conexión, dispara la sincronización pendiente.
        if (estabaDesconectado) {
          _servicioSincronizacion.sincronizarAhora();
        }

        _notificarSiCorresponde(nuevoEstado: true);
        _estadoAnterior = true;
      }
    } else {
      _fallosConsecutivos++;
      // Pasa a "sin conexión" rápido si es el primer chequeo de la app, si no espera 2 fallos.
      if (_conectado != false && (esInicial || _fallosConsecutivos >= 2)) {
        _conectado = false;
        notifyListeners();

        _notificarSiCorresponde(nuevoEstado: false);
        _estadoAnterior = false;
      }
    }
  }

  // Muestra avisos globales o ejecuta el callback solo en los 3 casos especificados.
  void _notificarSiCorresponde({required bool nuevoEstado}) {
    final deTrueAFalse = _estadoAnterior == true && nuevoEstado == false;
    final deFalseATrue = _estadoAnterior == false && nuevoEstado == true;
    final deNullAFalse = _estadoAnterior == null && nuevoEstado == false;

    if (deTrueAFalse || deFalseATrue || deNullAFalse) {
      if (alCambiarConexion != null) {
        alCambiarConexion!(nuevoEstado);
      } else {
        if (nuevoEstado) {
          mostrarNotificacionAppGlobal(
            tipo: TipoNotificacionApp.exito,
            titulo: 'Conexión restablecida',
            mensaje: 'Estamos enviando tus cambios pendientes.',
          );
        } else {
          mostrarNotificacionAppGlobal(
            tipo: TipoNotificacionApp.advertencia,
            titulo: 'Sin conexión',
            mensaje: 'Podés seguir usando la app. Tus cambios se guardan en el celular y se envían cuando vuelva la conexión.',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
