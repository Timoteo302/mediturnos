import 'package:flutter/foundation.dart';
import '../../../../turnos/datos/modelos/turnoDetalle.dart';
import '../../../../turnos/datos/modelos/estadoTurno.dart';
import '../../../../turnos/datos/modelos/excepcionTurnos.dart';
import '../../../../turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../../../../turnos/logica/formatoFechaEspanol.dart';

/// ViewModel para gestionar el estado de la pantalla de inicio del paciente.
class InicioPacienteViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final int pacienteId;
  final String nombreUsuario;

  InicioPacienteViewModel(this._repositorioTurnos, {required this.pacienteId, required this.nombreUsuario}) {
    cargar();
  }

  bool _descartado = false;
  bool _cargando = false;
  String? _error;
  List<TurnoDetalle> _turnos = [];

  bool get cargando => _cargando;
  String? get error => _error;
  List<TurnoDetalle> get turnos => _turnos;

  String get saludo => 'Hola, $nombreUsuario';
  String get fechaHoy => FormatoFechaEspanol.fechaLarga(DateTime.now());

  int get cantidadActivos => _turnos.where((t) => t.esProximo).length;

  TurnoDetalle? get proximoTurno {
    final proximos = _turnos.where((t) => t.esProximo).toList();
    if (proximos.isEmpty) return null;
    proximos.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return proximos.first;
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  /// Carga los turnos del paciente desde el repositorio.
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
      if (e.tipo == ErrorTurnos.sinConexion) {
        // En modo offline sin caché local de turnos, tratamos la lista como vacía para no bloquear la UI
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
}
