import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import '../componentes/comunes/barraNavegacion.dart';
import '../componentes/comunes/dialogoRequiereCuenta.dart';
import '../turnos/presentacion/pantallas/pantallaBuscarMedicos.dart';
import '../turnos/presentacion/pantallas/pantallaMisTurnos.dart';
import '../perfil/presentacion/pantallas/pantallaPerfil.dart';
import '../inicio/presentacion/pantallas/pantallaInicioPaciente.dart';

/// Barra de navegación inferior reutilizable para las pantallas del paciente.
class BarraNavegacionPaciente extends StatelessWidget {
  final int indiceActual;

  const BarraNavegacionPaciente({
    super.key,
    required this.indiceActual,
  });

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AutenticacionViewModel>();

    return BarraNavegacionApp(
      indiceSeleccionado: indiceActual,
      alSeleccionar: (index) {
        if (index == indiceActual) return;

        // Si el usuario está en modo invitado e intenta acceder a Mis Turnos o Mi Perfil, desplegamos el diálogo emergente.
        if (authVm.esInvitado && (index == 2 || index == 3)) {
          DialogoRequiereCuenta.mostrar(context);
          return;
        }

        Widget pantallaDestino;
        switch (index) {
          case 0:
            pantallaDestino = const PantallaInicioPaciente();
            break;
          case 1:
            pantallaDestino = const PantallaBuscarMedicos();
            break;
          case 2:
            pantallaDestino = const PantallaMisTurnos();
            break;
          case 3:
            pantallaDestino = const PantallaPerfil();
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
