import '../../../turnos/datos/modelos/estadoTurno.dart';

// Enum que representa los distintos tipos de notificaciones de la aplicación.
enum TipoNotificacion {
  recordatorioAsistencia,
  pacienteAsistira,
  pacienteNoAsistira,
  turnoReprogramado,
  turnoConfirmado,
  turnoCanceladoCentro,
}

// Extensión para mapear el enum TipoNotificacion desde y hacia los strings de la API.
extension TipoNotificacionExtension on TipoNotificacion {
  static TipoNotificacion desdeTexto(String texto) {
    switch (texto.toUpperCase()) {
      case 'RECORDATORIO_ASISTENCIA':
        return TipoNotificacion.recordatorioAsistencia;
      case 'PACIENTE_ASISTIRA':
        return TipoNotificacion.pacienteAsistira;
      case 'PACIENTE_NO_ASISTIRA':
        return TipoNotificacion.pacienteNoAsistira;
      case 'TURNO_REPROGRAMADO':
        return TipoNotificacion.turnoReprogramado;
      case 'TURNO_CONFIRMADO':
        return TipoNotificacion.turnoConfirmado;
      case 'TURNO_CANCELADO_CENTRO':
        return TipoNotificacion.turnoCanceladoCentro;
      default:
        return TipoNotificacion.recordatorioAsistencia;
    }
  }

  String aTextoApi() {
    switch (this) {
      case TipoNotificacion.recordatorioAsistencia:
        return 'RECORDATORIO_ASISTENCIA';
      case TipoNotificacion.pacienteAsistira:
        return 'PACIENTE_ASISTIRA';
      case TipoNotificacion.pacienteNoAsistira:
        return 'PACIENTE_NO_ASISTIRA';
      case TipoNotificacion.turnoReprogramado:
        return 'TURNO_REPROGRAMADO';
      case TipoNotificacion.turnoConfirmado:
        return 'TURNO_CONFIRMADO';
      case TipoNotificacion.turnoCanceladoCentro:
        return 'TURNO_CANCELADO_CENTRO';
    }
  }
}

// Modelo de datos para representar una notificación en la app.
class Notificacion {
  final int id;
  final TipoNotificacion tipo;
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime fechaCreacion;
  final int? turnoId;
  final DateTime? turnoFecha;
  final String? turnoHora;
  final EstadoTurno? turnoEstado;
  final String? respuestaPaciente;

  Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.fechaCreacion,
    this.turnoId,
    this.turnoFecha,
    this.turnoHora,
    this.turnoEstado,
    this.respuestaPaciente,
  });

  // Construye una notificación desde la respuesta JSON de la API.
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    final fechaCreacionStr = json['fechaCreacion']?.toString() ?? DateTime.now().toIso8601String();
    DateTime fechaCreacionParsed;
    try {
      fechaCreacionParsed = DateTime.parse(fechaCreacionStr);
    } catch (_) {
      fechaCreacionParsed = DateTime.now();
    }

    DateTime? turnoFechaParsed;
    if (json['turnoFecha'] != null) {
      try {
        turnoFechaParsed = DateTime.parse(json['turnoFecha'].toString());
      } catch (_) {}
    }

    return Notificacion(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      tipo: TipoNotificacionExtension.desdeTexto(json['tipo']?.toString() ?? ''),
      titulo: json['titulo']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      leida: json['leida'] == true,
      fechaCreacion: fechaCreacionParsed,
      turnoId: json['turnoId'] != null ? int.tryParse(json['turnoId'].toString()) : null,
      turnoFecha: turnoFechaParsed,
      turnoHora: json['turnoHora']?.toString(),
      turnoEstado: json['turnoEstado'] != null ? EstadoTurnoExtension.desdeTexto(json['turnoEstado'].toString()) : null,
      respuestaPaciente: json['respuestaPaciente']?.toString(),
    );
  }

  // Convierte la notificación a formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.aTextoApi(),
      'titulo': titulo,
      'mensaje': mensaje,
      'leida': leida,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'turnoId': turnoId,
      'turnoFecha': turnoFecha?.toIso8601String().substring(0, 10),
      'turnoHora': turnoHora,
      'turnoEstado': turnoEstado?.aTextoApi(),
      'respuestaPaciente': respuestaPaciente,
    };
  }
}
