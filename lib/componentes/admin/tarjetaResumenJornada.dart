import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta de resumen operativo para la jornada actual del panel de administración.
class TarjetaResumenJornada extends StatelessWidget {
  final int turnosHoy;
  final int pendientes;
  final int medicosActivos;

  const TarjetaResumenJornada({
    super.key,
    this.turnosHoy = 28,
    this.pendientes = 5,
    this.medicosActivos = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    color: ColoresApp.primario,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Jornada de Hoy',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                    ),
                  ),
                ],
              ),
              Text(
                'Actualizado hace 2 min',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _construirMetrica(
                valor: '$turnosHoy',
                etiqueta: 'Turnos hoy',
                subetiqueta: '85% asignados',
                colorSubetiqueta: ColoresApp.primario,
              ),
              _construirDivisor(),
              _construirMetrica(
                valor: '$pendientes',
                etiqueta: 'Pendientes',
                subetiqueta: 'Por confirmar',
                colorValor: const Color(0xFFDC2626),
                colorSubetiqueta: const Color(0xFFDC2626),
              ),
              _construirDivisor(),
              _construirMetrica(
                valor: '$medicosActivos',
                etiqueta: 'Médicos activos',
                subetiqueta: 'En consultorio',
                colorSubetiqueta: ColoresApp.textoSecundario,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirMetrica({
    required String valor,
    required String etiqueta,
    required String subetiqueta,
    Color colorValor = ColoresApp.textoTitulo,
    required Color colorSubetiqueta,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 12,
              color: ColoresApp.textoSecundario,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorValor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subetiqueta,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorSubetiqueta,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirDivisor() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}