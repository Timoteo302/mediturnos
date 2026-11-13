import 'package:flutter/foundation.dart';
import '../../../../turnos/datos/modelos/turnoDetalle.dart';
import '../../../../turnos/datos/modelos/estadoTurno.dart';
import '../../../../turnos/datos/modelos/excepcionTurnos.dart';
import '../../../../turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../../../../medicos/datos/modelos/medico.dart';
import '../../../../medicos/datos/repositorios/repositorioMedicos.dart';

/// ViewModel para el panel de inicio del administrador de la clínica.
class PanelAdminViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final RepositorioMedicos _repositorioMedicos;

  PanelAdminViewModel(this._repositorioTurnos, this._repositorioMedicos) {
    cargar();
  }

  bool _descartado = false;
  bool _cargando = false;
  String? _error;

  List<TurnoDetalle> _turnosHoy = [];
  List<Medico> _medicos = [];

  bool get cargando => _cargando;
  String? get error => _error;
  List<TurnoDetalle> get turnosHoy => _turnosHoy;

  int get confirmados => _turnosHoy.where((t) => t.estado == EstadoTurno.confirmado).length;
  int get pendientes => _turnosHoy.where((t) => t.estado == EstadoTurno.pendiente).length;
  int get medicosActivos => _medicos.where((m) => m.activo).length;
  int get totalMedicos => _medicos.length;

  List<TurnoDetalle> get pendientesHoy {
    final lista = _turnosHoy.where((t) => t.estado == EstadoTurno.pendiente).toList();
    lista.sort((a, b) => a.hora.compareTo(b.hora));
    return lista.take(5).toList();
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

  /// Carga los turnos de hoy y la lista de médicos para el resumen del admin.
  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final hoy = DateTime.now();
      final resultados = await Future.wait([
        _repositorioTurnos.obtenerTurnos(fecha: hoy),
        _repositorioMedicos.obtenerMedicos(incluirInactivos: true),
      ]);

      _turnosHoy = resultados[0] as List<TurnoDetalle>;
      _medicos = resultados[1] as List<Medico>;

      _cargando = false;
      notifyListeners();
    } on ExcepcionTurnos catch (e) {
      _cargando = false;
      _error = e.mensajeServidor ?? 'No pudimos cargar el resumen operativo.';
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar el resumen operativo.';
      notifyListeners();
    }
  }
}
