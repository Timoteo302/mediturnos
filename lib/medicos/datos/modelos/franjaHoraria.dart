class FranjaHoraria {
  final int inicioMin; // minutos desde medianoche
  final int finMin; // minutos desde medianoche

  FranjaHoraria({required this.inicioMin, required this.finMin});

  static int horaMinutosAEntero(String horaMm) {
    final partes = horaMm.split(':');
    if (partes.length < 2) return 0;
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  static String enteroAHoraMinutos(int totalMin) {
    int h = totalMin ~/ 60;
    int m = totalMin % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String get texto {
    return '${enteroAHoraMinutos(inicioMin)} a ${enteroAHoraMinutos(finMin)}';
  }

  String get etiqueta {
    if (inicioMin < 13 * 60) {
      return 'Turno mañana';
    } else if (inicioMin < 20 * 60) {
      return 'Turno tarde';
    } else {
      return 'Turno noche';
    }
  }

  int consultasPosibles(int duracionTurno) {
    if (duracionTurno <= 0) return 0;
    int diferencia = finMin - inicioMin;
    if (diferencia <= 0) return 0;
    return diferencia ~/ duracionTurno;
  }
}
