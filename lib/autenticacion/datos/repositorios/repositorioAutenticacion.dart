import '../modelos/usuario.dart';
import '../modelos/solicitudRecuperacion.dart';

// Interfaz para la gestión de autenticación y registro de usuarios.
abstract class RepositorioAutenticacion {
  Future<Usuario> iniciarSesion(String email, String contrasena);
  Future<Usuario> registrarPaciente({
    required String nombre,
    required String apellido,
    required String dni,
    required String telefono,
    required String email,
    required String contrasena,
  });
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni});
  Future<void> restablecerContrasena({required String idRecuperacion, required String codigo, required String nuevaContrasena});
  // Actualiza los datos de perfil almacenados localmente en SQLite para la sesión del usuario.
  Future<void> actualizarCopiaLocal(Usuario usuario);
}
