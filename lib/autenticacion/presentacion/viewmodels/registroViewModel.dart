import 'package:flutter/foundation.dart';
import 'package:mediturnos/autenticacion/datos/modelos/excepcionAutenticacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'package:mediturnos/configuracion/configuracionServidor.dart';

class RegistroViewModel extends ChangeNotifier {
  final RepositorioAutenticacion _repositorio;

  RegistroViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;

  String? _errorNombre;
  String? _errorApellido;
  String? _errorDni;
  String? _errorEmail;
  String? _errorContrasena;
  String? _errorConfirmacion;
  String? _errorGeneral;

  bool get cargando => _cargando;
  String? get errorNombre => _errorNombre;
  String? get errorApellido => _errorApellido;
  String? get errorDni => _errorDni;
  String? get errorEmail => _errorEmail;
  String? get errorContrasena => _errorContrasena;
  String? get errorConfirmacion => _errorConfirmacion;
  String? get errorGeneral => _errorGeneral;

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

  void limpiarError(String campo) {
    switch (campo) {
      case 'nombre':
        _errorNombre = null;
        break;
      case 'apellido':
        _errorApellido = null;
        break;
      case 'dni':
        _errorDni = null;
        break;
      case 'email':
        _errorEmail = null;
        break;
      case 'contrasena':
        _errorContrasena = null;
        break;
      case 'confirmacion':
        _errorConfirmacion = null;
        break;
    }
    _errorGeneral = null;
    notifyListeners();
  }

  String? validarNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio.';
    final val = v.trim();
    if (val.length < 2 || val.length > 100) return 'El nombre debe tener entre 2 y 100 caracteres.';
    final regex = RegExp(r"^[\p{L}\s'\-]+$", unicode: true);
    if (!regex.hasMatch(val)) return 'El nombre contiene caracteres inválidos.';
    return null;
  }

  String? validarApellido(String? v) {
    if (v == null || v.trim().isEmpty) return 'El apellido es obligatorio.';
    final val = v.trim();
    if (val.length < 2 || val.length > 100) return 'El apellido debe tener entre 2 y 100 caracteres.';
    final regex = RegExp(r"^[\p{L}\s'\-]+$", unicode: true);
    if (!regex.hasMatch(val)) return 'El apellido contiene caracteres inválidos.';
    return null;
  }

  String? validarDni(String? v) {
    if (v == null || v.trim().isEmpty) return 'El DNI es obligatorio.';
    final val = v.trim();
    final regex = RegExp(r'^\d{7,8}$');
    if (!regex.hasMatch(val)) return 'El DNI debe tener 7 u 8 números, sin puntos ni espacios.';
    return null;
  }

  String? validarEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo electrónico es obligatorio.';
    final val = v.trim().toLowerCase();
    final regex = RegExp(ConfiguracionServidor.regexEmail);
    if (!regex.hasMatch(val) || val.length > 150) return 'Ingresá un correo electrónico válido.';
    return null;
  }

  String? validarContrasena(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es obligatoria.';
    if (v.length < 8 || v.length > 72) return 'La contraseña debe tener entre 8 y 72 caracteres.';
    return null;
  }

  String? validarConfirmacion(String? v, String pass) {
    if (v == null || v.isEmpty) return 'Confirmá tu contraseña.';
    if (v != pass) return 'Las contraseñas no coinciden.';
    return null;
  }

  Future<bool> registrar({
    required String nombre,
    required String apellido,
    required String dni,
    required String email,
    required String contrasena,
    required String confirmacion,
  }) async {
    _errorNombre = validarNombre(nombre);
    _errorApellido = validarApellido(apellido);
    _errorDni = validarDni(dni);
    _errorEmail = validarEmail(email);
    _errorContrasena = validarContrasena(contrasena);
    _errorConfirmacion = validarConfirmacion(confirmacion, contrasena);
    _errorGeneral = null;

    if (_errorNombre != null ||
        _errorApellido != null ||
        _errorDni != null ||
        _errorEmail != null ||
        _errorContrasena != null ||
        _errorConfirmacion != null) {
      notifyListeners();
      return false;
    }

    _cargando = true;
    notifyListeners();

    try {
      await _repositorio.registrarPaciente(
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        dni: dni.trim(),
        email: email.trim(),
        contrasena: contrasena,
      );
      _cargando = false;
      notifyListeners();
      return true;
    } on ExcepcionAutenticacion catch (e) {
      _cargando = false;
      final msg = e.mensaje;

      if (e.tipo == ErrorAutenticacion.emailDuplicado) {
        _errorEmail = msg ?? 'Ese correo ya está registrado.';
      } else if (e.tipo == ErrorAutenticacion.dniDuplicado) {
        _errorDni = msg ?? 'Ese DNI ya está registrado.';
      } else if (e.tipo == ErrorAutenticacion.datosInvalidos && e.campo != null) {
        final errorMsg = msg ?? 'Dato inválido.';
        switch (e.campo) {
          case 'nombre':
            _errorNombre = errorMsg;
            break;
          case 'apellido':
            _errorApellido = errorMsg;
            break;
          case 'dni':
            _errorDni = errorMsg;
            break;
          case 'email':
            _errorEmail = errorMsg;
            break;
          case 'contrasena':
            _errorContrasena = errorMsg;
            break;
          default:
            _errorGeneral = errorMsg;
            break;
        }
      } else if (e.tipo == ErrorAutenticacion.sinConexion) {
        _errorGeneral = 'Necesitás conexión con el servidor para crear la cuenta.';
      } else if (e.tipo == ErrorAutenticacion.errorServidor) {
        _errorGeneral = msg ?? 'El servidor tuvo un problema. Intentá de nuevo.';
      } else {
        _errorGeneral = msg ?? 'No pudimos registrar tu cuenta. Intentá de nuevo.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos registrar tu cuenta. Intentá de nuevo.';
      notifyListeners();
      return false;
    }
  }
}
