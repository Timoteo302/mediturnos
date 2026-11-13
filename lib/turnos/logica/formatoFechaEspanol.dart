/// Utilidades para formatear fechas y calcular tiempos relativos en español (sin dependencias intl).
class FormatoFechaEspanol {
  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  static const List<String> _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  static const List<String> _diasCortos = ['LUE', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

  /// Devuelve el nombre del día de la semana (ej: 'Jueves').
  static String nombreDia(DateTime fecha) {
    return _dias[fecha.weekday - 1];
  }

  /// Devuelve el día de la semana en formato corto de 3 letras (ej: 'JUE').
  static String diaSemanaCorto(DateTime fecha) {
    return _diasCortos[fecha.weekday - 1];
  }

  /// Devuelve la fecha larga formateada (ej: 'Jueves, 12 de Noviembre').
  static String fechaLarga(DateTime fecha) {
    final nombreD = nombreDia(fecha);
    final mes = _meses[fecha.month - 1];
    return '$nombreD, ${fecha.day} de $mes';
  }

  /// Devuelve la fecha corta formateada (ej: '12 Nov 2026').
  static String fechaCorta(DateTime fecha) {
    final mes = _meses[fecha.month - 1];
    final mesCorto = mes.length > 3 ? mes.substring(0, 3) : mes;
    return '${fecha.day} $mesCorto ${fecha.year}';
  }

  /// Calcula el texto de tiempo restante para un turno a partir de su fecha y hora.
  static String textoTiempoRestante(DateTime fecha, String hora) {
    final partes = hora.split(':');
    int h = partes.isNotEmpty ? int.tryParse(partes[0]) ?? 0 : 0;
    int m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;

    final ahora = DateTime.now();
    final dtTurno = DateTime(fecha.year, fecha.month, fecha.day, h, m);

    if (dtTurno.isBefore(ahora)) {
      return 'Ya pasó';
    }

    final soloHoy = DateTime(ahora.year, ahora.month, ahora.day);
    final soloTurno = DateTime(dtTurno.year, dtTurno.month, dtTurno.day);

    final diferenciaDias = soloTurno.difference(soloHoy).inDays;

    if (diferenciaDias == 0) {
      return 'Hoy';
    } else if (diferenciaDias == 1) {
      return 'Mañana';
    } else {
      return 'En $diferenciaDias días';
    }
  }
}
