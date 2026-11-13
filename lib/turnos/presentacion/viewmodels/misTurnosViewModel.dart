import 'package:flutter/foundation.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/excepcionTurnos.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';

/// ViewModel para gestionar la lista de turnos del paciente (Próximos e Historial).
class MisTurnosViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final int pacienteId;

  MisTurnosViewModel(this._repositorioTurnos, {required this.pacienteId}) {
    cargar();
  }

  bool _descartado = false;
  bool _cargando = false;
  String? _error;
  String? _errorAccion;

  List<TurnoDetalle> _turnos = [];

  bool get cargando => _cargando;
  String? get error => _error;
  String? get errorAccion => _errorAccion;

  List<TurnoDetalle> get proximos {
    final lista = _turnos.where((t) => t.esProximo).toList();
    lista.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return lista;
  }

  List<TurnoDetalle> get historial {
    final lista = _turnos.where((t) => t.esHistorial).toList();
    lista.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    return lista;
  }

  int get cantProximos => proximos.length;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  /// Carga los turnos del paciente.
  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _turnos = await _repositorioTurnos.obtenerTurnos(pacienteId: pacienteId);
      _cargando = false;
      notifyListeners();
    } on ExcepcionTurnos catch (e) {
      _cargando = false;
      _error = e.mensajeServidor ?? 'No pudimos cargar tus turnos.';
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar tus turnos.';
      notifyListeners();
    }
  }

  /// Cancela un turno cambiando su estado a CANCELADO.
  Future<bool> cancelar(TurnoDetalle turno) async {
    _errorAccion = null;
    notifyListeners();

    try {
      await _repositorioTurnos.cambiarEstadoTurno(
        turnoId: turno.id,
        estado: EstadoTurno.cancelado,
      );
      await cargar();
      return true;
    } on ExcepcionTurnos catch (e) {
      if (e.tipo == ErrorTurnos.sinConexion) {
        _errorAccion = 'Necesitás conexión con el servidor para cancelar el turno.';
      } else {
        _errorAccion = e.mensajeServidor ?? 'No pudimos cancelar el turno.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _errorAccion = 'No pudimos cancelar el turno.';
      notifyListeners();
      return false;
    }
  }
}
