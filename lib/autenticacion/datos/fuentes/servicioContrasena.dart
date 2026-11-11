import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// Servicio para generar y verificar hashes SHA-256 con sal aleatoria por usuario.
// NOTA: Esto es solo para la verificacion offline del dispositivo; el servidor usa bcrypt.
class ServicioContrasena {
  static String generarHash(String contrasena) {
    final random = Random.secure();
    final bytesSal = List<int>.generate(16, (_) => random.nextInt(256));
    final salHex = bytesSal.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    final bytesContrasena = utf8.encode(salHex + contrasena);
    final hash = sha256.convert(bytesContrasena).toString();

    return '$salHex:$hash';
  }

  static bool verificar(String contrasena, String guardada) {
    try {
      final partes = guardada.split(':');
      if (partes.length != 2) return false;

      final salHex = partes[0];
      final hashGuardado = partes[1];

      final bytesContrasena = utf8.encode(salHex + contrasena);
      final hashCalculado = sha256.convert(bytesContrasena).toString();

      return hashCalculado == hashGuardado;
    } catch (_) {
      return false;
    }
  }
}
