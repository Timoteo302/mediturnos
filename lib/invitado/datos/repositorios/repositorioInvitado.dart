import '../modelos/resultadoReservaInvitado.dart';

// Interfaz para la gestión de reservas e interacciones en modo invitado.
abstract class RepositorioInvitado {
  Future<ResultadoReservaInvitado> reservarComoInvitado({
    required String nombre,
    required String apellido,
    required String dni,
    required String email,
    required String telefono,
    required int medicoId,
    required DateTime fecha,
    required String hora,
    required String claveSolicitud,
  });

  Future<Map<String, dynamic>> confirmarActivacion({
    required String email,
    required String codigo,
    required String contrasena,
  });

  Future<Map<String, dynamic>> reenviarActivacion({required String email});
}
