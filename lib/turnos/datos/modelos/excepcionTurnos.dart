// Definimos los tipos de errores que pueden ocurrir con los turnos.
// Agregamos confirmacionAnticipada para cuando se intenta confirmar un turno antes de las 24 hs.
enum ErrorTurnos {
  datosInvalidos,
  horarioOcupado,
  horarioNoDisponible,
  turnoNoEncontrado,
  turnoNoModificable,
  transicionInvalida,
  medicoNoEncontrado,
  medicoInactivo,
  pacienteNoEncontrado,
  confirmacionAnticipada, // Error cuando se intenta confirmar un turno con más de 24h de anticipación.
  sinPermiso,
  sinConexion,
  errorServidor,
  desconocido,
}

// Clase de excepción propia para atrapar los fallos de turnos y pasarlos a la UI.
class ExcepcionTurnos implements Exception {
  final ErrorTurnos tipo;
  final String? campo;
  final String? mensajeServidor;

  ExcepcionTurnos(this.tipo, {this.campo, this.mensajeServidor});

  @override
  String toString() => 'ExcepcionTurnos(tipo: $tipo, campo: $campo, mensajeServidor: $mensajeServidor)';
}
