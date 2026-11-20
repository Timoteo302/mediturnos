-- Script a ejecutar una sola vez, DESPUES de migracion_invitado.sql y los datos iniciales.

USE mediturnos;

ALTER TABLE turnos
  ADD COLUMN token_respuesta VARCHAR(64) NULL,
  ADD UNIQUE KEY uk_turnos_token_respuesta (token_respuesta);
