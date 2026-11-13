/// Define los posibles estados de un turno médico en el sistema.
enum EstadoTurno { pendiente, confirmado, cancelado, atendido }

/// Extensión para convertir el estado del turno a texto de API y etiqueta legible.
extension EstadoTurnoExtension on EstadoTurno {
  static EstadoTurno desdeTexto(String texto) {
    switch (texto.toUpperCase()) {
      case 'CONFIRMADO':
        return EstadoTurno.confirmado;
      case 'CANCELADO':
        return EstadoTurno.cancelado;
      case 'ATENDIDO':
        return EstadoTurno.atendido;
      case 'PENDIENTE':
      default:
        return EstadoTurno.pendiente;
    }
  }

  String aTextoApi() {
    switch (this) {
      case EstadoTurno.pendiente:
        return 'PENDIENTE';
      case EstadoTurno.confirmado:
        return 'CONFIRMADO';
      case EstadoTurno.cancelado:
        return 'CANCELADO';
      case EstadoTurno.atendido:
        return 'ATENDIDO';
    }
  }

  String get etiqueta {
    switch (this) {
      case EstadoTurno.pendiente:
        return 'Pendiente';
      case EstadoTurno.confirmado:
        return 'Confirmado';
      case EstadoTurno.cancelado:
        return 'Cancelado';
      case EstadoTurno.atendido:
        return 'Atendido';
    }
  }
}
