import 'dart:async';
import 'package:flutter/material.dart';
import '../../../autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import '../../../servicios/estadoConexionViewModel.dart';
import '../../../turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../../../turnos/datos/modelos/turnoDetalle.dart';
import '../../../turnos/datos/modelos/excepcionTurnos.dart';
import '../../datos/modelos/notificacion.dart';
import '../../datos/repositorios/repositorioNotificaciones.dart';

// ViewModel global para gestionar las notificaciones de la app, consulta periódica y respuesta a asistencias.
class NotificacionesViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final RepositorioNotificaciones _repositorioNotificaciones;
  final RepositorioGestionTurnos _repositorioTurnos;
  final AutenticacionViewModel _authVm;
  final EstadoConexionViewModel _conexionVm;

  int _cantidadNoLeidas = 0;
  List<Notificacion> _notificaciones = [];
  bool _cargando = false;
  String? _error;
  Timer? _timerPolling;
  bool _descartado = false;

  int get cantidadNoLeidas => _cantidadNoLeidas;
  List<Notificacion> get notificaciones => _notificaciones;
  bool get cargando => _cargando;
  String? get error => _error;

  NotificacionesViewModel({
    required RepositorioNotificaciones repositorioNotificaciones,
    required RepositorioGestionTurnos repositorioTurnos,
    required AutenticacionViewModel authVm,
    required EstadoConexionViewModel conexionVm,
  })  : _repositorioNotificaciones = repositorioNotificaciones,
        _repositorioTurnos = repositorioTurnos,
        _authVm = authVm,
        _conexionVm = conexionVm {
    WidgetsBinding.instance.addObserver(this);
    _authVm.addListener(_alCambiarAuth);
    _conexionVm.addListener(_alCambiarConexion);
    _evaluarMonitoreo();
  }

  void _alCambiarAuth() {
    _evaluarMonitoreo();
  }

  void _alCambiarConexion() {
    if (_conexionVm.conectado == true && _authVm.estaAutenticado) {
      consultarCantidadNoLeidas();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _authVm.estaAutenticado && _conexionVm.conectado == true) {
      consultarCantidadNoLeidas();
    }
  }

  void _evaluarMonitoreo() {
    if (_authVm.estaAutenticado) {
      consultarCantidadNoLeidas();
      _iniciarPolling();
    } else {
      _detenerPolling();
      _cantidadNoLeidas = 0;
      _notificaciones = [];
      notifyListeners();
    }
  }

  void _iniciarPolling() {
    _timerPolling?.cancel();
    _timerPolling = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_authVm.estaAutenticado && _conexionVm.conectado == true) {
        consultarCantidadNoLeidas();
      }
    });
  }

  void _detenerPolling() {
    _timerPolling?.cancel();
    _timerPolling = null;
  }

  // Consulta la cantidad de notificaciones no leídas para actualizar la campanita.
  Future<void> consultarCantidadNoLeidas() async {
    final usuarioId = _authVm.usuarioActual?.id;
    if (usuarioId == null || _conexionVm.conectado == false) return;

    try {
      final cant = await _repositorioNotificaciones.obtenerCantidadNoLeidas(usuarioId: usuarioId);
      if (_descartado) return;
      _cantidadNoLeidas = cant;
      notifyListeners();
    } catch (_) {}
  }

  // Carga el listado de notificaciones del usuario logueado.
  Future<void> cargar() async {
    final usuarioId = _authVm.usuarioActual?.id;
    if (usuarioId == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final lista = await _repositorioNotificaciones.obtenerNotificaciones(usuarioId: usuarioId);
      if (_descartado) return;
      _notificaciones = lista;
      _cantidadNoLeidas = lista.where((n) => !n.leida).length;
      _cargando = false;
      notifyListeners();
    } on ExcepcionTurnos catch (e) {
      if (_descartado) return;
      _cargando = false;
      _error = e.mensajeServidor ?? 'No pudimos cargar las notificaciones.';
      notifyListeners();
    } catch (_) {
      if (_descartado) return;
      _cargando = false;
      _error = 'No pudimos cargar las notificaciones.';
      notifyListeners();
    }
  }

  // Marca una notificación como leída local y remotamente.
  Future<void> marcarLeida(int id) async {
    try {
      await _repositorioNotificaciones.marcarLeida(id: id);
      final idx = _notificaciones.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notificaciones[idx].leida) {
        final antigua = _notificaciones[idx];
        _notificaciones[idx] = Notificacion(
          id: antigua.id,
          tipo: antigua.tipo,
          titulo: antigua.titulo,
          mensaje: antigua.mensaje,
          leida: true,
          fechaCreacion: antigua.fechaCreacion,
          turnoId: antigua.turnoId,
          turnoFecha: antigua.turnoFecha,
          turnoHora: antigua.turnoHora,
          turnoEstado: antigua.turnoEstado,
          respuestaPaciente: antigua.respuestaPaciente,
        );
        if (_cantidadNoLeidas > 0) _cantidadNoLeidas--;
        notifyListeners();
      }
    } catch (_) {}
  }

  // Marca todas las notificaciones del usuario como leídas.
  Future<void> marcarTodasLeidas() async {
    final usuarioId = _authVm.usuarioActual?.id;
    if (usuarioId == null) return;

    try {
      await _repositorioNotificaciones.marcarTodasLeidas(usuarioId: usuarioId);
      _notificaciones = _notificaciones.map((n) {
        return Notificacion(
          id: n.id,
          tipo: n.tipo,
          titulo: n.titulo,
          mensaje: n.mensaje,
          leida: true,
          fechaCreacion: n.fechaCreacion,
          turnoId: n.turnoId,
          turnoFecha: n.turnoFecha,
          turnoHora: n.turnoHora,
          turnoEstado: n.turnoEstado,
          respuestaPaciente: n.respuestaPaciente,
        );
      }).toList();
      _cantidadNoLeidas = 0;
      notifyListeners();
    } catch (_) {}
  }

  // Envía la respuesta de asistencia de un turno a la API. Requiere conexión a internet.
  Future<TurnoDetalle?> responderAsistencia(int turnoId, bool asistira) async {
    if (_conexionVm.conectado == false) {
      throw ExcepcionTurnos(
        ErrorTurnos.sinConexion,
        mensajeServidor: 'Necesitás conexión para responder.',
      );
    }

    try {
      final turnoActualizado = await _repositorioTurnos.responderAsistencia(
        turnoId: turnoId,
        asistira: asistira,
      );
      await consultarCantidadNoLeidas();
      return turnoActualizado;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _descartado = true;
    WidgetsBinding.instance.removeObserver(this);
    _detenerPolling();
    _authVm.removeListener(_alCambiarAuth);
    _conexionVm.removeListener(_alCambiarConexion);
    super.dispose();
  }
}
