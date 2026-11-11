import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta informativa para mostrar solicitudes locales pendientes de sincronizar.
class TarjetaSincronizacionPendiente extends StatelessWidget {
  final String cantidadPendientes;
  final String descripcion;
  final String detalleTurno;

  const TarjetaSincronizacionPendiente({
    super.key,
    this.cantidadPendientes = '1 en espera',
    this.descripcion =
    'Guardado en el dispositivo: 1 solicitud pendiente que se sincronizará automáticamente apenas vuelva la conexión.',
    this.detalleTurno = 'Turno: Dr. Morales (Cardiología) 14 Mayo, 15:30',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_outlined,
                      color: ColoresApp.primario,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sincronización pendiente',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cantidadPendientes,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primario,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 12,
              color: ColoresApp.textoSecundario,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: ColoresApp.primario,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detalleTurno,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.textoTitulo,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}