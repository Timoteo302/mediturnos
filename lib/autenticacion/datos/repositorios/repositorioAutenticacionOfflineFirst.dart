import 'dart:convert';
import '../modelos/usuario.dart';
import '../modelos/solicitudRecuperacion.dart';
import '../modelos/excepcionAutenticacion.dart';
import '../fuentes/clienteAutenticacionApi.dart';
import '../fuentes/almacenSesionLocal.dart';
import '../fuentes/servicioContrasena.dart';
import 'repositorioAutenticacion.dart';

class RepositorioAutenticacionOfflineFirst implements RepositorioAutenticacion {
  final ClienteAutenticacionApi remoto;
  final AlmacenSesionLocal local;

  RepositorioAutenticacionOfflineFirst({required this.remoto, required this.local});

  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async {
    final emailNorm = email.trim().toLowerCase();

    try {
      final usuarioRemoto = await remoto.iniciarSesion(emailNorm, contrasena);
      final hash = ServicioContrasena.generarHash(contrasena);
      await local.guardar(usuarioRemoto, hash);
      return usuarioRemoto;
    } on ExcepcionAutenticacion catch (e) {
      if (e.tipo == ErrorAutenticacion.credencialesInvalidas || e.tipo == ErrorAutenticacion.cuentaInactiva) {
        await local.borrar(emailNorm);
        rethrow;
      }
      if (e.tipo == ErrorAutenticacion.sinConexion) {
        return await _iniciarSesionLocal(emailNorm, contrasena);
      }
      rethrow;
    } catch (_) {
      return await _iniciarSesionLocal(emailNorm, contrasena);
    }
  }

  Future<Usuario> _iniciarSesionLocal(String email, String contrasena) async {
    final registroLocal = await local.obtener(email);
    if (registroLocal == null) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
    }

    final contrasenaHashGuardada = registroLocal['contrasena_hash']?.toString() ?? '';
    final passwordValida = ServicioContrasena.verificar(contrasena, contrasenaHashGuardada);

    if (!passwordValida) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.credencialesInvalidas);
    }

    final usuarioJsonStr = registroLocal['usuario_json']?.toString() ?? '{}';
    final jsonMap = json.decode(usuarioJsonStr);
    return Usuario.fromJson(jsonMap, sesionOffline: true);
  }

  @override
  Future<Usuario> registrarPaciente({
    required String nombre,
    required String apellido,
    required String dni,
    required String email,
    required String contrasena,
  }) async {
    final emailNorm = email.trim().toLowerCase();
    final usuario = await remoto.registrarPaciente(
      nombre: nombre,
      apellido: apellido,
      dni: dni,
      email: emailNorm,
      contrasena: contrasena,
    );

    final hash = ServicioContrasena.generarHash(contrasena);
    await local.guardar(usuario, hash);

    return usuario;
  }

  @override
  Future<SolicitudRecuperacion> solicitarRecuperacion({String? email, String? dni}) async {
    final emailNorm = email?.trim().toLowerCase();
    return await remoto.solicitarRecuperacion(email: emailNorm, dni: dni);
  }

  @override
  Future<void> restablecerContrasena({
    required String idRecuperacion,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    await remoto.restablecerContrasena(
      idRecuperacion: idRecuperacion,
      codigo: codigo,
      nuevaContrasena: nuevaContrasena,
    );
  }
}
