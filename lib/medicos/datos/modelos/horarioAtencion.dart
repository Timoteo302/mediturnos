class HorarioAtencion {
  final int? id;
  final int diaSemana; // 1 = Lunes, 7 = Domingo
  final String horaInicio; // "HH:mm"
  final String horaFin; // "HH:mm"
  final int duracionTurno;
  final bool activo;

  HorarioAtencion({
    this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionTurno,
    required this.activo,
  });

  static String _normalizarHora(String hora) {
    if (hora.length > 5) {
      return hora.substring(0, 5);
    }
    return hora;
  }

  factory HorarioAtencion.fromJson(Map<String, dynamic> json) {
    return HorarioAtencion(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      diaSemana: json['diaSemana'] is int ? json['diaSemana'] : int.parse(json['diaSemana'].toString()),
      horaInicio: _normalizarHora(json['horaInicio']?.toString() ?? '08:00'),
      horaFin: _normalizarHora(json['horaFin']?.toString() ?? '12:00'),
      duracionTurno: json['duracionTurno'] is int ? json['duracionTurno'] : int.tryParse(json['duracionTurno']?.toString() ?? '30') ?? 30,
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'diaSemana': diaSemana,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'duracionTurno': duracionTurno,
      'activo': activo,
    };
  }
}
