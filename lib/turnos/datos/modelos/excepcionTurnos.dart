/// Tipos de errores específicos del módulo de turnos.
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
  sinConexion,
  errorServidor,
  desconocido,
}

/// Excepción personalizada para manejar errores de la API de turnos.
class ExcepcionTurnos implements Exception {
  final ErrorTurnos tipo;
  final String? campo;
  final String? mensajeServidor;

  ExcepcionTurnos(this.tipo, {this.campo, this.mensajeServidor});

  @override
  String toString() => 'ExcepcionTurnos(tipo: $tipo, campo: $campo, mensajeServidor: $mensajeServidor)';
}
