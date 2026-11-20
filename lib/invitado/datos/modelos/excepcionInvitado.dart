enum TipoErrorInvitado {
  datosInvalidos,
  cuentaExistente,
  limiteInvitado,
  horarioOcupado,
  codigoInvalido,
  codigoVencido,
  demasiadosIntentos,
  esperaParaReenviar,
  activacionNoEncontrada,
  sinConexion,
  errorServidor,
  desconocido,
}

// Excepción personalizada para gestionar los errores específicos devueltos en la activación y reservas de invitados.
class ExcepcionInvitado implements Exception {
  final TipoErrorInvitado tipo;
  final String? codigo;
  final String? mensaje;
  final String? campo;

  ExcepcionInvitado(this.tipo, {this.codigo, this.mensaje, this.campo});

  @override
  String toString() => 'ExcepcionInvitado(tipo: $tipo, codigo: $codigo, campo: $campo, mensaje: $mensaje)';
}
