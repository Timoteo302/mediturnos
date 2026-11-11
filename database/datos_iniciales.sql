SET NAMES utf8mb4;
USE mediturnos;
-- Contraseñas de prueba: Admin1234 y Paciente1234 (bcrypt costo 10)
INSERT INTO usuarios (nombre, apellido, email, contrasena, rol, activo) VALUES
  ('Administrador','MediTurnos','admin@mediturnos.com','$2b$10$Qra3.ZouVWVIGHX7/3Dy..w.3xxu9kdyI5fW3ELwkGXJ/xTUx/.Oa','ADMIN',1),
  ('Matías','Romero','paciente@mediturnos.com','$2b$10$Uih1r6a9BuuUSmTHGXbrW.QJrUmCpbS4cUxMfEysrOnzZVvoLrIJ2','PACIENTE',1)
ON DUPLICATE KEY UPDATE email = email;
INSERT INTO pacientes (usuario_id, dni, telefono)
  SELECT id, '36782904', NULL FROM usuarios WHERE email = 'paciente@mediturnos.com'
ON DUPLICATE KEY UPDATE dni = dni;
