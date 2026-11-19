import 'package:flutter/foundation.dart';
import 'package:mediturnos/configuracion/baseDatosLocal.dart';

// Borra de SQLite únicamente los datos personales ya sincronizados al cerrar la sesión.
// No borra los turnos con sincronizado = 0 para no perder cambios locales sin enviar.
Future<void> limpiarDatosAlCerrarSesion() async {
  try {
    final db = await BaseDatosLocal.obtenerBaseDatos();

    // Elimina únicamente los turnos que ya están guardados en el servidor.
    await db.delete('turnos', where: 'sincronizado = 1');

    // Borra la tabla de disponibilidades para no dejar franjas horarias cacheadas de otro usuario.
    await db.delete('disponibilidades');
  } catch (e) {
    debugPrint('Error al limpiar datos locales al cerrar sesión: $e');
  }
}
