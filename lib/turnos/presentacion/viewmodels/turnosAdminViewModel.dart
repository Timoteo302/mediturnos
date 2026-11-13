import 'package:flutter/foundation.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/excepcionTurnos.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../../../medicos/datos/modelos/medico.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';

/// ViewModel para gestionar la grilla general de turnos desde el panel de administración.
class TurnosAdminViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final RepositorioMedicos _repositorioMedicos;
  final EstadoTurno? filtroInicial;

  TurnosAdminViewModel(this._repositorioTurnos, this._repositorioMedicos, {this.filtroInicial}) {
    if (filtroInicial != null) {
      if (filtroInicial == EstadoTurno.pendiente) _filtroEstado = 'pendientes';
      if (filtroInicial == EstadoTurno.confirmado) _filtroEstado = 'confirmados';
    }
    _inicializar();
  }

  bool _descartado = false;
  bool _cargando = false;
  String? _error;
  String? _errorAccion;

  DateTime _fechaSeleccionada = DateTime.now();
  Medico? _medicoSeleccionado; // null = todos
  String _filtroEstado = 'todos'; // 'todos', 'pendientes', 'confirmados'
  int? _idProcesando;

  List<TurnoDetalle> _turnos = [];
  List<Medico> _medicosActivos = [];

  bool get cargando => _cargando;
  String? get error => _error;
  String? get errorAccion => _errorAccion;

  DateTime get fechaSeleccionada => _fechaSeleccionada;
  Medico? get medicoSeleccionado => _medicoSeleccionado;
  String get filtroEstado => _filtroEstado;
  int? get idProcesando => _idProcesando;
  List<Medico> get medicosActivos => _medicosActivos;

  List<TurnoDetalle> get visibles {
    List<TurnoDetalle> lista = _turnos;
    if (_filtroEstado == 'pendientes') {
      lista = lista.where((t) => t.estado == EstadoTurno.pendiente).toList();
    } else if (_filtroEstado == 'confirmados') {
      lista = lista.where((t) => t.estado == EstadoTurno.confirmado).toList();
    }
    return lista;
  }

  int get cantTodos => _turnos.length;
  int get cantPendientes => _turnos.where((t) => t.estado == EstadoTurno.pendiente).length;
  int get cantConfirmados => _turnos.where((t) => t.estado == EstadoTurno.confirmado).length;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  Future<void> _inicializar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _repositorioMedicos.obtenerMedicos(incluirInactivos: false),
        _repositorioTurnos.obtenerTurnos(fecha: _fechaSeleccionada),
      ]);

      _medicosActivos = resultados[0] as List<Medico>;
      _turnos = resultados[1] as List<TurnoDetalle>;

      _cargando = false;
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar los turnos.';
      notifyListeners();
    }
  }

  Future<void> cambiarFecha(DateTime nuevaFecha) async {
    _fechaSeleccionada = DateTime(nuevaFecha.year, nuevaFecha.month, nuevaFecha.day);
    await cargarTurnos();
  }

  Future<void> seleccionarMedico(Medico? medico) async {
    _medicoSeleccionado = medico;
    await cargarTurnos();
  }

  void cambiarFiltroEstado(String filtro) {
    _filtroEstado = filtro;
    notifyListeners();
  }

  Future<void> cargarTurnos() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _turnos = await _repositorioTurnos.obtenerTurnos(
        fecha: _fechaSeleccionada,
        medicoId: _medicoSeleccionado?.id,
      );
      _cargando = false;
      notifyListeners();
    } on ExcepcionTurnos catch (e) {
      _cargando = false;
      _error = e.mensajeServidor ?? 'No pudimos cargar los turnos.';
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar los turnos.';
      notifyListeners();
    }
  }

  /// Confirma un turno en estado pendiente.
  Future<bool> confirmar(TurnoDetalle turno) async {
    _idProcesando = turno.id;
    _errorAccion = null;
    notifyListeners();

    try {
      await _repositorioTurnos.cambiarEstadoTurno(
        turnoId: turno.id,
        estado: EstadoTurno.confirmado,
      );
      await cargarTurnos();
      _idProcesando = null;
      notifyListeners();
      return true;
    } on ExcepcionTurnos catch (e) {
      _idProcesando = null;
      _errorAccion = e.mensajeServidor ?? 'No pudimos confirmar el turno.';
      notifyListeners();
      return false;
    } catch (_) {
      _idProcesando = null;
      _errorAccion = 'No pudimos confirmar el turno.';
      notifyListeners();
      return false;
    }
  }

  /// Marca un turno confirmado como atendido.
  Future<bool> marcarAtendido(TurnoDetalle turno) async {
    _idProcesando = turno.id;
    _errorAccion = null;
    notifyListeners();

    try {
      await _repositorioTurnos.cambiarEstadoTurno(
        turnoId: turno.id,
        estado: EstadoTurno.atendido,
      );
      await cargarTurnos();
      _idProcesando = null;
      notifyListeners();
      return true;
    } on ExcepcionTurnos catch (e) {
      _idProcesando = null;
      _errorAccion = e.mensajeServidor ?? 'No pudimos marcar el turno como atendido.';
      notifyListeners();
      return false;
    } catch (_) {
      _idProcesando = null;
      _errorAccion = 'No pudimos marcar el turno como atendido.';
      notifyListeners();
      return false;
    }
  }
}
