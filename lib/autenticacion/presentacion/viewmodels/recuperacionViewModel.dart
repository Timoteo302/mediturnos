import 'package:flutter/foundation.dart';
import 'package:mediturnos/autenticacion/datos/modelos/solicitudRecuperacion.dart';
import 'package:mediturnos/autenticacion/datos/modelos/excepcionAutenticacion.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacion.dart';

enum PasoRecuperacion { solicitar, restablecer, listo }

class RecuperacionViewModel extends ChangeNotifier {
  final RepositorioAutenticacion _repositorio;

  RecuperacionViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;
  bool _porDni = false;
  PasoRecuperacion _paso = PasoRecuperacion.solicitar;

  SolicitudRecuperacion? _solicitud;
  String? _codigoDemostracion;

  String? _errorDato;
  String? _errorCodigo;
  String? _errorContrasena;
  String? _errorConfirmacion;
  String? _errorGeneral;

  bool get cargando => _cargando;
  bool get porDni => _porDni;
  PasoRecuperacion get paso => _paso;
  SolicitudRecuperacion? get solicitud => _solicitud;
  String? get codigoDemostracion => _codigoDemostracion;

  String? get errorDato => _errorDato;
  String? get errorCodigo => _errorCodigo;
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

  void cambiarMetodo(bool valor) {
    _porDni = valor;
    _errorDato = null;
    _errorGeneral = null;
    notifyListeners();
  }

  void volverASolicitar() {
    _paso = PasoRecuperacion.solicitar;
    _solicitud = null;
    _codigoDemostracion = null;
    _errorGeneral = null;
    notifyListeners();
  }

  String? validarDato(String? v) {
    if (v == null || v.trim().isEmpty) {
      return _porDni ? 'El DNI es obligatorio.' : 'El correo electrónico es obligatorio.';
    }
    final val = v.trim();
    if (_porDni) {
      final regex = RegExp(r'^\d{7,8}$');
      if (!regex.hasMatch(val)) return 'El DNI debe tener 7 u 8 números, sin puntos ni espacios.';
    } else {
      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!regex.hasMatch(val) || val.length > 150) return 'Ingresá un correo electrónico válido.';
    }
    return null;
  }

  String? validarCodigo(String? v) {
    if (v == null || v.trim().isEmpty) return 'El código es obligatorio.';
    if (v.trim().length != 6 || int.tryParse(v.trim()) == null) return 'El código debe tener exactamente 6 dígitos.';
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

  Future<void> solicitarCodigo(String dato) async {
    _errorDato = validarDato(dato);
    _errorGeneral = null;

    if (_errorDato != null) {
      notifyListeners();
      return;
    }

    _cargando = true;
    notifyListeners();

    try {
      final res = await _repositorio.solicitarRecuperacion(
        email: _porDni ? null : dato.trim(),
        dni: _porDni ? dato.trim() : null,
      );
      _solicitud = res;
      _codigoDemostracion = res.codigoDemostracion;
      _paso = PasoRecuperacion.restablecer;
      _cargando = false;
      notifyListeners();
    } on ExcepcionAutenticacion catch (e) {
      _cargando = false;
      if (e.tipo == ErrorAutenticacion.cuentaNoEncontrada) {
        _errorDato = _porDni ? 'No encontramos una cuenta con ese DNI.' : 'No encontramos una cuenta con ese correo.';
      } else if (e.tipo == ErrorAutenticacion.cuentaInactiva) {
        _errorGeneral = 'Tu cuenta está desactivada. Contactá a la clínica.';
      } else if (e.tipo == ErrorAutenticacion.sinConexion) {
        _errorGeneral = 'Necesitás conexión con el servidor para recuperar la contraseña.';
      } else {
        _errorGeneral = 'No pudimos procesar la solicitud. Intentá de nuevo.';
      }
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos procesar la solicitud. Intentá de nuevo.';
      notifyListeners();
    }
  }

    Future<bool> reenviarCodigo(String dato) async {
    await solicitarCodigo(dato);
    return _paso == PasoRecuperacion.restablecer;
  }

  Future<bool> restablecer({
    required String codigo,
    required String nuevaContrasena,
    required String confirmacion,
  }) async {
    _errorCodigo = validarCodigo(codigo);
    _errorContrasena = validarContrasena(nuevaContrasena);
    _errorConfirmacion = validarConfirmacion(confirmacion, nuevaContrasena);
    _errorGeneral = null;

    if (_errorCodigo != null || _errorContrasena != null || _errorConfirmacion != null) {
      notifyListeners();
      return false;
    }

    if (_solicitud == null) {
      _errorGeneral = 'La solicitud expiró. Volvé a solicitar un código.';
      _paso = PasoRecuperacion.solicitar;
      notifyListeners();
      return false;
    }

    _cargando = true;
    notifyListeners();

    try {
      await _repositorio.restablecerContrasena(
        idRecuperacion: _solicitud!.idRecuperacion,
        codigo: codigo.trim(),
        nuevaContrasena: nuevaContrasena,
      );
      _paso = PasoRecuperacion.listo;
      _cargando = false;
      notifyListeners();
      return true;
    } on ExcepcionAutenticacion catch (e) {
      _cargando = false;
      if (e.tipo == ErrorAutenticacion.codigoInvalido) {
        final intentos = e.intentosRestantes;
        _errorCodigo = intentos != null && intentos > 0
            ? 'El código es incorrecto. Te quedan $intentos intentos.'
            : 'El código es incorrecto.';
      } else if (e.tipo == ErrorAutenticacion.codigoVencido) {
        _errorGeneral = 'El código venció. Pedí uno nuevo.';
        _paso = PasoRecuperacion.solicitar;
      } else if (e.tipo == ErrorAutenticacion.demasiadosIntentos) {
        _errorGeneral = 'Demasiados intentos. Pedí un código nuevo.';
        _paso = PasoRecuperacion.solicitar;
      } else if (e.tipo == ErrorAutenticacion.solicitudNoEncontrada) {
        _errorGeneral = 'Solicitud no encontrada. Pedí un código nuevo.';
        _paso = PasoRecuperacion.solicitar;
      } else {
        _errorGeneral = 'No pudimos restablecer la contraseña. Intentá de nuevo.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos restablecer la contraseña. Intentá de nuevo.';
      notifyListeners();
      return false;
    }
  }
}
