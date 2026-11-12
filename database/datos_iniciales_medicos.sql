SET NAMES utf8mb4;
USE mediturnos;
INSERT INTO medicos (nombre, apellido, especialidad_id, matricula, activo) VALUES
  ('Juan Manuel','Gómez',2,'114820',1),
  ('Lucía','Benítez',2,'128450',1),
  ('Ramiro','Vaca',6,'98712',1),
  ('Martín','Soria',3,'76540',0)
ON DUPLICATE KEY UPDATE matricula = matricula;
INSERT IGNORE INTO horarios_atencion (medico_id, dia_semana, hora_inicio, hora_fin, duracion_turno, activo)
SELECT m.id, d.dia, f.ini, f.fin, 30, 1
FROM medicos m
JOIN (SELECT 1 AS dia UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
JOIN (SELECT '08:30:00' AS ini, '12:30:00' AS fin UNION SELECT '14:00:00', '18:00:00') f
WHERE m.matricula IN ('114820','128450');
INSERT IGNORE INTO horarios_atencion (medico_id, dia_semana, hora_inicio, hora_fin, duracion_turno, activo)
SELECT m.id, d.dia, '09:00:00', '13:00:00', 30, 1
FROM medicos m
JOIN (SELECT 1 AS dia UNION SELECT 3 UNION SELECT 5) d
WHERE m.matricula = '98712';
