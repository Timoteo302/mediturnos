import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/turnos/selectorDiaTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Componente para el carrusel de calendario dinámico (5 días próximos y navegación por días).
class CarruselCalendario extends StatefulWidget {
  final DateTime fechaSeleccionada;
  final ValueChanged<DateTime> alSeleccionarFecha;
  final int cantidadDiasFuturos;

  const CarruselCalendario({
    super.key,
    required this.fechaSeleccionada,
    required this.alSeleccionarFecha,
    this.cantidadDiasFuturos = 5,
  });

  @override
  State<CarruselCalendario> createState() => _CarruselCalendarioState();
}

class _CarruselCalendarioState extends State<CarruselCalendario> {
  static const List<String> _diasSemana = [
    'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'
  ];

  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  /// Abre un selector de fecha completo (DatePicker) al tocar el nombre del mes.
  Future<void> _abrirDatePickerCompleto(BuildContext context) async {
    final DateTime hoy = DateTime.now();
    final DateTime limiteMaximo = hoy.add(const Duration(days: 30));

    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: widget.fechaSeleccionada.isBefore(hoy) ? hoy : widget.fechaSeleccionada,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: limiteMaximo,
      selectableDayPredicate: (DateTime fecha) {
        return fecha.weekday != DateTime.sunday;
      },
      helpText: 'SELECCIONÁ UNA FECHA DE CONSULTA',
      cancelText: 'CANCELAR',
      confirmText: 'SELECCIONAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColoresApp.primario,
              onPrimary: Colors.white,
              onSurface: ColoresApp.textoTitulo,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaElegida != null) {
      widget.alSeleccionarFecha(fechaElegida);
    }
  }

  /// Desplaza los días del carrusel hacia adelante o hacia atrás.
  void _desplazarDias(int dias) {
    final DateTime hoy = DateTime.now();
    final DateTime fechaBase = DateTime(hoy.year, hoy.month, hoy.day);
    final DateTime limiteMaximo = fechaBase.add(const Duration(days: 30));

    final DateTime nuevaFecha = widget.fechaSeleccionada.add(Duration(days: dias));

    if (nuevaFecha.isBefore(fechaBase)) {
      widget.alSeleccionarFecha(fechaBase);
      return;
    }
    if (nuevaFecha.isAfter(limiteMaximo)) {
      return;
    }

    widget.alSeleccionarFecha(nuevaFecha);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime hoy = DateTime.now();
    final DateTime fechaBase = DateTime(
      widget.fechaSeleccionada.year,
      widget.fechaSeleccionada.month,
      widget.fechaSeleccionada.day,
    );

    final String mesAnoHeader =
        '${_meses[widget.fechaSeleccionada.month - 1]} ${widget.fechaSeleccionada.year}';

    final bool esHoy = widget.fechaSeleccionada.year == hoy.year &&
        widget.fechaSeleccionada.month == hoy.month &&
        widget.fechaSeleccionada.day == hoy.day;

    final DateTime limiteMaximo = hoy.add(const Duration(days: 30));
    final bool esLimiteMaximo = widget.fechaSeleccionada.isAfter(limiteMaximo);

    return Column(
      children: [
        // Encabezado con Mes (cliqueable) y flechas < >
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _abrirDatePickerCompleto(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: ColoresApp.primario,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mesAnoHeader,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: ColoresApp.primario,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: esHoy ? ColoresApp.textoHint : ColoresApp.textoSecundario,
                  ),
                  onPressed: esHoy ? null : () => _desplazarDias(-5),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: esLimiteMaximo ? ColoresApp.textoHint : ColoresApp.textoSecundario,
                  ),
                  onPressed: esLimiteMaximo ? null : () => _desplazarDias(5),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Carrusel compacto de 5 días
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.cantidadDiasFuturos, (index) {
              final DateTime fecha = fechaBase.add(Duration(days: index));
              final String nombreDia = _diasSemana[fecha.weekday - 1];
              final String numeroDia = '${fecha.day}';

              final bool esDomingo = fecha.weekday == DateTime.sunday;
              final bool esMismaFecha =
                  widget.fechaSeleccionada.year == fecha.year &&
                      widget.fechaSeleccionada.month == fecha.month &&
                      widget.fechaSeleccionada.day == fecha.day;

              final bool esHoyDia = hoy.year == fecha.year &&
                  hoy.month == fecha.month &&
                  hoy.day == fecha.day;

              String infoDisponibilidad = '3 disp.';
              if (esDomingo) {
                infoDisponibilidad = 'Sin turnos';
              } else if (index % 3 == 0) {
                infoDisponibilidad = '1 disp.';
              } else if (index % 2 == 0) {
                infoDisponibilidad = '4 disp.';
              }

              return SelectorDiaTurno(
                diaSemana: esHoyDia ? 'Hoy' : nombreDia,
                numeroDia: numeroDia,
                infoDisponibilidad: infoDisponibilidad,
                estaSeleccionado: esMismaFecha,
                estaHabilitado: !esDomingo,
                onTap: () => widget.alSeleccionarFecha(fecha),
              );
            }),
          ),
        ),
      ],
    );
  }
}
