import '../modelos/usuario.dart';
import '../modelos/solicitudRecuperacion.dart';

abstract class RepositorioAutenticacion {
  Future<Usuario> iniciarSesion(String email, String contrasena);
  Future<Usuario> registrarPaciente({required String nombre, required String apellido, required String dni, required String email, required String contrasena});
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni});
  Future<void> restablecerContrasena({required String idRecuperacion, required String codigo, required String nuevaContrasena});
}
