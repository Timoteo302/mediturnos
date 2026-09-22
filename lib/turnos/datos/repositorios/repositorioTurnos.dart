import '../modelos/turno.dart';

abstract class RepositorioTurnos {
  Future<List<Turno>> obtenerTurnos();

  Future<void> guardarTurno(Turno turno);

  Future<void> modificarTurno(Turno turno);

  Future<void> eliminarTurno(int id);
}


//Es como una interfaz en Java. Estamos diciendo:
//odo repositorio de turnos tiene que saber obtener, guardar, modificar y eliminar turnos



