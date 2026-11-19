import '../modelos/notificacion.dart';
import '../fuentes/clienteNotificacionesApi.dart';
import 'repositorioNotificaciones.dart';

// Implementación del repositorio de notificaciones mediante cliente HTTP.
class RepositorioNotificacionesApi implements RepositorioNotificaciones {
  final ClienteNotificacionesApi clienteApi;

  RepositorioNotificacionesApi(this.clienteApi);

  @override
  Future<List<Notificacion>> obtenerNotificaciones({required int usuarioId}) {
    return clienteApi.obtenerNotificaciones(usuarioId: usuarioId);
  }

  @override
  Future<int> obtenerCantidadNoLeidas({required int usuarioId}) {
    return clienteApi.obtenerCantidadNoLeidas(usuarioId: usuarioId);
  }

  @override
  Future<void> marcarLeida({required int id}) {
    return clienteApi.marcarLeida(id: id);
  }

  @override
  Future<void> marcarTodasLeidas({required int usuarioId}) {
    return clienteApi.marcarTodasLeidas(usuarioId: usuarioId);
  }
}
