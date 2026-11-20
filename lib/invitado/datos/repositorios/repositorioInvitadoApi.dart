import 'package:mediturnos/invitado/datos/fuentes/clienteInvitadoApi.dart';
import 'package:mediturnos/invitado/datos/modelos/resultadoReservaInvitado.dart';
import 'repositorioInvitado.dart';

// Implementación del repositorio de invitados que se conecta a la API HTTP remota.
class RepositorioInvitadoApi implements RepositorioInvitado {
  final ClienteInvitadoApi _clienteApi;

  RepositorioInvitadoApi(this._clienteApi);

  @override
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
  }) async {
    final fechaStr = '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

    return await _clienteApi.reservarComoInvitado(
      nombre: nombre,
      apellido: apellido,
      dni: dni,
      email: email,
      telefono: telefono,
      medicoId: medicoId,
      fecha: fechaStr,
      hora: hora,
      claveSolicitud: claveSolicitud,
    );
  }

  @override
  Future<Map<String, dynamic>> confirmarActivacion({
    required String email,
    required String codigo,
    required String contrasena,
  }) async {
    return await _clienteApi.confirmarActivacion(
      email: email,
      codigo: codigo,
      contrasena: contrasena,
    );
  }

  @override
  Future<Map<String, dynamic>> reenviarActivacion({required String email}) async {
    return await _clienteApi.reenviarActivacion(email: email);
  }
}
