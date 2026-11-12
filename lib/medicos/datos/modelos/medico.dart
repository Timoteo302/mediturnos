import 'especialidad.dart';

class Medico {
  final int id;
  final String nombre;
  final String apellido;
  final Especialidad especialidad;
  final String? matricula;
  final bool activo;

  Medico({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.especialidad,
    this.matricula,
    required this.activo,
  });

  String get nombreCompleto => '$nombre $apellido';

  String get iniciales {
    if (nombre.isEmpty || apellido.isEmpty) return 'DR';
    return '${nombre[0]}${apellido[0]}'.toUpperCase();
  }

  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      especialidad: json['especialidad'] != null
          ? Especialidad.fromJson(json['especialidad'])
          : Especialidad(id: 0, nombre: 'Sin especialidad', activo: true),
      matricula: json['matricula']?.toString(),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'especialidad': especialidad.toJson(),
      'matricula': matricula,
      'activo': activo,
    };
  }
}
