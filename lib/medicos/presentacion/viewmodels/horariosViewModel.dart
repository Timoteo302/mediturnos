import 'package:flutter/foundation.dart';
import '../../datos/modelos/medico.dart';
import '../../datos/modelos/horarioAtencion.dart';
import '../../datos/modelos/franjaHoraria.dart';
import '../../datos/modelos/excepcionMedicos.dart';
import '../../datos/repositorios/repositorioMedicos.dart';

class HorariosViewModel extends ChangeNotifier {
  final RepositorioMedicos _repositorio;
  final Medico? _medicoInicial;

  HorariosViewModel(this._repositorio, this._medicoInicial) {
    _inicializar();
  }

  bool _descartado = false;
  bool _cargando = false;
  bool _guardando = false;
  String? _error;
  String? _errorAccion;

  Medico? _medicoSeleccionado;
  List<Medico> _medicosActivos = [];
  Set<int> _diasActivos = {};
  List<FranjaHoraria> _franjas = [];
  int _duracionMinutos = 30;
  bool _agendaNoUniforme = false;

  final List<int> _opcionesDuracionBase = [15, 20, 30, 45, 60];
  List<int> _opcionesDuracion = [15, 20, 30, 45, 60];

  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get error => _error;
  String? get errorAccion => _errorAccion;

  Medico? get medicoSeleccionado => _medicoSeleccionado;
  List<Medico> get medicosActivos => _medicosActivos;
  Set<int> get diasActivos => _diasActivos;
  List<FranjaHoraria> get franjas => _franjas;
  int get duracionMinutos => _duracionMinutos;
  bool get agendaNoUniforme => _agendaNoUniforme;
  List<int> get opcionesDuracion => _opcionesDuracion;

  int get cantidadDiasActivos => _diasActivos.length;
  int get cantidadFranjasActivas => _franjas.length;

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
    _error = null;
    notifyListeners();

    try {
      if (_medicoInicial != null) {
        _medicoSeleccionado = _medicoInicial;
        await cargarAgenda(_medicoInicial!.id);
      } else {
        _medicosActivos = await _repositorio.obtenerMedicos(incluirInactivos: false);
      }
      _cargando = false;
      notifyListeners();
    } on ExcepcionMedicos catch (e) {
      _cargando = false;
      _error = e.mensajeServidor ?? 'No pudimos cargar la información de horarios.';
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar la información de horarios.';
      notifyListeners();
    }
  }

  Future<void> seleccionarMedico(Medico medico) async {
    _medicoSeleccionado = medico;
    await cargarAgenda(medico.id);
  }

  Future<void> cargarAgenda(int medicoId) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final horarios = await _repositorio.obtenerHorarios(medicoId);
      
      _diasActivos.clear();
      _franjas.clear();
      _agendaNoUniforme = false;

      if (horarios.isNotEmpty) {
        _duracionMinutos = horarios.first.duracionTurno;
        if (!_opcionesDuracionBase.contains(_duracionMinutos)) {
          if (!_opcionesDuracion.contains(_duracionMinutos)) {
            _opcionesDuracion.add(_duracionMinutos);
            _opcionesDuracion.sort();
          }
        }

        for (var h in horarios) {
          _diasActivos.add(h.diaSemana);
        }

        Map<int, List<FranjaHoraria>> franjasPorDia = {};
        for (var dia in _diasActivos) {
          final horariosDia = horarios.where((h) => h.diaSemana == dia).toList();
          final listaFranjasDia = horariosDia.map((h) {
            return FranjaHoraria(
              inicioMin: FranjaHoraria.horaMinutosAEntero(h.horaInicio),
              finMin: FranjaHoraria.horaMinutosAEntero(h.horaFin),
            );
          }).toList();
          
          listaFranjasDia.sort((a, b) => a.inicioMin.compareTo(b.inicioMin));
          franjasPorDia[dia] = listaFranjasDia;
        }

        if (franjasPorDia.isNotEmpty) {
          final primerDia = _diasActivos.first;
          _franjas = franjasPorDia[primerDia]!;

          for (var dia in _diasActivos) {
            final fDia = franjasPorDia[dia]!;
            if (fDia.length != _franjas.length) {
              _agendaNoUniforme = true;
            } else {
              for (int i = 0; i < _franjas.length; i++) {
                if (_franjas[i].inicioMin != fDia[i].inicioMin ||
                    _franjas[i].finMin != fDia[i].finMin) {
                  _agendaNoUniforme = true;
                }
              }
            }
          }

          for (var h in horarios) {
            if (h.duracionTurno != _duracionMinutos) {
              _agendaNoUniforme = true;
            }
          }
        }
      } else {
        _duracionMinutos = 30;
      }

      _cargando = false;
      notifyListeners();
    } on ExcepcionMedicos catch (e) {
      _cargando = false;
      _error = e.mensajeServidor ?? 'No pudimos cargar la agenda del médico.';
      notifyListeners();
    } catch (_) {
      _cargando = false;
      _error = 'No pudimos cargar la agenda del médico.';
      notifyListeners();
    }
  }

  void alternarDia(int diaSemana) {
    if (_diasActivos.contains(diaSemana)) {
      _diasActivos.remove(diaSemana);
    } else {
      _diasActivos.add(diaSemana);
    }
    notifyListeners();
  }

  void cambiarDuracion(int duracion) {
    _duracionMinutos = duracion;
    notifyListeners();
  }

  String? _validarFranja(int inicioMin, int finMin, {int? indiceExcluir}) {
    if (inicioMin >= finMin) {
      return 'La hora de inicio debe ser anterior a la de fin.';
    }
    int duracionFranja = finMin - inicioMin;
    if (duracionFranja < _duracionMinutos) {
      return 'La franja debe durar al menos $_duracionMinutos minutos.';
    }

    for (int i = 0; i < _franjas.length; i++) {
      if (indiceExcluir != null && i == indiceExcluir) continue;
      final f = _franjas[i];
      if (inicioMin < f.finMin && finMin > f.inicioMin) {
        return 'Esa franja se superpone con otra.';
      }
    }
    return null;
  }

  String? agregarFranja(int inicioMin, int finMin) {
    final errorValidacion = _validarFranja(inicioMin, finMin);
    if (errorValidacion != null) return errorValidacion;

    _franjas.add(FranjaHoraria(inicioMin: inicioMin, finMin: finMin));
    _franjas.sort((a, b) => a.inicioMin.compareTo(b.inicioMin));
    notifyListeners();
    return null;
  }

  String? editarFranja(int indice, int inicioMin, int finMin) {
    if (indice < 0 || indice >= _franjas.length) return 'Franja no encontrada.';
    final errorValidacion = _validarFranja(inicioMin, finMin, indiceExcluir: indice);
    if (errorValidacion != null) return errorValidacion;

    _franjas[indice] = FranjaHoraria(inicioMin: inicioMin, finMin: finMin);
    _franjas.sort((a, b) => a.inicioMin.compareTo(b.inicioMin));
    notifyListeners();
    return null;
  }

  void eliminarFranja(int indice) {
    if (indice >= 0 && indice < _franjas.length) {
      _franjas.removeAt(indice);
      notifyListeners();
    }
  }

  Future<bool> guardar() async {
    if (_medicoSeleccionado == null) return false;

    if (_diasActivos.isNotEmpty && _franjas.isEmpty) {
      _errorAccion = 'Agregá al menos una franja horaria.';
      notifyListeners();
      return false;
    }
    if (_franjas.isNotEmpty && _diasActivos.isEmpty) {
      _errorAccion = 'Elegí al menos un día de atención.';
      notifyListeners();
      return false;
    }

    _guardando = true;
    _errorAccion = null;
    notifyListeners();

    try {
      List<HorarioAtencion> listaHorarios = [];
      for (var dia in _diasActivos) {
        for (var f in _franjas) {
          listaHorarios.add(HorarioAtencion(
            diaSemana: dia,
            horaInicio: FranjaHoraria.enteroAHoraMinutos(f.inicioMin),
            horaFin: FranjaHoraria.enteroAHoraMinutos(f.finMin),
            duracionTurno: _duracionMinutos,
            activo: true,
          ));
        }
      }

      await _repositorio.guardarHorarios(_medicoSeleccionado!.id, listaHorarios);

      _guardando = false;
      notifyListeners();
      return true;
    } on ExcepcionMedicos catch (e) {
      _guardando = false;
      if (e.tipo == ErrorMedicos.sinConexion) {
        _errorAccion = 'Necesitás conexión con el servidor para guardar la agenda.';
      } else {
        _errorAccion = e.mensajeServidor ?? 'No pudimos guardar la agenda.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      _guardando = false;
      _errorAccion = 'No pudimos guardar la agenda.';
      notifyListeners();
      return false;
    }
  }
}
