class Turno {
  final int id;
  final String paciente;
  final String medico;
  final String especialidad; //Ej: Cardiologia
  final String fecha;
  final String hora;
  final String estado; //Pendiente, confirmado, cancelado, etc.
  final bool sincronizado;  //Saber si ya se envió al servidor o todavía está pendiente

  Turno({
    required this.id,
    required this.paciente,
    required this.medico,
    required this.especialidad,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.sincronizado,
  });
}