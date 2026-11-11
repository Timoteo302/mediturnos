import 'rolUsuario.dart';
import 'paciente.dart';

class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final RolUsuario rol;
  final bool activo;
  final String fechaCreacion;
  final Paciente? paciente;
  final bool sesionOffline;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    required this.activo,
    required this.fechaCreacion,
    this.paciente,
    this.sesionOffline = false,
  });

  String get nombreCompleto => '$nombre $apellido';

  String get iniciales {
    if (nombre.isEmpty || apellido.isEmpty) return 'US';
    return '${nombre[0]}${apellido[0]}'.toUpperCase();
  }

  factory Usuario.fromJson(Map<String, dynamic> json, {bool sesionOffline = false}) {
    return Usuario(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      rol: RolUsuarioExtension.desdeTexto(json['rol']?.toString() ?? 'PACIENTE'),
      activo: json['activo'] ?? true,
      fechaCreacion: json['fechaCreacion']?.toString() ?? '',
      paciente: json['paciente'] != null ? Paciente.fromJson(json['paciente']) : null,
      sesionOffline: sesionOffline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': RolUsuarioExtension.aTexto(rol),
      'activo': activo,
      'fechaCreacion': fechaCreacion,
      'paciente': paciente?.toJson(),
      'sesionOffline': sesionOffline,
    };
  }

  Usuario copiarConSesionOffline(bool offline) {
    return Usuario(
      id: id,
      nombre: nombre,
      apellido: apellido,
      email: email,
      rol: rol,
      activo: activo,
      fechaCreacion: fechaCreacion,
      paciente: paciente,
      sesionOffline: offline,
    );
  }
}
