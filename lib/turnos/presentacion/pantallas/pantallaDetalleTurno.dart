import 'package:flutter/material.dart';

import 'package:mediturnos/componentes/turnos/dialogoCancelarTurno.dart';
import 'package:mediturnos/componentes/turnos/tarjetaDatosPacienteTurno.dart';
import 'package:mediturnos/componentes/turnos/tarjetaEstadoReserva.dart';
import 'package:mediturnos/componentes/turnos/tarjetaIndicacionesPaciente.dart';
import 'package:mediturnos/componentes/turnos/tarjetaMedicoSede.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

import 'pantallaModificarTurno.dart';

/// Pantalla de detalle completo de un turno médico (08. Detalle del turno).
class PantallaDetalleTurno extends StatelessWidget {
  final bool soloLectura;

  const PantallaDetalleTurno({
    super.key,
    this.soloLectura = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text(
              'Detalle del turno',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'ID #TR-884920',
              style: TextStyle(
                fontSize: 12,
                color: ColoresApp.textoSecundario,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Tarjeta superior: Estado, Fecha y Reserva
            const TarjetaEstadoReserva(),

            const SizedBox(height: 16),

            // 2. Tarjeta del Médico y Sede
            const TarjetaMedicoSede(),

            const SizedBox(height: 16),

            // 3. Tarjeta de Datos del Paciente
            const TarjetaDatosPacienteTurno(),

            const SizedBox(height: 16),

            // 4. Tarjeta de Indicaciones para el Paciente
            const TarjetaIndicacionesPaciente(),

            // Acciones de modificación y cancelación (Ocultas en modo soloLectura / Historial)
            if (!soloLectura) ...[
              const SizedBox(height: 24),

              // Botón Modificar Turno
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaModificarTurno(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.primario,
                    side: const BorderSide(
                        color: ColoresApp.primario, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                  label: const Text(
                    'Modificar turno',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón Cancelar Turno
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton.icon(
                  onPressed: () async {
                    final bool? confirmoCancelacion =
                        await mostrarDialogoCancelarTurno(
                      context: context,
                      doctor: 'Dra. Gabriela Pellegrini',
                      especialidad: 'Cardiología',
                      fechaHora: 'Jueves 24 Oct · 10:30 hs',
                      consultorio: 'Consultorio 4',
                    );

                    if (confirmoCancelacion == true && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text(
                    'Cancelar turno',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Modificaciones y cancelaciones permitidas hasta el Jueves 23 de Noviembre a las 10:30 hs.',
                  style: TextStyle(
                      fontSize: 11, color: ColoresApp.textoSecundario),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
