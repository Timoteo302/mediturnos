import '../datos/modelos/turno.dart';
import '../datos/repositorios/repositorioTurnos.dart';

class ServicioSincronizacion {
  // Repositorio que permite acceder a los turnos guardados localmente.
  final RepositorioTurnos repositorio;

  ServicioSincronizacion(this.repositorio);

  // Indica si actualmente estamos simulando una conexión a Internet.
  bool conectado = true;

  // Cambia entre modo conectado y modo sin conexión.
  void cambiarConexion() {
    conectado = !conectado;
  }

  // Obtiene los turnos que todavía no fueron sincronizados.
  Future<List<Turno>> obtenerTurnosPendientes() async {
    final turnos = await repositorio.obtenerTurnos();

    return turnos
        .where((turno) => !turno.sincronizado)
        .toList();
  }

  // Simula la sincronización de los turnos con el servidor.
  Future<void> sincronizar() async {
    // Si estamos sin conexión, no podemos sincronizar.
    if (!conectado) {
      return;
    }

    final turnosPendientes = await obtenerTurnosPendientes();

    // Por ahora simulamos el envío al servidor.
    for (final turno in turnosPendientes) {
      final turnoSincronizado = Turno(
        id: turno.id,
        paciente: turno.paciente,
        medico: turno.medico,
        especialidad: turno.especialidad,
        fecha: turno.fecha,
        hora: turno.hora,
        estado: turno.estado,
        sincronizado: true,
      );

      // Actualizamos el turno local como sincronizado.
      await repositorio.modificarTurno(turnoSincronizado);
    }
  }
}