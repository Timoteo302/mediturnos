-- Migración del modo invitado (cuentas sin contraseña que se activan con un código).
-- Se corre UNA sola vez, después de migracion_notificaciones.sql.
-- Si da "Duplicate column name", ya estaba corrida: no hay que hacer nada.

USE mediturnos;

-- Marca las cuentas creadas como invitado que todavía no eligieron contraseña
ALTER TABLE usuarios
  ADD COLUMN contrasena_pendiente TINYINT(1) NOT NULL DEFAULT 0;

-- Códigos de activación (se guarda solo el hash, nunca el código en claro)
CREATE TABLE activaciones_cuenta (
  id INT NOT NULL AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  codigo_hash VARCHAR(255) NOT NULL,
  vence_en DATETIME NOT NULL,
  intentos INT NOT NULL DEFAULT 0,
  usado TINYINT(1) NOT NULL DEFAULT 0,
  fecha_creacion TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_activacion_usuario (usuario_id, usado),
  CONSTRAINT fk_activacion_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
