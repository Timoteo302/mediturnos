class Paciente {
  final int id;
  final String dni;
  final String? telefono;

  Paciente({
    required this.id,
    required this.dni,
    this.telefono,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      dni: json['dni']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dni': dni,
      'telefono': telefono,
    };
  }
}
