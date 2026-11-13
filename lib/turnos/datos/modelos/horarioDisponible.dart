/// Representa un horario disponible para la reserva de turnos en una fecha dada.
class HorarioDisponible {
  final String hora; // 'HH:mm'
  final bool disponible;

  HorarioDisponible({required this.hora, required this.disponible});

  factory HorarioDisponible.fromJson(Map<String, dynamic> json) {
    return HorarioDisponible(
      hora: (json['hora']?.toString() ?? '08:00').substring(0, 5),
      disponible: json['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'hora': hora, 'disponible': disponible};
}
