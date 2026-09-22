import '../datos/modelos/turno.dart';
import '../datos/repositorios/repositorioTurnos.dart';

class CasosDeUsoTurnos {
  final RepositorioTurnos repositorio;

  CasosDeUsoTurnos(this.repositorio);

  // Obtiene todos los turnos guardados.
  Future<List<Turno>> obtenerTurnos() {
    return repositorio.obtenerTurnos();
  }

  // Guarda un nuevo turno.
  Future<void> registrarTurno(Turno turno) {
    return repositorio.guardarTurno(turno);
  }

  // Actualiza los datos de un turno existente.
  Future<void> modificarTurno(Turno turno) {
    return repositorio.modificarTurno(turno);
  }

  // Elimina un turno por su identificador.
  Future<void> cancelarTurno(int id) {
    return repositorio.eliminarTurno(id);
  }

  // Sincroniza los turnos locales con el servidor.
  Future<void> sincronizarTurnos() {
    // Más adelante agregaremos la lógica de sincronización.
    return Future.value();
  }
}

/*
CasosDeUsoTurnos
Es la parte de la lógica que reúne las acciones que se pueden realizar con los turnos.

obtenerTurnos() → pide al repositorio la lista de turnos.
registrarTurno() → recibe un turno nuevo y pide guardarlo.
modificarTurno() → recibe un turno modificado y pide actualizarlo.
cancelarTurno() → recibe el ID y pide eliminar/cancelar el turno.
sincronizarTurnos() → más adelante se encargará de enviar los datos locales al servidor cuando vuelva Internet.


FLUJO:
PANTALLA
   ↓
CasosDeUsoTurnos
   ↓
RepositorioTurnos
   ↓
SQLite / API
*/