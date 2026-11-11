import 'package:flutter/foundation.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/excepcionAutenticacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/configuracion/configuracionServidor.dart';

class AutenticacionViewModel extends ChangeNotifier {
  final RepositorioAutenticacion _repositorio;

  AutenticacionViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;
  Usuario? _usuarioActual;
  String? _errorEmail;
  String? _errorContrasena;
  String? _errorGeneral;

  bool get cargando => _cargando;
  Usuario? get usuarioActual => _usuarioActual;
  String? get errorEmail => _errorEmail;
  String? get errorContrasena => _errorContrasena;
  String? get errorGeneral => _errorGeneral;
  
  bool get modoSinConexion => _usuarioActual?.sesionOffline == true;
  bool get esAdmin => _usuarioActual?.rol == RolUsuario.admin;
  bool get estaAutenticado => _usuarioActual != null;

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
      _cargando = false;
      notifyListeners();
      return true;
    } on ExcepcionAutenticacion catch (e) {
      _cargando = false;
      switch (e.tipo) {
        case ErrorAutenticacion.credencialesInvalidas:
          _errorGeneral = 'Correo o contraseña incorrectos.';
          break;
        case ErrorAutenticacion.cuentaInactiva:
          _errorGeneral = 'Tu cuenta está desactivada. Contactá a la clínica.';
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

  Future<void> cerrarSesion() async {
    _cargando = true;
    notifyListeners();
    _usuarioActual = null;
    _cargando = false;
    notifyListeners();
  }
}
