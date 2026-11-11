class SolicitudRecuperacion {
  final String idRecuperacion;
  final int venceEnMinutos;
  final String? codigoDemostracion;

  SolicitudRecuperacion({
    required this.idRecuperacion,
    required this.venceEnMinutos,
    this.codigoDemostracion,
  });

  factory SolicitudRecuperacion.fromJson(Map<String, dynamic> json) {
    return SolicitudRecuperacion(
      idRecuperacion: json['idRecuperacion']?.toString() ?? '',
      venceEnMinutos: json['venceEnMinutos'] is int ? json['venceEnMinutos'] : int.tryParse(json['venceEnMinutos']?.toString() ?? '10') ?? 10,
      codigoDemostracion: json['codigoDemostracion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRecuperacion': idRecuperacion,
      'venceEnMinutos': venceEnMinutos,
      'codigoDemostracion': codigoDemostracion,
    };
  }
}
