import '../modelos/usuario.dart';

abstract class AlmacenSesionLocal {
  Future<void> guardar(Usuario usuario, String contrasenaHash);
  Future<Map<String, dynamic>?> obtener(String email);
  Future<void> borrar(String email);
}
