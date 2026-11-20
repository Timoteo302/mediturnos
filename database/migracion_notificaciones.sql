-- Migración de notificaciones y recordatorio de 24 h.
-- Se corre UNA sola vez, después de mediturnos.sql y los datos iniciales.
-- Si da "Duplicate column name", ya estaba corrida: no hay que hacer nada.

USE mediturnos;

-- Columnas para saber si ya se mandó el recordatorio y qué respondió el paciente
ALTER TABLE turnos
  ADD COLUMN recordatorio_enviado TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN respuesta_paciente ENUM('SIN_RESPUESTA','ASISTIRA','NO_ASISTIRA')
    NOT NULL DEFAULT 'SIN_RESPUESTA';

-- Notificaciones dentro de la app (la campanita)
CREATE TABLE notificaciones (
  id INT NOT NULL AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  turno_id INT NULL,
  tipo ENUM('RECORDATORIO_ASISTENCIA','PACIENTE_ASISTIRA','PACIENTE_NO_ASISTIRA',
            'TURNO_REPROGRAMADO','TURNO_CONFIRMADO','TURNO_CANCELADO_CENTRO') NOT NULL,
  titulo VARCHAR(120) NOT NULL,
  mensaje VARCHAR(255) NOT NULL,
  leida TINYINT(1) NOT NULL DEFAULT 0,
  fecha_creacion TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_notif_usuario (usuario_id, leida, fecha_creacion),
  CONSTRAINT fk_notif_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
  CONSTRAINT fk_notif_turno FOREIGN KEY (turno_id) REFERENCES turnos (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
