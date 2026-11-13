import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/modelos/horarioDisponible.dart';
import '../../datos/modelos/excepcionTurnos.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../../../medicos/datos/modelos/medico.dart';
import '../../../medicos/datos/modelos/horarioAtencion.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';

/// ViewModel para solicitar un nuevo turno médico con selección de fecha y hora.
class SolicitudTurnoViewModel extends ChangeNotifier {
  final RepositorioGestionTurnos _repositorioTurnos;
  final RepositorioMedicos _repositorioMedicos;
  final Medico medico;

  SolicitudTurnoViewModel(this._repositorioTurnos, this._repositorioMedicos, this.medico) {
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
  bool _huboConflictoDeHorario = false;

  // UUID v4 generado UNA sola vez para evitar duplicar turnos en reintentos por red.
  String? _claveSolicitudGenerada;
  DateTime? _fechaClaveGenerada;
  String? _horaClaveGenerada;

  bool get cargandoAgenda => _cargandoAgenda;
  bool get cargandoHorarios => _cargandoHorarios;
  bool get guardando => _guardando;
  String? get error => _error;
  String? get errorGeneral => _errorGeneral;

  Set<int> get diasConAtencion => _diasConAtencion;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  String? get horaSeleccionada => _horaSeleccionada;
  List<HorarioDisponible> get horariosDisponibles => _horariosDisponibles;
  bool get huboConflictoDeHorario => _huboConflictoDeHorario;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  /// Carga la agenda semanal del médico para saber qué días atiende.
  Future<void> _inicializar() async {
    _cargandoAgenda = true;
    _error = null;
    notifyListeners();

    try {
      _horariosAgenda = await _repositorioMedicos.obtenerHorarios(medico.id);
      _diasConAtencion = _horariosAgenda.where((h) => h.activo).map((h) => h.diaSemana).toSet();

      DateTime candidato = DateTime.now();
      for (int i = 0; i < 14; i++) {
        if (_diasConAtencion.contains(candidato.weekday)) {
          _fechaSeleccionada = DateTime(candidato.year, candidato.month, candidato.day);
          break;
        }
        candidato = candidato.add(const Duration(days: 1));
      }

      _cargandoAgenda = false;
      notifyListeners();

      if (_diasConAtencion.isNotEmpty) {
        await cargarDisponibilidad(_fechaSeleccionada);
      }
    } catch (_) {
      _cargandoAgenda = false;
      _error = 'No pudimos cargar la agenda del médico.';
      notifyListeners();
    }
  }

  /// Carga los horarios disponibles para una fecha dada.
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

  /// Obtiene o reutiliza la clave de solicitud única (UUID v4) para evitar duplicación ante reintentos.
  String _obtenerOCrearClaveSolicitud() {
    if (_claveSolicitudGenerada == null ||
        _fechaClaveGenerada != _fechaSeleccionada ||
        _horaClaveGenerada != _horaSeleccionada) {
      _claveSolicitudGenerada = const Uuid().v4();
      _fechaClaveGenerada = _fechaSeleccionada;
      _horaClaveGenerada = _horaSeleccionada;
    }
    return _claveSolicitudGenerada!;
  }

  /// Confirma y solicita el turno médico.
  Future<TurnoDetalle?> confirmar(int pacienteId) async {
    if (_horaSeleccionada == null) return null;

    _guardando = true;
    _huboConflictoDeHorario = false;
    _errorGeneral = null;
    notifyListeners();

    try {
      final clave = _obtenerOCrearClaveSolicitud();
      final turno = await _repositorioTurnos.solicitarTurno(
        pacienteId: pacienteId,
        medicoId: medico.id,
        fecha: _fechaSeleccionada,
        hora: _horaSeleccionada!,
        claveSolicitud: clave,
      );

      _guardando = false;
      notifyListeners();
      return turno;
    } on ExcepcionTurnos catch (e) {
      _guardando = false;
      if (e.tipo == ErrorTurnos.horarioOcupado) {
        _huboConflictoDeHorario = true;
        _errorGeneral = 'Ese horario ya fue reservado. Elegí otro.';
        await cargarDisponibilidad(_fechaSeleccionada);
      } else if (e.tipo == ErrorTurnos.horarioNoDisponible) {
        _huboConflictoDeHorario = true;
        _errorGeneral = 'Ese horario ya no está disponible.';
        await cargarDisponibilidad(_fechaSeleccionada);
      } else if (e.tipo == ErrorTurnos.medicoInactivo) {
        _errorGeneral = 'Este médico ya no está disponible.';
      } else if (e.tipo == ErrorTurnos.sinConexion) {
        _errorGeneral = 'Necesitás conexión con el servidor para solicitar el turno.';
      } else {
        _errorGeneral = e.mensajeServidor ?? 'No pudimos solicitar el turno.';
      }
      notifyListeners();
      return null;
    } catch (_) {
      _guardando = false;
      _errorGeneral = 'No pudimos solicitar el turno.';
      notifyListeners();
      return null;
    }
  }

  void reiniciar() {
    _horaSeleccionada = null;
    _huboConflictoDeHorario = false;
    _errorGeneral = null;
    _claveSolicitudGenerada = null;
    notifyListeners();
  }
}
