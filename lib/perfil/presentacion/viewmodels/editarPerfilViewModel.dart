import 'package:flutter/foundation.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/componentes/comunes/validadorTelefono.dart';
import 'package:mediturnos/componentes/comunes/validadoresPersona.dart';
import '../../datos/modelos/excepcionPerfil.dart';
import '../../datos/repositorios/repositorioPerfil.dart';

// ViewModel para la pantalla de edición de perfil del usuario.
class EditarPerfilViewModel extends ChangeNotifier {
  final RepositorioPerfil _repositorio;

  EditarPerfilViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;

  String? _errorNombre;
  String? _errorApellido;
  String? _errorTelefono;
  String? _errorGeneral;

  bool get cargando => _cargando;
  String? get errorNombre => _errorNombre;
  String? get errorApellido => _errorApellido;
  String? get errorTelefono => _errorTelefono;
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

  // Limpia los errores acumulados cuando el usuario edita un campo.
  void limpiarError(String campo) {
    switch (campo) {
      case 'nombre':
        _errorNombre = null;
        break;
      case 'apellido':
        _errorApellido = null;
        break;
      case 'telefono':
        _errorTelefono = null;
        break;
    }
    _errorGeneral = null;
    notifyListeners();
  }

  // Valida los datos y llama al repositorio para guardar las modificaciones del perfil.
  Future<Usuario?> guardar({
    required Usuario usuario,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    _errorNombre = validarNombre(nombre);
    _errorApellido = validarApellido(apellido);
    _errorGeneral = null;

    final esPaciente = usuario.paciente != null;
    if (esPaciente) {
      _errorTelefono = validarTelefono(telefono);
    } else {
      _errorTelefono = null;
    }

    if (_errorNombre != null || _errorApellido != null || _errorTelefono != null) {
      notifyListeners();
      return null;
    }

    _cargando = true;
    notifyListeners();

    try {
      final actualizado = await _repositorio.actualizarPerfil(
        id: usuario.id,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        telefono: esPaciente ? telefono?.trim() : null,
      );
      _cargando = false;
      notifyListeners();
      return actualizado;
    } on ExcepcionPerfil catch (e) {
      _cargando = false;
      if (e.tipo == ErrorPerfil.sinConexion) {
        _errorGeneral = 'Necesitás conexión para guardar los cambios.';
      } else if (e.tipo == ErrorPerfil.datosInvalidos && e.campo != null) {
        final msg = e.mensaje ?? 'Dato inválido.';
        switch (e.campo) {
          case 'nombre':
            _errorNombre = msg;
            break;
          case 'apellido':
            _errorApellido = msg;
            break;
          case 'telefono':
            _errorTelefono = msg;
            break;
          default:
            _errorGeneral = msg;
            break;
        }
      } else {
        _errorGeneral = e.mensaje ?? 'No pudimos guardar los cambios. Intentá de nuevo.';
      }
      notifyListeners();
      return null;
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos guardar los cambios. Intentá de nuevo.';
      notifyListeners();
      return null;
    }
  }
}
