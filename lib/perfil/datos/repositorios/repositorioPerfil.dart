import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';

// Interfaz para el repositorio de perfil de usuario.
abstract class RepositorioPerfil {
  Future<Usuario> actualizarPerfil({
    required int id,
    required String nombre,
    required String apellido,
    String? telefono,
  });
}
