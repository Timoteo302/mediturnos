class Turno {
  final int id;
  final String paciente;
  final String medico;
  final String especialidad;
  final String fecha;
  final String hora;
  final String estado;
  final bool sincronizado;

  final int? pacienteId;
  final int? medicoId;
  final String? claveSolicitud;

  Turno({
    required this.id,
    required this.paciente,
    required this.medico,
    required this.especialidad,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.sincronizado,
    this.pacienteId,
    this.medicoId,
    this.claveSolicitud,
  });
}