import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';

// Modelo que representa el resultado exitoso (HTTP 201) al realizar una reserva como invitado.
class ResultadoReservaInvitado {
  final TurnoDetalle turno;
  final String email;
  final int venceEnDias;
  final String? codigoDemostracion;

  ResultadoReservaInvitado({
    required this.turno,
    required this.email,
    required this.venceEnDias,
    this.codigoDemostracion,
  });

  factory ResultadoReservaInvitado.fromJson(Map<String, dynamic> json) {
    return ResultadoReservaInvitado(
      turno: TurnoDetalle.fromJson(json['turno'] as Map<String, dynamic>),
      email: json['email']?.toString() ?? '',
      venceEnDias: json['venceEnDias'] is int
          ? json['venceEnDias'] as int
          : int.tryParse(json['venceEnDias']?.toString() ?? '3') ?? 3,
      codigoDemostracion: json['codigoDemostracion']?.toString(),
    );
  }
}
