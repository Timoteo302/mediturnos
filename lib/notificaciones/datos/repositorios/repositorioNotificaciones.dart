import '../modelos/notificacion.dart';

// Interfaz abstracta para la gestión de notificaciones de la aplicación.
abstract class RepositorioNotificaciones {
  Future<List<Notificacion>> obtenerNotificaciones({required int usuarioId});
  Future<int> obtenerCantidadNoLeidas({required int usuarioId});
  Future<void> marcarLeida({required int id});
  Future<void> marcarTodasLeidas({required int usuarioId});
}
