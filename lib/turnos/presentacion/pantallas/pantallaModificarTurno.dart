import 'package:flutter/material.dart';

import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'package:mediturnos/componentes/turnos/bannerInformativoReagendar.dart';
import 'package:mediturnos/componentes/turnos/selectorReprogramacionFechaHora.dart';
import 'package:mediturnos/componentes/turnos/tarjetaCancelarCita.dart';
import 'package:mediturnos/componentes/turnos/tarjetaTurnoActualAsignado.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/perfil/presentacion/pantallas/pantallaPerfil.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaBuscarMedicos.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaInicio.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaMisTurnos.dart';

/// Esta pantalla permite modificar un turno actual (reprogramar fecha y hora) o cancelarlo.
class PantallaModificarTurno extends StatefulWidget {
  const PantallaModificarTurno({super.key});

  @override
  State<PantallaModificarTurno> createState() => _PantallaModificarTurnoState();
}

class _PantallaModificarTurnoState extends State<PantallaModificarTurno> {
  int _diaSeleccionadoIndex = 0;
  String _horarioSeleccionado = '09:30 hs';
  int _indiceNavegacion = 2;

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
              'Modificar o cancelar turno',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Gestion de cita medica',
              style: TextStyle(
                fontSize: 12,
                color: ColoresApp.textoSecundario,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner informativo
            const BannerInformativoReagendar(),

            const SizedBox(height: 20),

            // 2. Turno actual asignado
            const TarjetaTurnoActualAsignado(),

            const SizedBox(height: 24),

            // 3. Selector para reprogramar fecha y hora
            SelectorReprogramacionFechaHora(
              diaSeleccionadoIndex: _diaSeleccionadoIndex,
              horarioSeleccionado: _horarioSeleccionado,
              alSeleccionarDia: (index) =>
                  setState(() => _diaSeleccionadoIndex = index),
              alSeleccionarHorario: (horario) =>
                  setState(() => _horarioSeleccionado = horario),
            ),

            const SizedBox(height: 24),

            // Botón para confirmar el nuevo horario
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioBoton,
                  foregroundColor: ColoresApp.textoBoton,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined, size: 20),
                label: const Text(
                  'Confirmar nuevo horario',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Te llegará una notificación inmediata de confirmación a tu correo.',
                style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 28),
            const Divider(color: ColoresApp.bordeCampo),
            const SizedBox(height: 20),

            // 4. Tarjeta para cancelar el turno
            TarjetaCancelarCita(
              onCancelar: () => Navigator.pop(context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BarraNavegacionApp(
        indiceSeleccionado: _indiceNavegacion,
        alSeleccionar: (index) {
          setState(() => _indiceNavegacion = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaInicio()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaMisTurnos()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaPerfil()),
            );
          }
        },
        destinos: const [
          ElementoNavegacion(
            etiqueta: 'Inicio',
            icono: Icons.home_outlined,
            iconoSeleccionado: Icons.home,
          ),
          ElementoNavegacion(
            etiqueta: 'Especialistas',
            icono: Icons.search,
            iconoSeleccionado: Icons.search,
          ),
          ElementoNavegacion(
            etiqueta: 'Mis Turnos',
            icono: Icons.calendar_today_outlined,
            iconoSeleccionado: Icons.calendar_today,
          ),
          ElementoNavegacion(
            etiqueta: 'Mi Perfil',
            icono: Icons.person_outline,
            iconoSeleccionado: Icons.person,
          ),
        ],
      ),
    );
  }
}
