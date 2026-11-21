import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mediturnos/autenticacion/datos/fuentes/almacenSesionLocal.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/clienteAutenticacionApi.dart';
import 'package:mediturnos/autenticacion/datos/fuentes/servicioContrasena.dart';
import 'package:mediturnos/autenticacion/datos/modelos/excepcionAutenticacion.dart';
import 'package:mediturnos/autenticacion/datos/modelos/paciente.dart';
import 'package:mediturnos/autenticacion/datos/modelos/rolUsuario.dart';
import 'package:mediturnos/autenticacion/datos/modelos/usuario.dart';
import 'package:mediturnos/autenticacion/datos/repositorios/repositorioAutenticacionOfflineFirst.dart';

class FakeAlmacenSesionLocal implements AlmacenSesionLocal {
  final Map<String, Map<String, dynamic>> _baseSimulada = {};
  bool simularFalla = false;
  bool llamadoActualizarDatosUsuario = false;

  @override
  Future<void> guardar(Usuario usuario, String contrasenaHash) async {
    final jsonMap = usuario.toJson();
    jsonMap['sesionOffline'] = usuario.sesionOffline;
    _baseSimulada[usuario.email.trim().toLowerCase()] = {
      'email': usuario.email.trim().toLowerCase(),
      'contrasena_hash': contrasenaHash,
      'usuario_json': json.encode(jsonMap),
      'ultimo_acceso': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<void> actualizarDatosUsuario(Usuario usuario) async {
    llamadoActualizarDatosUsuario = true;
    if (simularFalla) {
      throw Exception('Error simulado en base local');
    }
    final key = usuario.email.trim().toLowerCase();
    if (_baseSimulada.containsKey(key)) {
      final jsonMap = usuario.toJson();
      jsonMap['sesionOffline'] = false;
      _baseSimulada[key]!['usuario_json'] = json.encode(jsonMap);
      _baseSimulada[key]!['ultimo_acceso'] = DateTime.now().toIso8601String();
    }
  }

  @override
  Future<Map<String, dynamic>?> obtener(String email) async {
    return _baseSimulada[email.trim().toLowerCase()];
  }

  @override
  Future<Map<String, dynamic>?> obtenerPorUsuarioId(int usuarioId) async {
    for (final s in _baseSimulada.values) {
      final map = json.decode(s['usuario_json']) as Map<String, dynamic>;
      if (map['id'] == usuarioId) return s;
    }
    return null;
  }

  @override
  Future<void> borrar(String email) async {
    _baseSimulada.remove(email.trim().toLowerCase());
  }
}

class FakeClienteAutenticacionApiSinConexion extends ClienteAutenticacionApi {
  FakeClienteAutenticacionApiSinConexion() : super(http.Client());

  @override
  Future<Usuario> iniciarSesion(String email, String contrasena) async {
    throw ExcepcionAutenticacion(ErrorAutenticacion.sinConexion);
  }
}

void main() {
  group('Actualización de copia local de sesión en perfil', () {
    late FakeAlmacenSesionLocal localStore;
    late FakeClienteAutenticacionApiSinConexion remotoApi;
    late RepositorioAutenticacionOfflineFirst repositorio;

    setUp(() {
      localStore = FakeAlmacenSesionLocal();
      remotoApi = FakeClienteAutenticacionApiSinConexion();
      repositorio = RepositorioAutenticacionOfflineFirst(remoto: remotoApi, local: localStore);
    });

    test('actualizarCopiaLocal llama a actualizarDatosUsuario con el usuario', () async {
      final usuario = Usuario(
        id: 1,
        nombre: 'Lucas',
        apellido: 'González',
        email: 'lucas@test.com',
        rol: RolUsuario.paciente,
        activo: true,
        fechaCreacion: '2026-01-01',
      );

      await repositorio.actualizarCopiaLocal(usuario);

      expect(localStore.llamadoActualizarDatosUsuario, isTrue);
    });

    test('Si el almacén tira una excepción, actualizarCopiaLocal NO la relanza', () async {
      localStore.simularFalla = true;
      final usuario = Usuario(
        id: 1,
        nombre: 'Lucas',
        apellido: 'González',
        email: 'lucas@test.com',
        rol: RolUsuario.paciente,
        activo: true,
        fechaCreacion: '2026-01-01',
      );

      expect(() => repositorio.actualizarCopiaLocal(usuario), returnsNormally);
    });

    test('Login offline después de actualizar la copia local muestra datos nuevos y mantiene la clave funcionando', () async {
      final email = 'lucas@test.com';
      final passOriginal = 'clave1234';

      final usuarioInicial = Usuario(
        id: 1,
        nombre: 'Lucas',
        apellido: 'González',
        email: email,
        rol: RolUsuario.paciente,
        activo: true,
        fechaCreacion: '2026-01-01',
        paciente: Paciente(id: 10, dni: '38450123', telefono: '11111111'),
      );

      // 1. Guardar copia inicial al hacer login
      final hash = ServicioContrasena.generarHash(passOriginal);
      await localStore.guardar(usuarioInicial, hash);

      // 2. Actualizar copia local con nombre y teléfono nuevos
      final usuarioActualizado = Usuario(
        id: 1,
        nombre: 'Lucas Nuevo',
        apellido: 'González Nuevo',
        email: email,
        rol: RolUsuario.paciente,
        activo: true,
        fechaCreacion: '2026-01-01',
        paciente: Paciente(id: 10, dni: '38450123', telefono: '3841404667'),
      );

      await repositorio.actualizarCopiaLocal(usuarioActualizado);

      // 3. Iniciar sesión sin conexión (el remoto tira sinConexion)
      final usuarioObtenidoOffline = await repositorio.iniciarSesion(email, passOriginal);

      // 4. Verificaciones
      expect(usuarioObtenidoOffline.nombre, equals('Lucas Nuevo'));
      expect(usuarioObtenidoOffline.apellido, equals('González Nuevo'));
      expect(usuarioObtenidoOffline.paciente?.telefono, equals('3841404667'));
      expect(usuarioObtenidoOffline.sesionOffline, isTrue);

      // Contraseña incorrecta tira credencialesInvalidas
      expect(
        () => repositorio.iniciarSesion(email, 'clave_erronea'),
        throwsA(isA<ExcepcionAutenticacion>().having((e) => e.tipo, 'tipo', equals(ErrorAutenticacion.credencialesInvalidas))),
      );
    });
  });
}
