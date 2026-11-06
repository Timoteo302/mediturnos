import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Modelo de datos para definir cada pestaña de la barra de navegación.
class ElementoNavegacion {
  final String etiqueta;
  final IconData icono;
  final IconData iconoSeleccionado;

  const ElementoNavegacion({
    required this.etiqueta,
    required this.icono,
    required this.iconoSeleccionado,
  });
}

/// Componente de barra de navegación inferior reutilizable para la aplicación.
class BarraNavegacionApp extends StatelessWidget {
  final int indiceSeleccionado;
  final List<ElementoNavegacion> destinos;
  final ValueChanged<int> alSeleccionar;

  const BarraNavegacionApp({
    super.key,
    required this.indiceSeleccionado,
    required this.destinos,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: const Color(0xFFE8F3FF),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ColoresApp.primario,
            );
          }
          return const TextStyle(
            fontSize: 11,
            color: ColoresApp.textoSecundario,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: indiceSeleccionado,
        onDestinationSelected: alSeleccionar,
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: destinos.map((destino) {
          return NavigationDestination(
            icon: Icon(destino.icono, color: ColoresApp.textoSecundario),
            selectedIcon: Icon(destino.iconoSeleccionado, color: ColoresApp.primario),
            label: destino.etiqueta,
          );
        }).toList(),
      ),
    );
  }
}