enum ErrorAutenticacion {
  credencialesInvalidas,
  cuentaInactiva,
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

class ExcepcionAutenticacion implements Exception {
  final ErrorAutenticacion tipo;
  final String? campo;
  final int? intentosRestantes;

  ExcepcionAutenticacion(this.tipo, {this.campo, this.intentosRestantes});

  @override
  String toString() => 'ExcepcionAutenticacion(tipo: $tipo, campo: $campo, intentos: $intentosRestantes)';
}
