import 'package:flutter/foundation.dart';
import '../../datos/modelos/medico.dart';
import '../../datos/modelos/especialidad.dart';
import '../../datos/modelos/excepcionMedicos.dart';
import '../../datos/repositorios/repositorioMedicos.dart';

class FormularioMedicoViewModel extends ChangeNotifier {
  final RepositorioMedicos _repositorio;
  final Medico? _medicoAEditar;

  FormularioMedicoViewModel(this._repositorio, this._medicoAEditar) {
    _inicializar();
  }

  bool _descartado = false;
  bool _cargando = false;
  bool _guardando = false;

  List<Especialidad> _especialidades = [];
  int? _especialidadId;
  bool _activo = true;

  String? _errorNombre;
  String? _errorApellido;
  String? _errorMatricula;
  String? _errorEspecialidad;
  String? _errorGeneral;

  bool get cargando => _cargando;
  bool get guardando => _guardando;
  List<Especialidad> get especialidades => _especialidades;
  int? get especialidadId => _especialidadId;
  bool get activo => _activo;

  String? get errorNombre => _errorNombre;
  String? get errorApellido => _errorApellido;
  String? get errorMatricula => _errorMatricula;
  String? get errorEspecialidad => _errorEspecialidad;
  String? get errorGeneral => _errorGeneral;

  bool get esEdicion => _medicoAEditar != null;

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

  Future<void> _inicializar() async {
    _cargando = true;
    notifyListeners();

    try {
      final listaEsp = await _repositorio.obtenerEspecialidades(incluirInactivas: false);
      _especialidades = listaEsp;

      if (_medicoAEditar != null) {
        _especialidadId = _medicoAEditar.especialidad.id;
        _activo = _medicoAEditar.activo;

        // Si la especialidad del médico a editar no está entre las activas, agregarla para que el desplegable no falle
        if (!_especialidades.any((e) => e.id == _especialidadId)) {
          _especialidades.add(_medicoAEditar.especialidad);
        }
      }

      _cargando = false;
      notifyListeners();
    } on ExcepcionMedicos catch (e) {
      _cargando = false;
      _errorGeneral = e.mensajeServidor ?? 'No pudimos cargar las especialidades.';
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _errorGeneral = 'No pudimos cargar las especialidades.';
      notifyListeners();
    }
  }

  void seleccionarEspecialidad(int? id) {
    _especialidadId = id;
    _errorEspecialidad = null;
    notifyListeners();
  }

  void cambiarActivo(bool valor) {
    _activo = valor;
    notifyListeners();
  }

  void limpiarError(String campo) {
    switch (campo) {
      case 'nombre':
        _errorNombre = null;
        break;
      case 'apellido':
        _errorApellido = null;
        break;
      case 'matricula':
        _errorMatricula = null;
        break;
      case 'especialidad':
        _errorEspecialidad = null;
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

  String? validarMatricula(String? v) {
    if (v == null || v.trim().isEmpty) return 'La matrícula es obligatoria.';
    final val = v.trim();
    final regex = RegExp(r'^\d{3,10}$');
    if (!regex.hasMatch(val)) return 'La matrícula debe tener entre 3 y 10 números.';
    return null;
  }

  String? validarEspecialidad() {
    if (_especialidadId == null) return 'Seleccioná una especialidad.';
    return null;
  }

  Future<Medico?> guardar({
    required String nombre,
    required String apellido,
    required String matricula,
  }) async {
    _errorNombre = validarNombre(nombre);
    _errorApellido = validarApellido(apellido);
    _errorMatricula = validarMatricula(matricula);
    _errorEspecialidad = validarEspecialidad();
    _errorGeneral = null;

    if (_errorNombre != null ||
        _errorApellido != null ||
        _errorMatricula != null ||
        _errorEspecialidad != null) {
      notifyListeners();
      return null;
    }

    _guardando = true;
    notifyListeners();

    try {
      Medico medicoGuardado;
      if (_medicoAEditar == null) {
        medicoGuardado = await _repositorio.crearMedico(
          nombre: nombre.trim(),
          apellido: apellido.trim(),
          especialidadId: _especialidadId!,
          matricula: matricula.trim(),
          activo: _activo,
        );
      } else {
        medicoGuardado = await _repositorio.actualizarMedico(
          _medicoAEditar.id,
          nombre: nombre.trim(),
          apellido: apellido.trim(),
          especialidadId: _especialidadId!,
          matricula: matricula.trim(),
          activo: _activo,
        );
      }

      _guardando = false;
      notifyListeners();
      return medicoGuardado;
    } on ExcepcionMedicos catch (e) {
      _guardando = false;
      final msg = e.mensajeServidor;
      if (e.tipo == ErrorMedicos.matriculaDuplicada) {
        _errorMatricula = msg ?? 'Ya existe un médico con esa matrícula.';
      } else if (e.tipo == ErrorMedicos.datosInvalidos && e.campo != null) {
        final err = msg ?? 'Dato inválido.';
        switch (e.campo) {
          case 'nombre':
            _errorNombre = err;
            break;
          case 'apellido':
            _errorApellido = err;
            break;
          case 'matricula':
            _errorMatricula = err;
            break;
          case 'especialidadId':
          case 'especialidad':
            _errorEspecialidad = err;
            break;
          default:
            _errorGeneral = err;
            break;
        }
      } else if (e.tipo == ErrorMedicos.medicoNoEncontrado) {
        _errorGeneral = 'El médico ya no existe. Volvé a la lista y actualizá.';
      } else if (e.tipo == ErrorMedicos.sinConexion) {
        _errorGeneral = 'Necesitás conexión con el servidor para guardar el médico.';
      } else {
        _errorGeneral = msg ?? 'No pudimos guardar el médico.';
      }
      notifyListeners();
      return null;
    } catch (_) {
      _guardando = false;
      _errorGeneral = 'No pudimos guardar el médico.';
      notifyListeners();
      return null;
    }
  }
}
