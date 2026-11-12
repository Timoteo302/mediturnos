import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'package:mediturnos/medicos/presentacion/pantallas/pantallaGestionMedicos.dart';
import 'package:mediturnos/perfil/presentacion/pantallas/pantallaPerfilAdmin.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaInicioAdmin.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaTodosLosTurnos.dart';

/// Componente de barra de navegación inferior compartida para la sección de administración.
class BarraNavegacionAdmin extends StatelessWidget {
  final int indiceActual;

  const BarraNavegacionAdmin({
    super.key,
    required this.indiceActual,
  });

  @override
  Widget build(BuildContext context) {
    return BarraNavegacionApp(
      indiceSeleccionado: indiceActual,
      alSeleccionar: (index) {
        if (index == indiceActual) return;

        Widget pantallaDestino;
        switch (index) {
          case 0:
            pantallaDestino = const PantallaInicioAdmin();
            break;
          case 1:
            pantallaDestino = const PantallaTodosLosTurnos();
            break;
          case 2:
            pantallaDestino = const PantallaGestionMedicos();
            break;
          case 3:
            pantallaDestino = const PantallaPerfilAdmin();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => pantallaDestino),
        );
      },
      destinos: const [
        ElementoNavegacion(
          etiqueta: 'Inicio',
          icono: Icons.home_outlined,
          iconoSeleccionado: Icons.home,
        ),
        ElementoNavegacion(
          etiqueta: 'Turnos',
          icono: Icons.calendar_today_outlined,
          iconoSeleccionado: Icons.calendar_today,
        ),
        ElementoNavegacion(
          etiqueta: 'Médicos',
          icono: Icons.medical_services_outlined,
          iconoSeleccionado: Icons.medical_services,
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
