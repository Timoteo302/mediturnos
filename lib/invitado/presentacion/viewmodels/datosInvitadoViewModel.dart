import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:mediturnos/componentes/comunes/validadorTelefono.dart';
import 'package:mediturnos/componentes/comunes/validadoresPersona.dart';
import 'package:mediturnos/configuracion/configuracionServidor.dart';
import 'package:mediturnos/invitado/datos/modelos/resultadoReservaInvitado.dart';
import 'package:mediturnos/invitado/datos/modelos/excepcionInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitado.dart';

// ViewModel para gestionar los datos del formulario de reserva en modo invitado y las validaciones de campos.
class DatosInvitadoViewModel extends ChangeNotifier {
  final RepositorioInvitado _repositorio;

  DatosInvitadoViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;
  String? _errorNombre;
  String? _errorApellido;
  String? _errorDni;
  String? _errorTelefono;
  String? _errorEmail;
  String? _errorGeneral;

  bool get cargando => _cargando;
  String? get errorNombre => _errorNombre;
  String? get errorApellido => _errorApellido;
  String? get errorDni => _errorDni;
  String? get errorTelefono => _errorTelefono;
  String? get errorEmail => _errorEmail;
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
      case 'telefono':
        _errorTelefono = null;
        break;
      case 'email':
        _errorEmail = null;
        break;
    }
    _errorGeneral = null;
    notifyListeners();
  }

  String? validarDni(String? v) {
    if (v == null || v.trim().isEmpty) return 'El DNI es obligatorio.';
    final val = v.trim();
    final regex = RegExp(r'^[1-9]\d{6,7}$');
    if (!regex.hasMatch(val)) return 'El DNI debe tener 7 u 8 números, sin puntos, y no puede empezar con 0.';
    return null;
  }

  String? validarEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo electrónico es obligatorio.';
    final val = v.trim().toLowerCase();
    final regex = RegExp(ConfiguracionServidor.regexEmail);
    if (!regex.hasMatch(val) || val.length > 150) return 'Ingresá un correo electrónico válido.';
    return null;
  }

  // Valida los datos e intenta reservar llamando a la API de invitados.
  Future<ResultadoReservaInvitado?> reservar({
    required String nombre,
    required String apellido,
    required String dni,
    required String telefono,
    required String email,
    required int medicoId,
    required DateTime fecha,
    required String hora,
  }) async {
    _errorNombre = validarNombre(nombre);
    _errorApellido = validarApellido(apellido);
    _errorDni = validarDni(dni);
    _errorTelefono = validarTelefono(telefono);
    _errorEmail = validarEmail(email);
    _errorGeneral = null;

    if (_errorNombre != null ||
        _errorApellido != null ||
        _errorDni != null ||
        _errorTelefono != null ||
        _errorEmail != null) {
      notifyListeners();
      return null;
    }

    _cargando = true;
    notifyListeners();

    try {
      final claveSolicitud = const Uuid().v4();

      final resultado = await _repositorio.reservarComoInvitado(
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        dni: dni.trim(),
        telefono: telefono.trim(),
        email: email.trim(),
        medicoId: medicoId,
        fecha: fecha,
        hora: hora,
        claveSolicitud: claveSolicitud,
      );

      _cargando = false;
      notifyListeners();
      return resultado;
    } on ExcepcionInvitado catch (e) {
      _cargando = false;
      if (e.tipo == TipoErrorInvitado.datosInvalidos && e.campo != null) {
        final errorMsg = e.mensaje ?? 'Dato inválido.';
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
          case 'telefono':
            _errorTelefono = errorMsg;
            break;
          case 'email':
            _errorEmail = errorMsg;
            break;
          default:
            _errorGeneral = errorMsg;
            break;
        }
      } else {
        rethrow;
      }
      notifyListeners();
      return null;
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos registrar la reserva. Intentá de nuevo.';
      notifyListeners();
      return null;
    }
  }
}
