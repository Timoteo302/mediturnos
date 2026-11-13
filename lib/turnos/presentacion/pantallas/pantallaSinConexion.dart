import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/comunes/tarjetaSincronizacionPendiente.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/perfil/presentacion/pantallas/pantallaPerfil.dart';
import 'package:mediturnos/servicios/verificadorConexion.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaBuscarMedicos.dart';
import 'package:mediturnos/inicio/presentacion/pantallas/pantallaInicioPaciente.dart';

// Pantalla que informa la falta de conexión a internet (17. Estado: Sin conexión).
class PantallaSinConexion extends StatefulWidget {
  const PantallaSinConexion({super.key});

  @override
  State<PantallaSinConexion> createState() => _PantallaSinConexionState();
}

class _PantallaSinConexionState extends State<PantallaSinConexion> {
  int _indiceNavegacion = 2;

  Future<void> _probarReconexion() async {
  final bool estaConectado = await VerificadorConexion.tieneConexionReal();

  if (!mounted) return;

  if (estaConectado) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Conexión a internet restablecida!'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
    // 👈 Vuelve a la pantalla exacta donde estaba el usuario antes del corte
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sigue sin conexión a internet. Verificá tu Wi-Fi o Datos.'),
        backgroundColor: Color(0xFFDC2626),
      ),
    );
  }
}

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
        title: const Text(
          'MediTurnos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, size: 14, color: Color(0xFFDC2626)),
                  SizedBox(width: 4),
                  Text(
                    'Sin conexión',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _construirIconoEncabezado(),
            const SizedBox(height: 20),
            const Text(
              'Sin conexión a internet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No pudimos comunicarnos con el servidor. Revisá tu conexión wifi o datos móviles e intentá nuevamente. Tus datos y turnos guardados previamente siguen disponibles en tu teléfono.',
              style: TextStyle(
                fontSize: 13,
                color: ColoresApp.textoSecundario,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const TarjetaSincronizacionPendiente(),
            const SizedBox(height: 24),

            // Botón: Intentar nuevamente (Prueba si volvió la conexión)
            BotonPrincipal(
              texto: 'Intentar nuevamente',
              onPressed: _probarReconexion,
            ),

            const SizedBox(height: 12),

            // Botón: Continuar sin conexión (Sigue navegando en la app localmente)
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: ColoresApp.primario,
              ),
              label: const Text(
                'Continuar sin conexión',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primario,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
              MaterialPageRoute(builder: (context) => const PantallaInicioPaciente()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaPerfil()),
            );
          }
        },
        destinos: const [
          ElementoNavegacion(etiqueta: 'Inicio', icono: Icons.home_outlined, iconoSeleccionado: Icons.home),
          ElementoNavegacion(etiqueta: 'Especialistas', icono: Icons.search, iconoSeleccionado: Icons.search),
          ElementoNavegacion(etiqueta: 'Mis Turnos', icono: Icons.calendar_today_outlined, iconoSeleccionado: Icons.calendar_today),
          ElementoNavegacion(etiqueta: 'Mi Perfil', icono: Icons.person_outline, iconoSeleccionado: Icons.person),
        ],
      ),
    );
  }

  Widget _construirIconoEncabezado() {
    return Center(
      child: Container(
        width: 110,
        height: 110,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F3FF),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.wifi_off_rounded,
          color: ColoresApp.primario,
          size: 52,
        ),
      ),
    );
  }
}
