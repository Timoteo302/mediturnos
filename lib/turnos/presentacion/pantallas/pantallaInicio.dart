import 'package:flutter/material.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/componentes/inicio/bannerUrgencia.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/inicio/tarjetaAccesoRapido.dart';
import 'package:mediturnos/componentes/inicio/tarjetaProximoTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';

import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'pantallaBuscarMedicos.dart';
import 'pantallaMisTurnos.dart';
import '../../../perfil/presentacion/pantallas/pantallaPerfil.dart';
import 'package:mediturnos/servicios/verificadorConexion.dart';

/// Pantalla principal de inicio para el paciente (03A. Inicio).
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
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
              _construirEncabezadoSuperior(),
              const SizedBox(height: 20),
              _construirSeccionSaludo(),
              const SizedBox(height: 20),
              BotonPrincipal(
                texto: '+ Solicitar turno',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaBuscarMedicos(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              const TarjetaProximoTurno(),
              const SizedBox(height: 28),
              _construirAccesosRapidos(),
              const SizedBox(height: 24),
              const BannerUrgencia(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _construirNavegacionInferior(),
    );
  }

  Widget _construirEncabezadoSuperior() {
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
                Icons.health_and_safety_outlined,
                color: ColoresApp.primario,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MediTurnos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
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

  Widget _construirSeccionSaludo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Miércoles, 23 de Octubre',
          style: TextStyle(
            fontSize: 13,
            color: ColoresApp.textoSecundario,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text('Hola, Sofía', style: EstilosTexto.tituloGrande),
        SizedBox(height: 4),
        Text(
          'Gestioná tus consultas y cuidá tu salud hoy.',
          style: EstilosTexto.subtitulo,
        ),
      ],
    );
  }

  Widget _construirAccesosRapidos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos rápidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TarjetaAccesoRapido(
              titulo: 'Mis turnos',
              subtitulo: 'Ver historial y fechas',
              icono: Icons.calendar_month_outlined,
              badgeTexto: '2 activos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaMisTurnos(),
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            TarjetaAccesoRapido(
              titulo: 'Buscar médicos',
              subtitulo: 'Por nombre o área',
              icono: Icons.person_search_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaBuscarMedicos(),
                  ),
                );
              },
            ),
          ],
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

        // Si toca la pestaña 1 ("Especialistas"), va a la pantalla de Buscar Médicos:
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
          ).then((_) => setState(() => _indiceNavegacion = 0));
        } else if (index == 2) { // 👈 Pestaña "Mis Turnos"
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaMisTurnos()),
          ).then((_) => setState(() => _indiceNavegacion = 0));
        } else if (index == 3) { // 👈 Pestaña "Mi Perfil"
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaPerfil()),
          ).then((_) => setState(() => _indiceNavegacion = 0));
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
    );
  }
}