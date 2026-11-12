import 'package:flutter/foundation.dart';
import '../../datos/modelos/medico.dart';
import '../../datos/modelos/excepcionMedicos.dart';
import '../../datos/repositorios/repositorioMedicos.dart';

enum FiltroMedicos { todos, activos, inactivos }

class MedicosViewModel extends ChangeNotifier {
  final RepositorioMedicos _repositorio;

  MedicosViewModel(this._repositorio);

  bool _descartado = false;
  bool _cargando = false;
  String? _error;
  String? _errorAccion;

  List<Medico> _medicos = [];
  FiltroMedicos _filtro = FiltroMedicos.todos;
  String _textoBusqueda = '';
  int? _idCambiandoEstado;

  bool get cargando => _cargando;
  String? get error => _error;
  String? get errorAccion => _errorAccion;
  List<Medico> get medicos => _medicos;
  FiltroMedicos get filtro => _filtro;
  String get textoBusqueda => _textoBusqueda;
  int? get idCambiandoEstado => _idCambiandoEstado;

  bool get hayBusqueda => _textoBusqueda.trim().isNotEmpty;

  int get totalTodos => _medicos.length;
  int get totalActivos => _medicos.where((m) => m.activo).length;
  int get totalInactivos => _medicos.where((m) => !m.activo).length;

  List<Medico> get visibles {
    List<Medico> lista = _medicos;

    // Aplicar filtro de pestaña
    if (_filtro == FiltroMedicos.activos) {
      lista = lista.where((m) => m.activo).toList();
    } else if (_filtro == FiltroMedicos.inactivos) {
      lista = lista.where((m) => !m.activo).toList();
    }

    // Aplicar búsqueda normalizada (sin tildes, sin mayúsculas)
    if (hayBusqueda) {
      final busquedaNorm = _normalizar(_textoBusqueda);
      lista = lista.where((m) {
        final nombreNorm = _normalizar(m.nombreCompleto);
        final espNorm = _normalizar(m.especialidad.nombre);
        final matNorm = _normalizar(m.matricula ?? '');
        return nombreNorm.contains(busquedaNorm) ||
            espNorm.contains(busquedaNorm) ||
            matNorm.contains(busquedaNorm);
      }).toList();
    }

    return lista;
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

  String _normalizar(String texto) {
    const conTildes = 'ÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÄËÏÖÜäëïöüÂÊÎÔÛâêîôûÑñ';
    const sinTildes = 'AEIOUaeiouAEIOUaeiouAEIOUaeiouAEIOUaeiouNn';
    var resultado = texto.toLowerCase();
    for (int i = 0; i < conTildes.length; i++) {
      resultado = resultado.replaceAll(conTildes[i], sinTildes[i]);
    }
    return resultado;
  }

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _medicos = await _repositorio.obtenerMedicos(incluirInactivos: true);
      _cargando = false;
      notifyListeners();
    } on ExcepcionMedicos catch (e) {
      _cargando = false;
      if (e.tipo == ErrorMedicos.sinConexion) {
        _error = 'Necesitás conexión con el servidor para cargar los médicos.';
      } else if (e.tipo == ErrorMedicos.errorServidor) {
        _error = 'El servidor tuvo un problema. Intentá de nuevo.';
      } else {
        _error = 'No pudimos cargar los médicos. Intentá de nuevo.';
      }
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar los médicos. Intentá de nuevo.';
      notifyListeners();
    }
  }

  void cambiarFiltro(FiltroMedicos nuevoFiltro) {
    _filtro = nuevoFiltro;
    notifyListeners();
  }

  void buscar(String texto) {
    _textoBusqueda = texto;
    notifyListeners();
  }

  void limpiarBusqueda() {
    _textoBusqueda = '';
    notifyListeners();
  }

  Future<bool> cambiarEstado(Medico medico) async {
    _idCambiandoEstado = medico.id;
    _errorAccion = null;
    notifyListeners();

    try {
      final nuevoEstado = !medico.activo;
      final medicoActualizado = await _repositorio.cambiarEstadoMedico(medico.id, nuevoEstado);
      
      final index = _medicos.indexWhere((m) => m.id == medico.id);
      if (index != -1) {
        _medicos[index] = medicoActualizado;
      }

      _idCambiandoEstado = null;
      notifyListeners();
      return true;
    } on ExcepcionMedicos catch (e) {
      _idCambiandoEstado = null;
      if (e.tipo == ErrorMedicos.sinConexion) {
        _errorAccion = 'Necesitás conexión con el servidor para cambiar el estado.';
      } else {
        _errorAccion = e.mensajeServidor ?? 'No pudimos cambiar el estado del médico.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _idCambiandoEstado = null;
      _errorAccion = 'No pudimos cambiar el estado del médico.';
      notifyListeners();
      return false;
    }
  }
}
