import '../../../../autenticacion/datos/modelos/paciente.dart';
import '../../../../medicos/datos/modelos/medico.dart';
import 'estadoTurno.dart';

// Los campos respuestaPaciente, origenPendiente y pacienteCuentaPendiente se persisten localmente en la tabla 'turnos' de SQLite a través de AlmacenTurnosLocal.
// puedeConfirmarse no se guarda en SQLite porque se calcula en tiempo real al leer el turno según la hora del dispositivo.

/// Representa el detalle completo de un turno médico con datos de paciente y médico.
class TurnoDetalle {
  final int id;
  final EstadoTurno estado;
  final DateTime fecha; // Solo fecha (año, mes, día)
  final String hora; // 'HH:mm'
  final String? claveSolicitud;
  final bool sincronizado;
  final PacienteDetalle paciente;
  final MedicoDetalle medico;
  final String? errorSincronizacion;
  final String respuestaPaciente; // "SIN_RESPUESTA", "ASISTIRA" o "NO_ASISTIRA"
  final bool puedeConfirmarse; // true si está dentro de las 24 horas previas al turno
  final bool pacienteCuentaPendiente; // true si el paciente reservó como invitado y no activó la cuenta

  TurnoDetalle({
    required this.id,
    required this.estado,
    required this.fecha,
    required this.hora,
    this.claveSolicitud,
    this.sincronizado = true,
    this.errorSincronizacion,
    required this.paciente,
    required this.medico,
    this.respuestaPaciente = 'SIN_RESPUESTA',
    this.puedeConfirmarse = false,
    this.pacienteCuentaPendiente = false,
  });

  /// Devuelve la fecha y hora combinadas en un objeto DateTime.
  DateTime get fechaHora {
    final partesHora = hora.split(':');
    int h = partesHora.isNotEmpty ? int.tryParse(partesHora[0]) ?? 0 : 0;
    int m = partesHora.length > 1 ? int.tryParse(partesHora[1]) ?? 0 : 0;
    return DateTime(fecha.year, fecha.month, fecha.day, h, m);
  }

  /// Indica si el turno pertenece al historial (atendido, cancelado o fecha anterior a hoy).
  bool get esHistorial {
    if (estado == EstadoTurno.cancelado || estado == EstadoTurno.atendido) {
      return true;
    }
    final hoy = DateTime.now();
    final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
    return fecha.isBefore(soloHoy);
  }

  /// Indica si un turno local nuevo no se pudo registrar en el servidor (tiene error de sincronización y ID negativo).
  bool get noRegistrado => errorSincronizacion != null && id < 0;

  /// Indica si el turno es próximo (pendiente o confirmado, fecha actual o futura, y no falló en el registro local).
  bool get esProximo => !esHistorial && !noRegistrado;

  factory TurnoDetalle.fromJson(Map<String, dynamic> json) {
    final fechaStr = json['fecha']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10);
    final partesFecha = fechaStr.split('-');
    final anio = partesFecha.isNotEmpty ? int.tryParse(partesFecha[0]) ?? 2026 : 2026;
    final mes = partesFecha.length > 1 ? int.tryParse(partesFecha[1]) ?? 1 : 1;
    final dia = partesFecha.length > 2 ? int.tryParse(partesFecha[2]) ?? 1 : 1;

    return TurnoDetalle(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      estado: EstadoTurnoExtension.desdeTexto(json['estado']?.toString() ?? 'PENDIENTE'),
      fecha: DateTime(anio, mes, dia),
      hora: (json['hora']?.toString() ?? '08:00').substring(0, 5),
      claveSolicitud: json['claveSolicitud']?.toString(),
      sincronizado: json['sincronizado'] ?? true,
      paciente: json['paciente'] != null
          ? PacienteDetalle.fromJson(json['paciente'])
          : PacienteDetalle(id: 0, nombre: 'Paciente', apellido: '', dni: ''),
      medico: json['medico'] != null
          ? MedicoDetalle.fromJson(json['medico'])
          : MedicoDetalle(id: 0, nombre: 'Médico', apellido: '', especialidad: EspecialidadDetalle(id: 0, nombre: 'General')),
      errorSincronizacion: json['errorSincronizacion']?.toString(),
      respuestaPaciente: json['respuestaPaciente']?.toString() ?? 'SIN_RESPUESTA',
      puedeConfirmarse: json['puedeConfirmarse'] is bool ? json['puedeConfirmarse'] as bool : false,
      pacienteCuentaPendiente: json['pacienteCuentaPendiente'] is bool ? json['pacienteCuentaPendiente'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estado': estado.aTextoApi(),
      'fecha': '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
      'hora': hora,
      'claveSolicitud': claveSolicitud,
      'sincronizado': sincronizado,
      'paciente': paciente.toJson(),
      'medico': medico.toJson(),
      'errorSincronizacion': errorSincronizacion,
      'respuestaPaciente': respuestaPaciente,
      'puedeConfirmarse': puedeConfirmarse,
      'pacienteCuentaPendiente': pacienteCuentaPendiente,
    };
  }
}

/// Detalle del paciente asociado al turno.
class PacienteDetalle {
  final int id;
  final String nombre;
  final String apellido;
  final String dni;
  final String? telefono;

  PacienteDetalle({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.dni,
    this.telefono,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory PacienteDetalle.fromJson(Map<String, dynamic> json) {
    return PacienteDetalle(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      dni: json['dni']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'apellido': apellido, 'dni': dni, 'telefono': telefono};
}

/// Detalle del médico asociado al turno.
class MedicoDetalle {
  final int id;
  final String nombre;
  final String apellido;
  final String? matricula;
  final EspecialidadDetalle especialidad;

  MedicoDetalle({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.matricula,
    required this.especialidad,
  });

  String get nombreCompleto => '$nombre $apellido';

  String get iniciales {
    if (nombre.isEmpty || apellido.isEmpty) return 'DR';
    return '${nombre[0]}${apellido[0]}'.toUpperCase();
  }

  factory MedicoDetalle.fromJson(Map<String, dynamic> json) {
    return MedicoDetalle(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      matricula: json['matricula']?.toString(),
      especialidad: json['especialidad'] != null
          ? EspecialidadDetalle.fromJson(json['especialidad'])
          : EspecialidadDetalle(id: 0, nombre: 'General'),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'apellido': apellido, 'matricula': matricula, 'especialidad': especialidad.toJson()};
}

/// Especialidad médica del médico del turno.
class EspecialidadDetalle {
  final int id;
  final String nombre;

  EspecialidadDetalle({required this.id, required this.nombre});

  factory EspecialidadDetalle.fromJson(Map<String, dynamic> json) {
    return EspecialidadDetalle(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre};
}
