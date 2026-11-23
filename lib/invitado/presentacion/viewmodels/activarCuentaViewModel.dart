import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/invitado/datos/modelos/excepcionInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitado.dart';

// ViewModel para gestionar la activación de cuenta de invitado y la cuenta regresiva de reenvío.
class ActivarCuentaViewModel extends ChangeNotifier {
  final RepositorioInvitado _repositorio;

  ActivarCuentaViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;
  int _segundosRestantes = 0;
  Timer? _timerReenvio;

  String? _errorCodigo;
  String? _errorContrasena;
  String? _errorRepetir;
  String? _errorGeneral;

  bool get cargando => _cargando;
  int get segundosRestantes => _segundosRestantes;
  bool get reenvioBloqueado => _segundosRestantes > 0;

  String? get errorCodigo => _errorCodigo;
  String? get errorContrasena => _errorContrasena;
  String? get errorRepetir => _errorRepetir;
  String? get errorGeneral => _errorGeneral;

  @override
  void dispose() {
    _descartado = true;
    _timerReenvio?.cancel();
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
      case 'codigo':
        _errorCodigo = null;
        break;
      case 'contrasena':
        _errorContrasena = null;
        break;
      case 'repetir':
        _errorRepetir = null;
        break;
    }
    _errorGeneral = null;
    notifyListeners();
  }

  String? validarCodigo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresá el código de 6 dígitos.';
    final val = v.trim();
    if (val.length != 6 || int.tryParse(val) == null) return 'El código debe tener 6 números.';
    return null;
  }

  String? validarContrasena(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es obligatoria.';
    if (v.length < 8 || v.length > 72) return 'La contraseña debe tener entre 8 y 72 caracteres.';
    return null;
  }

  String? validarRepetir(String? v, String pass) {
    if (v == null || v.isEmpty) return 'Confirmá tu contraseña.';
    if (v != pass) return 'Las contraseñas no coinciden.';
    return null;
  }

  // Inicia la cuenta regresiva de 60 segundos para bloquear reenvíos continuos.
  void _iniciarCuentaRegresiva() {
    _segundosRestantes = 60;
    notifyListeners();
    _timerReenvio?.cancel();
    _timerReenvio = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        _segundosRestantes--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Solicita un nuevo código de activación al servidor.
  Future<Map<String, dynamic>?> reenviar(String email) async {
    if (reenvioBloqueado) return null;

    _cargando = true;
    _errorGeneral = null;
    notifyListeners();

    try {
      final res = await _repositorio.reenviarActivacion(email: email.trim());
      _cargando = false;
      _iniciarCuentaRegresiva();
      notifyListeners();
      return res;
    } on ExcepcionInvitado catch (e) {
      _cargando = false;
      if (e.tipo == TipoErrorInvitado.esperaParaReenviar) {
        _errorGeneral = e.mensaje ?? 'Esperá un momento antes de solicitar otro código.';
      } else if (e.tipo == TipoErrorInvitado.activacionNoEncontrada) {
        _errorGeneral = e.mensaje ?? 'No hay una cuenta pendiente de activar con ese correo.';
      } else if (e.tipo == TipoErrorInvitado.sinConexion) {
        _errorGeneral = 'Necesitás conexión para solicitar el código.';
      } else {
        _errorGeneral = e.mensaje ?? 'No pudimos reenviar el código.';
      }
      notifyListeners();
      return null;
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos reenviar el código.';
      notifyListeners();
      return null;
    }
  }

  // Envía la confirmación con el código y crea la contraseña de la cuenta.
  Future<Usuario?> confirmar({
    required String email,
    required String codigo,
    required String contrasena,
    required String repetir,
  }) async {
    _errorCodigo = validarCodigo(codigo);
    _errorContrasena = validarContrasena(contrasena);
    _errorRepetir = validarRepetir(repetir, contrasena);
    _errorGeneral = null;

    if (_errorCodigo != null || _errorContrasena != null || _errorRepetir != null) {
      notifyListeners();
      return null;
    }

    _cargando = true;
    notifyListeners();

    try {
      final jsonMap = await _repositorio.confirmarActivacion(
        email: email.trim(),
        codigo: codigo.trim(),
        contrasena: contrasena,
      );

      final usuario = Usuario.fromJson(jsonMap);
      _cargando = false;
      notifyListeners();
      return usuario;
    } on ExcepcionInvitado catch (e) {
      _cargando = false;
      switch (e.tipo) {
        case TipoErrorInvitado.codigoInvalido:
          _errorCodigo = 'El código no es correcto.';
          break;
        case TipoErrorInvitado.codigoVencido:
          _errorCodigo = 'El código venció. Pedí uno nuevo.';
          break;
        case TipoErrorInvitado.demasiadosIntentos:
          _errorGeneral = 'Hiciste demasiados intentos. Pedí un código nuevo.';
          break;
        case TipoErrorInvitado.activacionNoEncontrada:
          _errorGeneral = e.mensaje ?? 'No hay una cuenta pendiente de activar con ese correo.';
          break;
        case TipoErrorInvitado.sinConexion:
          _errorGeneral = 'Necesitás conexión para activar tu cuenta.';
          break;
        default:
          _errorGeneral = e.mensaje ?? 'No pudimos activar tu cuenta. Intentá de nuevo.';
          break;
      }
      notifyListeners();
      return null;
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos activar tu cuenta. Intentá de nuevo.';
      notifyListeners();
      return null;
    }
  }
}
