enum ErrorAutenticacion {
  credencialesInvalidas,
  cuentaInactiva,
  activacionPendiente,
  emailDuplicado,
  dniDuplicado,
  cuentaNoEncontrada,
  datosInvalidos,
  codigoInvalido,
  codigoVencido,
  demasiadosIntentos,
  solicitudNoEncontrada,
  sinConexion,
  errorServidor,
  desconocido,
}

// Excepción personalizada para los errores del módulo de autenticación.
class ExcepcionAutenticacion implements Exception {
  final ErrorAutenticacion tipo;
  final String? campo;
  final String? mensaje;
  final int? intentosRestantes;

  ExcepcionAutenticacion(this.tipo, {this.campo, this.mensaje, this.intentosRestantes});

  @override
  String toString() => 'ExcepcionAutenticacion(tipo: $tipo, campo: $campo, mensaje: $mensaje, intentos: $intentosRestantes)';
}
