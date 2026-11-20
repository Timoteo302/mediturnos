import 'package:flutter/foundation.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/excepcionAutenticacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/configuracion/configuracionServidor.dart';
import 'package:mediturnos/servicios/servicioLimpiezaLocal.dart';

// Estructura en memoria para almacenar una reserva seleccionada por un invitado antes de iniciar sesión.
class ReservaPendienteInvitado {
  final int medicoId;
  final DateTime fecha;
  final String hora;
  final String medicoNombre;
  final String especialidadNombre;

  ReservaPendienteInvitado({
    required this.medicoId,
    required this.fecha,
    required this.hora,
    required this.medicoNombre,
    required this.especialidadNombre,
  });
}

// ViewModel para gestionar el estado de sesión, autenticación y modo invitado del usuario.
class AutenticacionViewModel extends ChangeNotifier {
  final RepositorioAutenticacion _repositorio;
  final Future<void> Function() _limpiezaLocal;

  AutenticacionViewModel(
    this._repositorio, {
    Future<void> Function()? limpiezaLocal,
  }) : _limpiezaLocal = limpiezaLocal ?? limpiarDatosAlCerrarSesion;

  bool _descartado = false;
  bool _cargando = false;
  bool _esInvitado = false;
  Usuario? _usuarioActual;
  ReservaPendienteInvitado? _reservaPendiente;
  String? _errorEmail;
  String? _errorContrasena;
  String? _errorGeneral;
  ErrorAutenticacion? _ultimoError;

  bool get cargando => _cargando;
  bool get esInvitado => _esInvitado;
  Usuario? get usuarioActual => _usuarioActual;
  ReservaPendienteInvitado? get reservaPendiente => _reservaPendiente;
  String? get errorEmail => _errorEmail;
  String? get errorContrasena => _errorContrasena;
  String? get errorGeneral => _errorGeneral;
  ErrorAutenticacion? get ultimoError => _ultimoError;
  
  bool get modoSinConexion => _usuarioActual?.sesionOffline == true;
  bool get esAdmin => _usuarioActual?.rol == RolUsuario.admin;
  bool get estaAutenticado => _usuarioActual != null;

  // Activa el modo invitado en memoria sin usuario logueado.
  void entrarComoInvitado() {
    _esInvitado = true;
    _usuarioActual = null;
    notifyListeners();
  }

  // Sale del modo invitado para permitir iniciar sesión o crear cuenta.
  void salirDeInvitado() {
    _esInvitado = false;
    notifyListeners();
  }

  // Guarda los datos de la reserva pendiente que seleccionó el invitado.
  void guardarReservaPendiente({
    required int medicoId,
    required DateTime fecha,
    required String hora,
    required String medicoNombre,
    required String especialidadNombre,
  }) {
    _reservaPendiente = ReservaPendienteInvitado(
      medicoId: medicoId,
      fecha: fecha,
      hora: hora,
      medicoNombre: medicoNombre,
      especialidadNombre: especialidadNombre,
    );
    notifyListeners();
  }

  // Limpia los datos de la reserva pendiente.
  void limpiarReservaPendiente() {
    _reservaPendiente = null;
    notifyListeners();
  }

  // Actualiza los datos en memoria del usuario logueado e intenta refrescar la copia guardada en SQLite.
  Future<void> actualizarUsuarioActual(Usuario u) async {
    final offline = _usuarioActual?.sesionOffline ?? u.sesionOffline;
    _usuarioActual = u.copiarConSesionOffline(offline);
    notifyListeners();

    try {
      await _repositorio.actualizarCopiaLocal(u);
    } catch (e) {
      debugPrint('Error al actualizar copia local: $e');
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) {
      super.notifyListeners();
    }
  }

  void limpiarErrores() {
    _errorEmail = null;
    _errorContrasena = null;
    _errorGeneral = null;
    _ultimoError = null;
    notifyListeners();
  }

  String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }
    final emailNorm = valor.trim().toLowerCase();
    final regex = RegExp(ConfiguracionServidor.regexEmail);
    if (!regex.hasMatch(emailNorm) || emailNorm.length > 150) {
      return 'Ingresá un correo electrónico válido.';
    }
    return null;
  }

  String? validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    return null;
  }

  Future<bool> iniciarSesion(String email, String contrasena) async {
    limpiarErrores();

    final errEmail = validarEmail(email);
    final errPass = validarContrasena(contrasena);

    if (errEmail != null || errPass != null) {
      _errorEmail = errEmail;
      _errorContrasena = errPass;
      notifyListeners();
      return false;
    }

    _cargando = true;
    notifyListeners();

    try {
      _usuarioActual = await _repositorio.iniciarSesion(email, contrasena);
      _esInvitado = false;
      _cargando = false;
      notifyListeners();
      return true;
    } on ExcepcionAutenticacion catch (e) {
      _cargando = false;
      _ultimoError = e.tipo;
      switch (e.tipo) {
        case ErrorAutenticacion.credencialesInvalidas:
          _errorGeneral = 'Correo o contraseña incorrectos.';
          break;
        case ErrorAutenticacion.cuentaInactiva:
          _errorGeneral = 'Tu cuenta está desactivada. Contactá a la clínica.';
          break;
        case ErrorAutenticacion.activacionPendiente:
          _errorGeneral = e.mensaje ?? 'Tu cuenta requiere ser activada. Verificá tu correo.';
          break;
        case ErrorAutenticacion.sinConexion:
          _errorGeneral = 'Necesitás conexión la primera vez que iniciás sesión en este dispositivo.';
          break;
        case ErrorAutenticacion.errorServidor:
          _errorGeneral = 'El servidor tuvo un problema. Intentá de nuevo.';
          break;
        default:
          _errorGeneral = 'No pudimos iniciar sesión. Intentá de nuevo.';
          break;
      }
      notifyListeners();
      return false;
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos iniciar sesión. Intentá de nuevo.';
      notifyListeners();
      return false;
    }
  }

  // Cierra la sesión activa del usuario, resetea el estado invitado y ejecuta la limpieza local.
  Future<void> cerrarSesion() async {
    _cargando = true;
    notifyListeners();

    try {
      await _limpiezaLocal();
    } catch (e) {
      debugPrint('Error al limpiar datos locales al cerrar sesión: $e');
    }

    _esInvitado = false;
    _usuarioActual = null;
    _cargando = false;
    notifyListeners();
  }
}
