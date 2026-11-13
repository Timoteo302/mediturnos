import 'package:flutter/foundation.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/modelos/horarioDisponible.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/excepcionTurnos.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../../../medicos/datos/modelos/medico.dart';
import '../../../medicos/datos/modelos/horarioAtencion.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';

/// ViewModel para reprogramar la fecha y hora de un turno existente.
class ModificarTurnoViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final RepositorioMedicos _repositorioMedicos;
  final TurnoDetalle turnoOriginal;
  final Medico medico;

  ModificarTurnoViewModel(
    this._repositorioTurnos,
    this._repositorioMedicos,
    this.turnoOriginal,
    this.medico,
  ) {
    _inicializar();
  }

  bool _descartado = false;
  bool _cargandoAgenda = true;
  bool _cargandoHorarios = false;
  bool _guardando = false;
  String? _error;
  String? _errorGeneral;

  List<HorarioAtencion> _horariosAgenda = [];
  Set<int> _diasConAtencion = {};
  DateTime _fechaSeleccionada = DateTime.now();
  String? _horaSeleccionada;
  List<HorarioDisponible> _horariosDisponibles = [];

  bool get cargandoAgenda => _cargandoAgenda;
  bool get cargandoHorarios => _cargandoHorarios;
  bool get guardando => _guardando;
  String? get error => _error;
  String? get errorGeneral => _errorGeneral;

  Set<int> get diasConAtencion => _diasConAtencion;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  String? get horaSeleccionada => _horaSeleccionada;
  List<HorarioDisponible> get horariosDisponibles => _horariosDisponibles;

  /// Indica si se puede guardar (el usuario cambió fecha u hora respecto al turno original).
  bool get puedeGuardar {
    if (_horaSeleccionada == null) return false;
    final mismaFecha = _fechaSeleccionada.year == turnoOriginal.fecha.year &&
        _fechaSeleccionada.month == turnoOriginal.fecha.month &&
        _fechaSeleccionada.day == turnoOriginal.fecha.day;
    final mismaHora = _horaSeleccionada == turnoOriginal.hora;
    return !(mismaFecha && mismaHora);
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

  Future<void> _inicializar() async {
    _cargandoAgenda = true;
    _error = null;
    notifyListeners();

    try {
      _horariosAgenda = await _repositorioMedicos.obtenerHorarios(medico.id);
      _diasConAtencion = _horariosAgenda.where((h) => h.activo).map((h) => h.diaSemana).toSet();

      _fechaSeleccionada = DateTime(turnoOriginal.fecha.year, turnoOriginal.fecha.month, turnoOriginal.fecha.day);
      _horaSeleccionada = turnoOriginal.hora;

      _cargandoAgenda = false;
      notifyListeners();

      await cargarDisponibilidad(_fechaSeleccionada);
    } catch (_) {
      _cargandoAgenda = false;
      _error = 'No pudimos cargar la agenda del médico.';
      notifyListeners();
    }
  }

  Future<void> cargarDisponibilidad(DateTime fecha) async {
    _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);
    _horaSeleccionada = null;
    _cargandoHorarios = true;
    _errorGeneral = null;
    notifyListeners();

    try {
      _horariosDisponibles = await _repositorioTurnos.obtenerDisponibilidad(
        medicoId: medico.id,
        fecha: _fechaSeleccionada,
      );
      _cargandoHorarios = false;
      notifyListeners();
    } on ExcepcionTurnos catch (e) {
      _cargandoHorarios = false;
      _errorGeneral = e.mensajeServidor ?? 'No pudimos consultar la disponibilidad.';
      notifyListeners();
    } catch (_) {
      _cargandoHorarios = false;
      _errorGeneral = 'No pudimos consultar la disponibilidad.';
      notifyListeners();
    }
  }

  void seleccionarHora(String hora) {
    _horaSeleccionada = hora;
    _errorGeneral = null;
    notifyListeners();
  }

  /// Reprograma el turno con la nueva fecha y hora seleccionadas.
  Future<bool> guardar() async {
    if (!puedeGuardar) return false;

    _guardando = true;
    _errorGeneral = null;
    notifyListeners();

    try {
      await _repositorioTurnos.reprogramarTurno(
        turnoId: turnoOriginal.id,
        fecha: _fechaSeleccionada,
        hora: _horaSeleccionada!,
      );

      _guardando = false;
      notifyListeners();
      return true;
    } on ExcepcionTurnos catch (e) {
      _guardando = false;
      if (e.tipo == ErrorTurnos.horarioOcupado || e.tipo == ErrorTurnos.horarioNoDisponible) {
        _errorGeneral = 'Ese horario ya no está disponible. Elegí otro.';
        await cargarDisponibilidad(_fechaSeleccionada);
      } else if (e.tipo == ErrorTurnos.sinConexion) {
        _errorGeneral = 'Necesitás conexión con el servidor para modificar el turno.';
      } else {
        _errorGeneral = e.mensajeServidor ?? 'No pudimos modificar el turno.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _guardando = false;
      _errorGeneral = 'No pudimos modificar el turno.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelar() async {
    _guardando = true;
    _errorGeneral = null;
    notifyListeners();

    try {
      await _repositorioTurnos.cambiarEstadoTurno(
        turnoId: turnoOriginal.id,
        estado: EstadoTurno.cancelado,
      );
      _guardando = false;
      notifyListeners();
      return true;
    } on ExcepcionTurnos catch (e) {
      _guardando = false;
      _errorGeneral = e.mensajeServidor ?? 'No pudimos cancelar el turno.';
      notifyListeners();
      return false;
    } catch (_) {
      _guardando = false;
      _errorGeneral = 'No pudimos cancelar el turno.';
      notifyListeners();
      return false;
    }
  }
}
