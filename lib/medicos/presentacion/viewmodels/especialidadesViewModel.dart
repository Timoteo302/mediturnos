import 'package:flutter/foundation.dart';
import '../../datos/modelos/especialidad.dart';
import '../../datos/modelos/excepcionMedicos.dart';
import '../../datos/repositorios/repositorioMedicos.dart';

enum FiltroEspecialidades { todas, activas, inactivas }

class EspecialidadesViewModel extends ChangeNotifier {
  final RepositorioMedicos _repositorio;

  EspecialidadesViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;
  bool _guardando = false;
  String? _error;
  String? _errorAccion;

  List<Especialidad> _especialidades = [];
  FiltroEspecialidades _filtro = FiltroEspecialidades.todas;
  int? _idProcesando;

  String? _errorNombre;
  String? _errorDescripcion;
  String? _errorGeneral;

  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get error => _error;
  String? get errorAccion => _errorAccion;
  List<Especialidad> get especialidades => _especialidades;
  FiltroEspecialidades get filtro => _filtro;
  int? get idProcesando => _idProcesando;

  String? get errorNombre => _errorNombre;
  String? get errorDescripcion => _errorDescripcion;
  String? get errorGeneral => _errorGeneral;

  int get totalTodas => _especialidades.length;
  int get totalActivas => _especialidades.where((e) => e.activo).length;
  int get totalInactivas => _especialidades.where((e) => !e.activo).length;

  List<Especialidad> get visibles {
    if (_filtro == FiltroEspecialidades.activas) {
      return _especialidades.where((e) => e.activo).toList();
    } else if (_filtro == FiltroEspecialidades.inactivas) {
      return _especialidades.where((e) => !e.activo).toList();
    }
    return _especialidades;
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

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _especialidades = await _repositorio.obtenerEspecialidades(incluirInactivas: true);
      _cargando = false;
      notifyListeners();
    } on ExcepcionMedicos catch (e) {
      _cargando = false;
      if (e.tipo == ErrorMedicos.sinConexion) {
        _error = 'Necesitás conexión con el servidor para cargar las especialidades.';
      } else {
        _error = e.mensajeServidor ?? 'No pudimos cargar las especialidades.';
      }
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar las especialidades.';
      notifyListeners();
    }
  }

  void cambiarFiltro(FiltroEspecialidades filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  void limpiarErroresFormulario() {
    _errorNombre = null;
    _errorDescripcion = null;
    _errorGeneral = null;
    notifyListeners();
  }

  String? validarNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresá el nombre de la especialidad.';
    final val = v.trim();
    if (val.length < 2 || val.length > 100) return 'El nombre debe tener entre 2 y 100 caracteres.';
    return null;
  }

  String? validarDescripcion(String? v) {
    if (v != null && v.trim().length > 255) return 'La descripción no puede superar los 255 caracteres.';
    return null;
  }

  Future<bool> guardar({int? id, required String nombre, String? descripcion}) async {
    _errorNombre = validarNombre(nombre);
    _errorDescripcion = validarDescripcion(descripcion);
    _errorGeneral = null;

    if (_errorNombre != null || _errorDescripcion != null) {
      notifyListeners();
      return false;
    }

    _guardando = true;
    notifyListeners();

    try {
      Especialidad espGuardada;
      if (id == null) {
        espGuardada = await _repositorio.crearEspecialidad(
          nombre: nombre.trim(),
          descripcion: descripcion?.trim(),
        );
        _especialidades.add(espGuardada);
      } else {
        espGuardada = await _repositorio.actualizarEspecialidad(
          id,
          nombre: nombre.trim(),
          descripcion: descripcion?.trim(),
        );
        final index = _especialidades.indexWhere((e) => e.id == id);
        if (index != -1) {
          _especialidades[index] = espGuardada;
        }
      }

      _guardando = false;
      notifyListeners();
      return true;
    } on ExcepcionMedicos catch (e) {
      _guardando = false;
      final msg = e.mensajeServidor;
      if (e.tipo == ErrorMedicos.especialidadDuplicada) {
        _errorNombre = msg ?? 'Ya existe una especialidad con ese nombre.';
      } else if (e.tipo == ErrorMedicos.datosInvalidos && e.campo != null) {
        final err = msg ?? 'Dato inválido.';
        if (e.campo == 'nombre') {
          _errorNombre = err;
        } else if (e.campo == 'descripcion') {
          _errorDescripcion = err;
        } else {
          _errorGeneral = err;
        }
      } else if (e.tipo == ErrorMedicos.sinConexion) {
        _errorGeneral = 'Necesitás conexión con el servidor para guardar la especialidad.';
      } else {
        _errorGeneral = msg ?? 'No pudimos guardar la especialidad.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _guardando = false;
      _errorGeneral = 'No pudimos guardar la especialidad.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarEstado(Especialidad especialidad) async {
    _idProcesando = especialidad.id;
    _errorAccion = null;
    notifyListeners();

    try {
      final nuevoEstado = !especialidad.activo;
      final espActualizada = await _repositorio.cambiarEstadoEspecialidad(especialidad.id, nuevoEstado);

      final index = _especialidades.indexWhere((e) => e.id == especialidad.id);
      if (index != -1) {
        _especialidades[index] = espActualizada;
      }

      _idProcesando = null;
      notifyListeners();
      return true;
    } on ExcepcionMedicos catch (e) {
      _idProcesando = null;
      if (e.tipo == ErrorMedicos.especialidadEnUso) {
        _errorAccion = 'No se puede desactivar: hay médicos activos con esta especialidad.';
      } else if (e.tipo == ErrorMedicos.sinConexion) {
        _errorAccion = 'Necesitás conexión con el servidor para cambiar el estado.';
      } else {
        _errorAccion = e.mensajeServidor ?? 'No pudimos cambiar el estado de la especialidad.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _idProcesando = null;
      _errorAccion = 'No pudimos cambiar el estado de la especialidad.';
      notifyListeners();
      return false;
    }
  }
}
