import 'package:flutter/foundation.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/excepcionTurnos.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';

/// ViewModel para gestionar la lista de turnos del paciente (Próximos e Historial).
class MisTurnosViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final int? pacienteId;

  MisTurnosViewModel(this._repositorioTurnos, {this.pacienteId}) {
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
    final noRegistrados = _turnos.where((t) => t.noRegistrado).toList();
    final proxs = _turnos.where((t) => t.esProximo).toList();
    proxs.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return [...noRegistrados, ...proxs];
  }

  List<TurnoDetalle> get historial {
    final lista = _turnos.where((t) => t.esHistorial).toList();
    lista.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    return lista;
  }

  int get cantProximos => _turnos.where((t) => t.esProximo).length;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  /// Carga los turnos del paciente. Si es invitado (pacienteId == null), deja la lista vacía sin llamar al repositorio.
  Future<void> cargar() async {
    if (pacienteId == null) {
      _cargando = false;
      _turnos = [];
      _error = null;
      notifyListeners();
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _turnos = await _repositorioTurnos.obtenerTurnos(pacienteId: pacienteId!);
      _cargando = false;
      notifyListeners();
    } on ExcepcionTurnos catch (e) {
      _cargando = false;
      if (e.tipo == ErrorTurnos.sinConexion) {
        // En modo offline sin caché local, tratamos la lista como vacía para no bloquear la pantalla
        _turnos = [];
        _error = null;
      } else {
        _error = e.mensajeServidor ?? 'No pudimos cargar tus turnos.';
      }
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _turnos = [];
      _error = null;
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
