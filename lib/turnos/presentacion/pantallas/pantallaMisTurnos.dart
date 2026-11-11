// Importamos los paquetes principales de Flutter
import 'package:flutter/material.dart';

// Importamos la barra de navegación inferior y configuraciones de la app
import '../../../componentes/comunes/barraNavegacion.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos otras pantallas para la navegación inferior
import 'pantallaInicio.dart';
import 'pantallaBuscarMedicos.dart';
import 'pantallaDetalleTurno.dart';
import '../../../perfil/presentacion/pantallas/pantallaPerfil.dart';
import 'package:mediturnos/componentes/turnos/dialogoCancelarTurno.dart';
import 'package:mediturnos/componentes/turnos/estadoSinTurnos.dart';

// Pantalla "Mis Turnos" para gestionar consultas activas e historial médico.
class PantallaMisTurnos extends StatefulWidget {
  const PantallaMisTurnos({super.key});

  @override
  State<PantallaMisTurnos> createState() => _PantallaMisTurnosState();
}

class _PantallaMisTurnosState extends State<PantallaMisTurnos> {
  // Índice actual para la barra de navegación inferior (Mis Turnos es la pestaña 2)
  int _indiceNavegacion = 2;

  // Variable para controlar la pestaña seleccionada ("Próximos" o "Historial")
  bool _verProximos = true;

  // Variable para evaluar si el paciente tiene turnos programados activa (true = Muestra turnos activos)
  bool _tieneTurnosProgramados = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Sin botón atrás porque es una pantalla principal de pestaña
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.health_and_safety_outlined, color: ColoresApp.primario, size: 22),
            SizedBox(width: 8),
            Text(
              'MediTurnos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),

      // Cuerpo desplazable
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y Subtítulo
            const Text(
              'Mis turnos',
              style: EstilosTexto.tituloGrande,
            ),
            const SizedBox(height: 4),
            const Text(
              'Gestioná tus consultas y revisá tu historial médico',
              style: EstilosTexto.subtitulo,
            ),

            const SizedBox(height: 20),

            // Selector de Pestañas tipo "Pill" (Próximos / Historial)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  // Pestaña Próximos
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _verProximos = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _verProximos ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: _verProximos
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Próximos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _verProximos ? ColoresApp.textoTitulo : ColoresApp.textoSecundario,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _verProximos ? ColoresApp.primario : ColoresApp.textoSecundario,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Pestaña Historial
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _verProximos = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_verProximos ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: !_verProximos
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            'Historial',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !_verProximos ? ColoresApp.textoTitulo : ColoresApp.textoSecundario,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Muestra el estado vacío si NO hay turnos, o la lista si SÍ hay turnos
            if (!_tieneTurnosProgramados) ...[
              // ❌ Sin turnos -> Muestra la tarjeta vacía que hicimos
              EstadoSinTurnos(
                onSolicitarTurno: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaBuscarMedicos(),
                    ),
                  );
                },
              ),
            ] else ...[
              // ✅ Con turnos -> Muestra las tarjetas de los turnos
              _construirTarjetaTurno(
                context,
                nombreMedico: 'Dr. Juan Manuel Gómez',
                especialidad: 'Cardiología',
                estadoTexto: 'Confirmado',
                estadoColor: const Color(0xFF10B981),
                estadoFondo: const Color(0xFFD1FAE5),
                estadoIcono: Icons.check_circle_outline,
                fechaHora: 'Jueves 24 de Octubre • 10:30 hs',
                ubicacion: 'Sede Central • Consultorio 4',
                textoBotonSecundario: 'Reprogramar',
                iconoBotonSecundario: Icons.calendar_today_outlined,
                colorBotonSecundario: ColoresApp.textoTitulo,
              ),

              const SizedBox(height: 16),

              _construirTarjetaTurno(
                context,
                nombreMedico: 'Dra. Lucía Benítez',
                especialidad: 'Cardiología',
                estadoTexto: 'Pendiente de confirmación',
                estadoColor: const Color(0xFFD97706),
                estadoFondo: const Color(0xFFFEF3C7),
                estadoIcono: Icons.access_time_rounded,
                fechaHora: 'Martes 5 de Noviembre • 15:00 hs',
                ubicacion: 'Sede Belgrano',
                textoBotonSecundario: 'Cancelar',
                iconoBotonSecundario: Icons.close,
                colorBotonSecundario: const Color(0xFFDC2626),
              ),
            ],

            const SizedBox(height: 32),

            // Sección inferior: Historial reciente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HISTORIAL RECIENTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoSecundario,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Text(
                        'Ver todo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primario,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 16, color: ColoresApp.primario),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tarjeta de Historial Reciente (Dr. Ramiro Vaca)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColoresApp.bordeCampo),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: ColoresApp.primario,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dr. Ramiro Vaca',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.textoTitulo,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Traumatología',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColoresApp.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Gris claro para Atendido
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check, size: 12, color: Color(0xFF64748B)),
                            SizedBox(width: 4),
                            Text(
                              'Atendido',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: ColoresApp.textoSecundario),
                            SizedBox(width: 8),
                            Text(
                              '12 de Septiembre de 2024',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                            ),
                          ],
                        ),
                        Text(
                          '11:15 hs',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColoresApp.textoTitulo,
                        side: const BorderSide(color: ColoresApp.bordeCampo),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 16, color: ColoresApp.textoTitulo),
                      label: const Text(
                        'Ver detalle',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Banner promocional "¿Buscás una nueva consulta?"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: ColoresApp.primario,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '¿Buscás una nueva consulta?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sacá turno con tu especialista en minutos',
                          style: TextStyle(
                            fontSize: 11,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaBuscarMedicos(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primario,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Reservar',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Barra de navegación inferior
      bottomNavigationBar: _construirNavegacionInferior(context),
    );
  }

  /// Widget reutilizable para construir cada tarjeta de turno
  Widget _construirTarjetaTurno(
    BuildContext context, {
    required String nombreMedico,
    required String especialidad,
    required String estadoTexto,
    required Color estadoColor,
    required Color estadoFondo,
    required IconData estadoIcono,
    required String fechaHora,
    required String ubicacion,
    required String textoBotonSecundario,
    required IconData iconoBotonSecundario,
    required Color colorBotonSecundario,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresApp.bordeCampo),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera de la tarjeta: Doctor e Indicador de estado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono médico circular
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ColoresApp.fondoIcono,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: ColoresApp.primario,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Nombre y especialidad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreMedico,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      especialidad,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de estado (Confirmado / Pendiente)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: estadoFondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(estadoIcono, size: 12, color: estadoColor),
                    const SizedBox(width: 4),
                    Text(
                      estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Caja interna con Fecha, Hora y Ubicación
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: ColoresApp.textoSecundario),
                    const SizedBox(width: 8),
                    Text(
                      fechaHora,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: ColoresApp.textoSecundario),
                    const SizedBox(width: 8),
                    Text(
                      ubicacion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Botones de acción inferiores (Reprogramar/Cancelar y Ver detalle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón secundario (Reprogramar o Cancelar)
              TextButton.icon(
                onPressed: () async {
                  // Si el botón es 'Cancelar', abre el diálogo modal
                  if (textoBotonSecundario == 'Cancelar') {
                    final bool? confirmo = await mostrarDialogoCancelarTurno(
                      context: context,
                      doctor: nombreMedico,
                      especialidad: especialidad,
                      fechaHora: fechaHora,
                      consultorio: ubicacion,
                    );

                    if (confirmo == true) {
                      // Se confirmó la cancelación del turno
                    }
                  }
                },
                icon: Icon(iconoBotonSecundario, size: 16, color: colorBotonSecundario),
                label: Text(
                  textoBotonSecundario,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorBotonSecundario,
                  ),
                ),
              ),

              // Botón primario "Ver detalle ->"
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaDetalleTurno(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioBoton,
                  foregroundColor: ColoresApp.textoBoton,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ver detalle',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoBoton,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye la barra de navegación inferior conectada con las demás pantallas
  Widget _construirNavegacionInferior(BuildContext context) {
    return BarraNavegacionApp(
      indiceSeleccionado: _indiceNavegacion,
      alSeleccionar: (index) {
        setState(() {
          _indiceNavegacion = index;
        });

        // Navegación según la pestaña seleccionada
        if (index == 0) {
          // Ir a Inicio
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaInicio()),
          );
        } else if (index == 1) {
          // Ir a Especialistas
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
          ).then((_) => setState(() => _indiceNavegacion = 2));
        } else if (index == 3) {
          // Ir a Mi Perfil
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaPerfil()),
          ).then((_) => setState(() => _indiceNavegacion = 2));
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
