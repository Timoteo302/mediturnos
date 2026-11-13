// TODO(offline-first): lo implementa el compañero de offline-first. No borrar estos comentarios hasta implementarlo.
// Implementación offline-first de RepositorioGestionTurnos usando ClienteTurnosApi + AlmacenTurnosLocal.
// - Lecturas (obtenerTurnos, obtenerDisponibilidad): con conexión, pedir a la API y refrescar la caché; si responde sinConexion, devolver la caché; si está vacía, relanzar sinConexion.
// - solicitarTurno sin conexión: guardar en la tabla local con sincronizado=false y la claveSolicitud.
// - Sincronización: enviar turnos pendientes (sincronizado=false) al recuperar conexión y bajar el estado actual del servidor.
// - En main.dart cambiar SOLO la línea del Provider<RepositorioGestionTurnos>. Los ViewModels y las pantallas no se tocan.
