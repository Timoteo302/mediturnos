import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/turnos/avisoImportanteRevision.dart';
import 'package:mediturnos/componentes/turnos/headerReservaTemporal.dart';
import 'package:mediturnos/componentes/turnos/tarjetaResumenTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';
import 'package:mediturnos/turnos/datos/modelos/turno.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioTurnosImpl.dart';
import 'package:mediturnos/turnos/logica/casosDeUsoTurnos.dart';

/// Pantalla de confirmación y revisión final del turno (Paso 4).
class PantallaConfirmarSolicitud extends StatelessWidget {
  final DateTime fecha;
  final String hora;
  final int medicoId;

  const PantallaConfirmarSolicitud({
    super.key,
    required this.fecha,
    required this.hora,
    required this.medicoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Confirmar solicitud'),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header con temporizador de reserva
            const HeaderReservaTemporal(),

            const SizedBox(height: 16),

            // 2. Tarjeta resumen del turno
            TarjetaResumenTurno(
              hora: '$hora hs',
            ),

            const SizedBox(height: 20),

            // 3. Aviso importante de revisión
            const AvisoImportanteRevision(),

            const SizedBox(height: 24),

            // 4. Botón Principal: Confirmar solicitud
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final usuario =
                      context.read<AutenticacionViewModel>().usuarioActual;

                  final pacienteId = usuario?.paciente?.id;

                  if (pacienteId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se encontró el paciente autenticado.',
                        ),
                      ),
                    );
                    return;
                  }

                  final turno = Turno(
                    id: DateTime.now().microsecondsSinceEpoch,
                    paciente: 'Sofía Martínez',
                    medico: 'Dr. Juan Manuel Gómez',
                    especialidad: 'Cardiología',
                    fecha: fecha.toIso8601String().split('T').first,
                    hora: hora,
                    estado: 'PENDIENTE',
                    sincronizado: false,
                    pacienteId: pacienteId,
                    medicoId: medicoId,
                    claveSolicitud: const Uuid().v4(),
                  );

                  try {
                    final casosDeUso = CasosDeUsoTurnos(
                      RepositorioTurnosImpl(),
                    );

                    await casosDeUso.registrarTurno(turno);
                    if (!context.mounted) return;

                    context
                        .read<ServicioMonitoreoSincronizacion>()
                        .sincronizarAhora();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Solicitud guardada localmente. Pendiente de sincronización.',
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar la solicitud: $e'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioBoton,
                  foregroundColor: ColoresApp.textoBoton,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'Confirmar solicitud',
                  style: EstilosTexto.textoBotonPrincipal,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 5. Botón Secundario: Volver a editar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColoresApp.primario,
                  side: const BorderSide(
                    color: ColoresApp.primario,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                label: const Text(
                  'Volver a editar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primario,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 6. Nota de seguridad inferior
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: ColoresApp.textoSecundario,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tus datos médicos se procesan de forma confidencial y segura.',
                    style: TextStyle(
                      fontSize: 11,
                      color: ColoresApp.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
