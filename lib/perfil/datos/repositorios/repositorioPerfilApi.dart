import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import '../fuentes/clientePerfilApi.dart';
import 'repositorioPerfil.dart';

// Implementación del repositorio de perfil que consulta directamente la API.
class RepositorioPerfilApi implements RepositorioPerfil {
  final ClientePerfilApi cliente;

  RepositorioPerfilApi(this.cliente);

  @override
  Future<Usuario> actualizarPerfil({
    required int id,
    required String nombre,
    required String apellido,
    String? telefono,
  }) {
    return cliente.actualizarPerfil(
      id: id,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
    );
  }
}
