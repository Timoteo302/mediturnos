// TODO(offline-first): lo implementa el compañero de offline-first. No borrar estos comentarios hasta implementarlo.
// Contrato abstracto para el almacenamiento local de turnos (AlmacenTurnosLocal).
// Métodos requeridos:
// - guardarTurnos(List<TurnoDetalle>)
// - obtenerTurnos({int? pacienteId})
// - guardarDisponibilidad(int medicoId, DateTime fecha, List<HorarioDisponible>)
// - obtenerDisponibilidad(int medicoId, DateTime fecha)
// - Reutilizar la tabla turnos de baseDatosLocal.dart (id, pacienteId, medicoId, fecha, hora, estado, claveSolicitud, sincronizado) y agregarle lo que falte con onUpgrade.
// - Los turnos creados offline llevan sincronizado=false y su claveSolicitud.
