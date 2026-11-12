import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/medicos/datos/modelos/especialidad.dart';
import 'package:mediturnos/medicos/datos/modelos/horarioAtencion.dart';
import 'package:mediturnos/medicos/datos/modelos/excepcionMedicos.dart';
import 'package:mediturnos/medicos/datos/repositorios/repositorioMedicos.dart';
import 'package:mediturnos/medicos/presentacion/viewmodels/medicosViewModel.dart';
import 'package:mediturnos/medicos/presentacion/viewmodels/formularioMedicoViewModel.dart';
import 'package:mediturnos/medicos/presentacion/viewmodels/especialidadesViewModel.dart';

class RepositorioMedicosFalso implements RepositorioMedicos {
  List<Medico> medicos = [
    Medico(id: 1, nombre: 'Juan', apellido: 'Pérez', matricula: '1234', activo: true, especialidad: Especialidad(id: 1, nombre: 'Cardiología', activo: true)),
    Medico(id: 2, nombre: 'María', apellido: 'Gómez', matricula: '5678', activo: false, especialidad: Especialidad(id: 2, nombre: 'Pediatría', activo: true)),
  ];

  List<Especialidad> especialidades = [
    Especialidad(id: 1, nombre: 'Cardiología', descripcion: 'Corazón', activo: true),
    Especialidad(id: 2, nombre: 'Pediatría', descripcion: 'Niños', activo: true),
  ];

  @override
  Future<List<Medico>> obtenerMedicos({bool incluirInactivos = false}) async {
    if (incluirInactivos) return medicos;
    return medicos.where((m) => m.activo).toList();
  }

  @override
  Future<Medico> crearMedico({required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo}) async {
    if (matricula == '1234') {
      throw ExcepcionMedicos(ErrorMedicos.matriculaDuplicada, campo: 'matricula', mensajeServidor: 'Matrícula duplicada');
    }
    final esp = especialidades.firstWhere((e) => e.id == especialidadId);
    final nuevo = Medico(id: 3, nombre: nombre, apellido: apellido, matricula: matricula, activo: activo, especialidad: esp);
    medicos.add(nuevo);
    return nuevo;
  }

  @override
  Future<Medico> actualizarMedico(int id, {required String nombre, required String apellido, required int especialidadId, required String matricula, required bool activo}) async {
    final esp = especialidades.firstWhere((e) => e.id == especialidadId);
    final index = medicos.indexWhere((m) => m.id == id);
    medicos[index] = Medico(id: id, nombre: nombre, apellido: apellido, matricula: matricula, activo: activo, especialidad: esp);
    return medicos[index];
  }

  @override
  Future<Medico> cambiarEstadoMedico(int id, bool activo) async {
    final index = medicos.indexWhere((m) => m.id == id);
    final m = medicos[index];
    medicos[index] = Medico(id: m.id, nombre: m.nombre, apellido: m.apellido, matricula: m.matricula, activo: activo, especialidad: m.especialidad);
    return medicos[index];
  }

  @override
  Future<List<Especialidad>> obtenerEspecialidades({bool incluirInactivas = false}) async => especialidades;

  @override
  Future<Especialidad> crearEspecialidad({required String nombre, String? descripcion}) async {
    if (nombre == 'Cardiología') {
      throw ExcepcionMedicos(ErrorMedicos.especialidadDuplicada, campo: 'nombre', mensajeServidor: 'Especialidad duplicada');
    }
    final nueva = Especialidad(id: 3, nombre: nombre, descripcion: descripcion, activo: true);
    especialidades.add(nueva);
    return nueva;
  }

  @override
  Future<Especialidad> actualizarEspecialidad(int id, {required String nombre, String? descripcion}) async {
    final index = especialidades.indexWhere((e) => e.id == id);
    especialidades[index] = Especialidad(id: id, nombre: nombre, descripcion: descripcion, activo: especialidades[index].activo);
    return especialidades[index];
  }

  @override
  Future<Especialidad> cambiarEstadoEspecialidad(int id, bool activo) async {
    if (!activo && id == 1) {
      throw ExcepcionMedicos(ErrorMedicos.especialidadEnUso, mensajeServidor: 'En uso');
    }
    final index = especialidades.indexWhere((e) => e.id == id);
    final e = especialidades[index];
    especialidades[index] = Especialidad(id: e.id, nombre: e.nombre, descripcion: e.descripcion, activo: activo);
    return especialidades[index];
  }

  @override
  Future<List<HorarioAtencion>> obtenerHorarios(int medicoId) async => [];

  @override
  Future<List<HorarioAtencion>> guardarHorarios(int medicoId, List<HorarioAtencion> horarios) async => horarios;
}

void main() {
  group('ViewModels de Médicos Tests', () {
    test('MedicosViewModel carga, filtros y búsqueda sin tildes', () async {
      final repo = RepositorioMedicosFalso();
      final vm = MedicosViewModel(repo);

      await vm.cargar();
      expect(vm.totalTodos, 2);
      expect(vm.totalActivos, 1);
      expect(vm.totalInactivos, 1);

      vm.buscar('cardiologia');
      expect(vm.visibles.length, 1);
      expect(vm.visibles[0].nombre, 'Juan');
    });

    test('FormularioMedicoViewModel valida y maneja matrícula duplicada', () async {
      final repo = RepositorioMedicosFalso();
      final vm = FormularioMedicoViewModel(repo, null);

      await Future.delayed(const Duration(milliseconds: 50));
      vm.seleccionarEspecialidad(1);

      expect(vm.validarMatricula('ab'), 'La matrícula debe tener entre 3 y 10 números.');
      expect(vm.validarMatricula('1234'), isNull);

      final resultado = await vm.guardar(nombre: 'Ana', apellido: 'Ruiz', matricula: '1234');
      expect(resultado, isNull);
      expect(vm.errorMatricula, 'Matrícula duplicada');
    });

    test('EspecialidadesViewModel validaciones y especialidad en uso', () async {
      final repo = RepositorioMedicosFalso();
      final vm = EspecialidadesViewModel(repo);

      await vm.cargar();
      expect(vm.totalTodas, 2);

      final res = await vm.cambiarEstado(vm.especialidades[0]);
      expect(res, false);
      expect(vm.errorAccion, 'No se puede desactivar: hay médicos activos con esta especialidad.');
    });
  });
}
