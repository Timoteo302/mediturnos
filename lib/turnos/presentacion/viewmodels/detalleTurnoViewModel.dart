import 'package:flutter/foundation.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/excepcionTurnos.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../../logica/formatoFechaEspanol.dart';

/// ViewModel para gestionar las acciones y detalles de un turno específico.
class DetalleTurnoViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final TurnoDetalle turno;

  DetalleTurnoViewModel(this._repositorioTurnos, this.turno);

  bool _descartado = false;
  bool _procesando = false;
  String? _error;

  bool get procesando => _procesando;
  String? get error => _error;

  String get fechaLarga => FormatoFechaEspanol.fechaLarga(turno.fecha);
  String get tiempoRestante => FormatoFechaEspanol.textoTiempoRestante(turno.fecha, turno.hora);
  String get numeroReserva => '#${turno.id}';

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  /// Cancela el turno actual.
  Future<bool> cancelar() async {
    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      await _repositorioTurnos.cambiarEstadoTurno(
        turnoId: turno.id,
        estado: EstadoTurno.cancelado,
      );
      _procesando = false;
      notifyListeners();
      return true;
    } on ExcepcionTurnos catch (e) {
      _procesando = false;
      if (e.tipo == ErrorTurnos.sinConexion) {
        _error = 'Necesitás conexión con el servidor para cancelar el turno.';
      } else {
        _error = e.mensajeServidor ?? 'No pudimos cancelar el turno.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _procesando = false;
      _error = 'No pudimos cancelar el turno.';
      notifyListeners();
      return false;
    }
  }
}
