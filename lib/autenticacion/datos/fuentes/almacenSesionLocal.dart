import '../modelos/usuario.dart';

// Interfaz para la persistencia local de la sesión del usuario.
abstract class AlmacenSesionLocal {
  Future<void> guardar(Usuario usuario, String contrasenaHash);
  // Actualiza el JSON del usuario en la base local sin modificar el hash de la contraseña.
  Future<void> actualizarDatosUsuario(Usuario usuario);
  Future<Map<String, dynamic>?> obtener(String email);
  Future<Map<String, dynamic>?> obtenerPorUsuarioId(int usuarioId);
  Future<void> borrar(String email);
}
