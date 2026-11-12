enum ErrorMedicos {
  datosInvalidos,
  matriculaDuplicada,
  medicoNoEncontrado,
  especialidadDuplicada,
  especialidadEnUso,
  especialidadNoEncontrada,
  sinConexion,
  errorServidor,
  desconocido,
}

class ExcepcionMedicos implements Exception {
  final ErrorMedicos tipo;
  final String? campo;
  final String? mensajeServidor;

  ExcepcionMedicos(this.tipo, {this.campo, this.mensajeServidor});

  @override
  String toString() => 'ExcepcionMedicos(tipo: $tipo, campo: $campo, mensajeServidor: $mensajeServidor)';
}
