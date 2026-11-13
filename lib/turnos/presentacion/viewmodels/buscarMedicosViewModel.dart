import 'package:flutter/foundation.dart';
import '../../../medicos/datos/modelos/medico.dart';
import '../../../medicos/datos/modelos/especialidad.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';

/// ViewModel para gestionar la búsqueda y filtrado de médicos por especialidad.
class BuscarMedicosViewModel extends ChangeNotifier {
  final RepositorioMedicos _repositorioMedicos;

  BuscarMedicosViewModel(this._repositorioMedicos) {
    cargar();
  }

  bool _descartado = false;
  bool _cargando = false;
  String? _error;

  List<Medico> _medicos = [];
  List<Especialidad> _especialidades = [];
  int? _especialidadIdSeleccionada;
  String _textoBusqueda = '';

  bool get cargando => _cargando;
  String? get error => _error;
  List<Especialidad> get especialidades => _especialidades;
  int? get especialidadIdSeleccionada => _especialidadIdSeleccionada;
  String get textoBusqueda => _textoBusqueda;

  List<Medico> get visibles {
    List<Medico> lista = _medicos.where((m) => m.activo).toList();

    if (_especialidadIdSeleccionada != null) {
      lista = lista.where((m) => m.especialidad.id == _especialidadIdSeleccionada).toList();
    }

    if (_textoBusqueda.trim().isNotEmpty) {
      final busquedaNorm = _normalizar(_textoBusqueda);
      lista = lista.where((m) {
        final nombreNorm = _normalizar(m.nombreCompleto);
        final espNorm = _normalizar(m.especialidad.nombre);
        return nombreNorm.contains(busquedaNorm) || espNorm.contains(busquedaNorm);
      }).toList();
    }

    return lista;
  }

  int get cantidad => visibles.length;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
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

  /// Carga médicos y especialidades activas.
  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _repositorioMedicos.obtenerMedicos(incluirInactivos: false),
        _repositorioMedicos.obtenerEspecialidades(incluirInactivas: false),
      ]);

      _medicos = resultados[0] as List<Medico>;
      _especialidades = resultados[1] as List<Especialidad>;

      _cargando = false;
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar los especialistas. Intentá de nuevo.';
      notifyListeners();
    }
  }

  void seleccionarEspecialidad(int? id) {
    _especialidadIdSeleccionada = id;
    notifyListeners();
  }

  void buscar(String texto) {
    _textoBusqueda = texto;
    notifyListeners();
  }
}
