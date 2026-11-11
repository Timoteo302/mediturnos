import 'package:flutter/material.dart';

// Importamos los colores y estilos que ya estan creados en el proyecto para mantener el mismo diseno.
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos la barra de navegacion inferior para mantener el menu abajo.
import '../../../componentes/comunes/barraNavegacion.dart';

// Importamos otras pantallas para que el menu inferior funcione bien si tocamos otro boton.
import 'pantallaInicio.dart';
import 'pantallaBuscarMedicos.dart';
import 'pantallaMisTurnos.dart';
import '../../../perfil/presentacion/pantallas/pantallaPerfil.dart';

// Esta pantalla permite modificar un turno actual (reprogramar fecha y hora) o cancelarlo.
// Usamos StatefulWidget porque necesitamos guardar que dia y que horario selecciona el usuario.
class PantallaModificarTurno extends StatefulWidget {
  const PantallaModificarTurno({super.key});

  @override
  State<PantallaModificarTurno> createState() => _PantallaModificarTurnoState();
}

class _PantallaModificarTurnoState extends State<PantallaModificarTurno> {
  
  // Aca guardamos que tarjeta de dia esta seleccionada (0 para viernes 25, 1 para lunes 28).
  int _diaSeleccionadoIndex = 0;

  // Aca guardamos el horario que el usuario elige (por ejemplo '09:30 hs' o '11:15 hs').
  String _horarioSeleccionado = '09:30 hs';

  // Indice para la barra de navegacion inferior (lo dejamos en Mis Turnos ya que venimos de ahi).
  int _indiceNavegacion = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      
      // La barra superior (AppBar) con el titulo y el boton de atras.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context), // Vuelve a la pantalla anterior cuando lo tocamos.
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

      // Todo el contenido va dentro de SingleChildScrollView para que se pueda deslizar hacia abajo si no entra en la pantalla.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Banner informativo superior (avisa que no se pierde el turno actual hasta confirmar el nuevo).
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Azul muy clarito
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: ColoresApp.primario, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Podes reagendar tu consulta sin perder la reserva vigente hasta que selecciones y confirmes un nuevo horario.',
                      style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Seccion: Turno actual asignado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today_outlined, color: ColoresApp.primario, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Turno actual asignado',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                  ],
                ),
                // Badge verde que dice Confirmado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'Confirmado',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tarjeta blanca con los datos del turno que tiene actualmente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: ColoresApp.fondoIcono,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.medical_services_outlined, color: ColoresApp.primario, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dr. Juan Manuel Gomez',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Cardiologia Clinica',
                              style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Matricula Nac. 104.920',
                              style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Caja interna con fecha y ubicacion actual
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: ColoresApp.primario),
                            SizedBox(width: 8),
                            Text(
                              'Jueves 24 de Octubre',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                            ),
                            Text(
                              '  |  ',
                              style: TextStyle(color: ColoresApp.textoSecundario),
                            ),
                            Text(
                              '10:30 hs',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: ColoresApp.textoSecundario),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Consultorio 4, Sede Central (Av. Pueyrredon 1443, CABA)',
                                style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Seccion: Reprogramar para otra fecha
            Row(
              children: const [
                Icon(Icons.refresh, color: ColoresApp.primario, size: 20),
                SizedBox(width: 8),
                Text(
                  'Reprogramar para otra fecha',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Elegi una nueva fecha y horario disponible. Si el nuevo turno no se confirma, tu turno actual seguira reservado.',
              style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
            ),

            const SizedBox(height: 16),

            // Paso 1: Seleccionar dia disponible
            const Text(
              '1. Seleccionar dia disponible',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
            ),
            const SizedBox(height: 10),

            // Fila con las dos tarjetas de dias (Viernes 25 y Lunes 28)
            Row(
              children: [
                // Tarjeta 1: Viernes 25 (Seleccionada)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _diaSeleccionadoIndex = 0; // Guardamos que eligio el dia 0
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        // Si esta seleccionado, el borde es azul. Si no, gris normal.
                        border: Border.all(
                          color: _diaSeleccionadoIndex == 0 ? ColoresApp.primario : ColoresApp.bordeCampo,
                          width: _diaSeleccionadoIndex == 0 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Mas proximo', style: TextStyle(fontSize: 11, color: ColoresApp.primario, fontWeight: FontWeight.bold)),
                              Icon(Icons.check_circle, size: 18, color: ColoresApp.primario),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Viernes 25 Octubre',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '2 cupos libres',
                            style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tarjeta 2: Lunes 28 (No seleccionada)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _diaSeleccionadoIndex = 1; // Guardamos que eligio el dia 1
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _diaSeleccionadoIndex == 1 ? ColoresApp.primario : ColoresApp.bordeCampo,
                          width: _diaSeleccionadoIndex == 1 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Semana proxima', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
                              Icon(Icons.radio_button_unchecked, size: 18, color: ColoresApp.textoSecundario),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Lunes 28 Octubre',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '3 cupos libres',
                            style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Paso 2: Horarios disponibles
            const Text(
              '2. Horarios disponibles para el Viernes 25 Octubre',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
            ),
            const SizedBox(height: 10),

            // Fila con los botones de horarios (09:30 hs y 11:15 hs)
            Row(
              children: [
                // Horario 1 (09:30 hs)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _horarioSeleccionado = '09:30 hs';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: _horarioSeleccionado == '09:30 hs' ? ColoresApp.fondoIcono : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _horarioSeleccionado == '09:30 hs' ? ColoresApp.primario : ColoresApp.bordeCampo,
                          width: _horarioSeleccionado == '09:30 hs' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.access_time, size: 18, color: ColoresApp.primario),
                              SizedBox(width: 8),
                              Text(
                                '09:30 hs',
                                style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ColoresApp.bordeCampo),
                            ),
                            child: const Text('Libre', style: TextStyle(fontSize: 10, color: ColoresApp.primario, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Horario 2 (11:15 hs)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _horarioSeleccionado = '11:15 hs';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: _horarioSeleccionado == '11:15 hs' ? ColoresApp.fondoIcono : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _horarioSeleccionado == '11:15 hs' ? ColoresApp.primario : ColoresApp.bordeCampo,
                          width: _horarioSeleccionado == '11:15 hs' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.access_time, size: 18, color: ColoresApp.textoSecundario),
                              SizedBox(width: 8),
                              Text(
                                '11:15 hs',
                                style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: ColoresApp.bordeCampo),
                            ),
                            child: const Text('Libre', style: TextStyle(fontSize: 10, color: ColoresApp.textoSecundario, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Boton azul para confirmar el nuevo horario
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aca se conectaria con la base de datos para actualizar el turno
                  // Por ahora solo volvemos atras o mostramos un mensaje
                  Navigator.pop(context);
                },
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
                'Te llegara una notificacion inmediata de confirmacion a tu correo.',
                style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 28),
            const Divider(color: ColoresApp.bordeCampo),
            const SizedBox(height: 20),

            // 4. Seccion de Cancelar este turno (Tarjeta roja clara)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                      SizedBox(width: 8),
                      Text(
                        '¿Necesitas cancelar la cita medica?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Al cancelar, el cupo quedara libre para otro paciente. Esta accion no se puede deshacer.',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  // Boton rojo para cancelar turno
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Aca iria la logica para cancelar el turno en la base de datos
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2), // Fondo rojo muy clarito
                        foregroundColor: const Color(0xFFDC2626), // Texto rojo
                        side: const BorderSide(color: Color(0xFFFCA5A5)), // Borde rojo claro
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text(
                        'Cancelar este turno',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Barra de navegacion inferior para mantener la misma estructura en todas las pantallas
      bottomNavigationBar: _construirNavegacionInferior(context),
    );
  }

  // Metodo que construye la barra de navegacion inferior y conecta los botones con las demas pantallas.
  Widget _construirNavegacionInferior(BuildContext context) {
    return BarraNavegacionApp(
      indiceSeleccionado: _indiceNavegacion,
      alSeleccionar: (index) {
        setState(() {
          _indiceNavegacion = index;
        });

        if (index == 0) {
          // Va a Inicio
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaInicio()),
          );
        } else if (index == 1) {
          // Va a Buscar Medicos (Especialistas)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
          );
        } else if (index == 2) {
          // Va a Mis Turnos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaMisTurnos()),
          );
        } else if (index == 3) {
          // Va a Mi Perfil
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
    );
  }
}
