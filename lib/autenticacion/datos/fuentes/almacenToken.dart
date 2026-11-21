import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Almacén seguro en el dispositivo para guardar y consultar el token JWT y usuarioId de la sesión.
class AlmacenToken {
  static const String _claveToken = 'mediturnos_jwt_token';
  static const String _claveVenceEn = 'mediturnos_jwt_vence_en';
  static const String _claveUsuarioId = 'mediturnos_jwt_usuario_id';

  final FlutterSecureStorage _storage;

  AlmacenToken({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Guarda el token JWT, su fecha de vencimiento y el ID del usuario en el almacenamiento seguro.
  Future<void> guardar(String token, DateTime venceEn, {int? usuarioId}) async {
    try {
      await _storage.write(key: _claveToken, value: token);
      await _storage.write(key: _claveVenceEn, value: venceEn.toIso8601String());
      if (usuarioId != null) {
        await _storage.write(key: _claveUsuarioId, value: usuarioId.toString());
      }
    } catch (_) {}
  }

  // Retorna el ID del usuario autenticado guardado en el almacenamiento seguro.
  Future<int?> leerUsuarioId() async {
    try {
      final idStr = await _storage.read(key: _claveUsuarioId);
      if (idStr != null && idStr.isNotEmpty) {
        return int.tryParse(idStr);
      }
    } catch (_) {}
    return null;
  }

  // Retorna el token JWT activo o null si no existe o ya venció.
  Future<String?> leerToken() async {
    try {
      final token = await _storage.read(key: _claveToken);
      final venceEnStr = await _storage.read(key: _claveVenceEn);

      if (token == null || token.isEmpty || venceEnStr == null) {
        return null;
      }

      final venceEn = DateTime.parse(venceEnStr);
      if (DateTime.now().isAfter(venceEn)) {
        return null;
      }
      return token;
    } catch (_) {
      return null;
    }
  }

  // Permite verificar si existía un token guardado pero su fecha ya venció.
  Future<bool> sesionExpirada() async {
    try {
      final token = await _storage.read(key: _claveToken);
      final venceEnStr = await _storage.read(key: _claveVenceEn);
      if (token != null && token.isNotEmpty && venceEnStr != null) {
        final venceEn = DateTime.parse(venceEnStr);
        return DateTime.now().isAfter(venceEn);
      }
    } catch (_) {}
    return false;
  }

  // Elimina las credenciales de sesión del almacenamiento seguro.
  Future<void> borrar() async {
    try {
      await _storage.delete(key: _claveToken);
      await _storage.delete(key: _claveVenceEn);
      await _storage.delete(key: _claveUsuarioId);
    } catch (_) {}
  }
}
