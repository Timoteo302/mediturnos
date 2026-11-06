import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/admin/tarjetaAccionAdmin.dart';
import 'package:mediturnos/componentes/admin/tarjetaResumenJornada.dart';
import 'package:mediturnos/componentes/admin/tarjetaTurnoPendiente.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';

import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import '../../../autenticacion/presentacion/pantallas/pantallaLogin.dart';


/// Pantalla principal de inicio para el Administrador (03B. Inicio Admin).
class PantallaInicioAdmin extends StatefulWidget {
  const PantallaInicioAdmin({super.key});

  @override
  State<PantallaInicioAdmin> createState() => _PantallaInicioAdminState();
}

class _PantallaInicioAdminState extends State<PantallaInicioAdmin> {
  int _indiceNavegacion = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirEncabezadoAdmin(),
              const SizedBox(height: 20),
              _construirTituloPanel(),
              const SizedBox(height: 20),
              const TarjetaResumenJornada(),
              const SizedBox(height: 24),
              _construirSeccionAcciones(),
              const SizedBox(height: 24),
              _construirSeccionPendientes(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _construirNavegacionInferior(),
    );
  }

  Widget _construirEncabezadoAdmin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: ColoresApp.primario,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'MediTurnos Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                Text(
                  'Panel de Administración',
                  style: TextStyle(
                    fontSize: 11,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: ColoresApp.primario,
                size: 26,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: ColoresApp.primario,
                size: 26,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaLogin(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirTituloPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Panel de Gestión - Clínica San Lucas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Resumen operativo y control de agendas en tiempo real.',
          style: EstilosTexto.subtitulo,
        ),
      ],
    );
  }

  Widget _construirSeccionAcciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones directas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 12),
        TarjetaAccionAdmin(
          titulo: 'Ver todos los turnos',
          subtitulo:
          'Consultá la grilla completa, reprogramaciones y cancelaciones del día.',
          icono: Icons.grid_view_rounded,
          infoPie: '23 confirmados • 5 en espera',
          textoEnlace: 'Abrir grilla >',
          esBannerAncho: true,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TarjetaAccionAdmin(
              titulo: 'Gestionar médicos',
              subtitulo: 'Nómina de especialistas y disponibilidad diaria.',
              icono: Icons.medical_services_outlined,
              infoPie: '14 registros',
              onTap: () {},
            ),
            const SizedBox(width: 12),
            TarjetaAccionAdmin(
              titulo: 'Gestionar horarios',
              subtitulo: 'Configuración de franjas y días de atención.',
              icono: Icons.access_time_outlined,
              infoPie: '8 consultorios',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirSeccionPendientes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Próximos turnos a confirmar hoy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Ver pendientes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primario,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TarjetaTurnoPendiente(
          iniciales: 'MG',
          nombrePaciente: 'Martina Gómez',
          dniObraSocial: 'DNI: 38.412.905 • OSDE 210',
          medicoEspecialidad: 'Dr. Ramiro Vaca • Traumatología',
          horaConsultorio: '10:30 hs (Cons. 2)',
          onLlamar: () {},
          onRevisar: () {},
        ),
        TarjetaTurnoPendiente(
          iniciales: 'EL',
          nombrePaciente: 'Esteban López',
          dniObraSocial: 'DNI: 29.834.112 • Swiss Medical',
          medicoEspecialidad: 'Dra. Lucía Benítez • Cardiología',
          horaConsultorio: '11:15 hs (Cons. 5)',
          onLlamar: () {},
          onRevisar: () {},
        ),
      ],
    );
  }

  Widget _construirNavegacionInferior() {
    return BarraNavegacionApp(
      indiceSeleccionado: _indiceNavegacion,
      alSeleccionar: (index) {
        setState(() {
          _indiceNavegacion = index;
        });
      },
      destinos: const [
        ElementoNavegacion(
          etiqueta: 'Inicio',
          icono: Icons.home_outlined,
          iconoSeleccionado: Icons.home,
        ),
        ElementoNavegacion(
          etiqueta: 'Todos los turnos',
          icono: Icons.calendar_today_outlined,
          iconoSeleccionado: Icons.calendar_today,
        ),
        ElementoNavegacion(
          etiqueta: 'Médicos',
          icono: Icons.medical_services_outlined,
          iconoSeleccionado: Icons.medical_services,
        ),
        ElementoNavegacion(
          etiqueta: 'Horarios',
          icono: Icons.access_time_outlined,
          iconoSeleccionado: Icons.access_time,
        ),
        ElementoNavegacion(
          etiqueta: 'Mi perfil',
          icono: Icons.person_outline,
          iconoSeleccionado: Icons.person,
        ),
      ],
    );
  }
}