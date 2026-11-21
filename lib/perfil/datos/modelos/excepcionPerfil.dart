// Enum con los tipos de errores que pueden ocurrir al actualizar el perfil del usuario.
enum ErrorPerfil {
  sinConexion,
  datosInvalidos,
  usuarioNoEncontrado,
  sinPermiso,
  errorServidor,
  desconocido,
}

// Excepción personalizada para los errores de edición de perfil.
class ExcepcionPerfil implements Exception {
  final ErrorPerfil tipo;
  final String? mensaje;
  final String? campo;

  ExcepcionPerfil(this.tipo, {this.mensaje, this.campo});

  @override
  String toString() => 'ExcepcionPerfil(tipo: $tipo, campo: $campo, mensaje: $mensaje)';
}
