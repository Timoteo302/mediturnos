SET NAMES utf8mb4;
USE mediturnos;
INSERT INTO usuarios (nombre, apellido, email, contrasena, rol, activo) VALUES
  ('Martina','Gómez','martina.gomez@mediturnos.com','$2b$10$Uih1r6a9BuuUSmTHGXbrW.QJrUmCpbS4cUxMfEysrOnzZVvoLrIJ2','PACIENTE',1),
  ('Esteban','López','esteban.lopez@mediturnos.com','$2b$10$Uih1r6a9BuuUSmTHGXbrW.QJrUmCpbS4cUxMfEysrOnzZVvoLrIJ2','PACIENTE',1)
ON DUPLICATE KEY UPDATE email = email;
INSERT INTO pacientes (usuario_id, dni, telefono)
  SELECT id, '38412905', '3855000001' FROM usuarios WHERE email = 'martina.gomez@mediturnos.com'
ON DUPLICATE KEY UPDATE dni = dni;
INSERT INTO pacientes (usuario_id, dni, telefono)
  SELECT id, '29834112', '3855000002' FROM usuarios WHERE email = 'esteban.lopez@mediturnos.com'
ON DUPLICATE KEY UPDATE dni = dni;
INSERT IGNORE INTO turnos (paciente_id, medico_id, fecha, hora, estado, clave_solicitud)
SELECT p.id, m.id, d.fecha, d.hora, d.estado, UUID()
FROM (
  SELECT 'paciente@mediturnos.com' AS email, '114820' AS matricula, CURDATE() AS fecha, '09:00:00' AS hora, 'CONFIRMADO' AS estado
  UNION ALL SELECT 'martina.gomez@mediturnos.com', '98712', CURDATE(), '09:30:00', 'PENDIENTE'
  UNION ALL SELECT 'esteban.lopez@mediturnos.com', '128450', CURDATE(), '10:00:00', 'CANCELADO'
  UNION ALL SELECT 'paciente@mediturnos.com', '128450', CURDATE(), '11:00:00', 'PENDIENTE'
  UNION ALL SELECT 'paciente@mediturnos.com', '98712', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '10:00:00', 'PENDIENTE'
  UNION ALL SELECT 'paciente@mediturnos.com', '114820', DATE_SUB(CURDATE(), INTERVAL 7 DAY), '10:30:00', 'ATENDIDO'
  UNION ALL SELECT 'paciente@mediturnos.com', '114820', DATE_SUB(CURDATE(), INTERVAL 14 DAY), '15:00:00', 'CANCELADO'
) d
JOIN usuarios u ON u.email = d.email
JOIN pacientes p ON p.usuario_id = u.id
JOIN medicos m ON m.matricula = d.matricula;
