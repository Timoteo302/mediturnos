// TODO(offline-first): lo implementa rami lo  de offline-first. No borrar estos comentarios hasta implementarlo.
// Implementación local con sqflite para persistencia offline de médicos.
// - Elegir con el compañero de offline-first si se usa la base existente (baseDatosLocal.dart, subiendo la versión con onUpgrade) o un archivo propio (ej: mediturnos_medicos.db).
// - Tablas que espejan MySQL: especialidades(id, nombre, descripcion, activo), medicos(id, nombre, apellido, especialidad_id, matricula, activo), horarios_atencion(id, medico_id, dia_semana, hora_inicio, hora_fin, duracion_turno, activo), cada una con una columna actualizado_en.
// - Usar siempre los IDs que manda el servidor; no inventar IDs locales.
