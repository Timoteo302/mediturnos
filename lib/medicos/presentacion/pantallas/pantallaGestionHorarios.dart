// Aqui importamos los paquetes de Flutter necesarios para la pantalla.
import 'package:flutter/material.dart';

// Importamos los colores y estilos centralizados de la aplicacion.
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos la barra de navegacion inferior para administradores.
import '../../../componentes/comunes/barraNavegacion.dart';

// Importamos otras pantallas de administracion para conectar el menu inferior.
import '../../../turnos/presentacion/pantallas/pantallaInicioAdmin.dart';
import '../../../turnos/presentacion/pantallas/pantallaTodosLosTurnos.dart';
import 'pantallaGestionMedicos.dart';

// Esta pantalla permite al administrador configurar los dias de atencion, franjas horarias
// y parametros de consulta para cada medico de la clinica.
// Usamos StatefulWidget porque los dias seleccionados, duracion y cupos cambian al tocar los botones.
class PantallaGestionHorarios extends StatefulWidget {
  const PantallaGestionHorarios({super.key});

  @override
  State<PantallaGestionHorarios> createState() => _PantallaGestionHorariosState();
}

class _PantallaGestionHorariosState extends State<PantallaGestionHorarios> {
  
  // Indice de la barra de navegacion inferior (3 corresponde a 'Horarios').
  int _indiceNavegacion = 3;

  // Mapa para llevar el control de que dias de la semana estan activos (seleccionados).
  final Map<String, bool> _diasAtencion = {
    'Lunes': true,
    'Martes': false,
    'Miercoles': true,
    'Jueves': false,
    'Viernes': true,
    'Sabado': false,
  };

  // Duracion promedio de consulta seleccionada en minutos.
  int _duracionMinutos = 30;

  // Cupo de sobreturnos permitidos por jornada.
  int _cupoSobretournos = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      
      // Barra superior (AppBar) con titulo y botones de ayuda y perfil
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context), // Vuelve al panel anterior
        ),
        title: const Text(
          'Gestionar horarios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
        ],
      ),

      // Cuerpo desplazable para configurar todos los parametros
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Encabezado explicativo del panel de administracion
            const Text(
              'PANEL DE ADMINISTRACION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ColoresApp.primario, letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),
            const Text(
              'Configura la disponibilidad semanal y franjas de consulta medica.',
              style: TextStyle(fontSize: 13, color: ColoresApp.textoSecundario),
            ),

            const SizedBox(height: 20),

            // 2. Seccion: Profesional asignado
            const Text(
              'Profesional asignado',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('JG', style: TextStyle(color: ColoresApp.primario, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Dr. Juan Manuel Gomez',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cardiologia  •  Sede Central',
                          style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: ColoresApp.textoSecundario),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Seccion: Dias de atencion semanal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dias de atencion semanal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                ),
                Text(
                  '${_diasAtencion.values.where((activo) => activo).length} dias activos',
                  style: const TextStyle(fontSize: 11, color: ColoresApp.textoSecundario, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grilla o fila de dias de la semana (Lunes a Sabado)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _diasAtencion.keys.map((dia) {
                final bool activo = _diasAtencion[dia]!;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _diasAtencion[dia] = !activo; // Cambiamos el estado al tocar el dia
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: activo ? ColoresApp.fondoIcono : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: activo ? ColoresApp.primario : ColoresApp.bordeCampo,
                        width: activo ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dia,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: activo ? ColoresApp.primario : ColoresApp.textoSecundario,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          activo ? Icons.check_circle_outlined : Icons.add,
                          size: 16,
                          color: activo ? ColoresApp.primario : ColoresApp.textoSecundario,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 6),
            const Text(
              'Las franjas inferiores aplicaran a los dias seleccionados arriba.',
              style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
            ),

            const SizedBox(height: 24),

            // 4. Seccion: Franjas horarias habilitadas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Franjas horarias habilitadas',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoIcono,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '2 activas',
                    style: TextStyle(fontSize: 10, color: ColoresApp.primario, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tarjeta de Turno Manana
            _construirTarjetaFranja(
              titulo: 'Turno Manana',
              horario: '08:30 hs a 12:30 hs',
              detalle: 'Intervalo: 30 min (8 consultas posibles)',
            ),

            const SizedBox(height: 12),

            // Tarjeta de Turno Tarde
            _construirTarjetaFranja(
              titulo: 'Turno Tarde',
              horario: '14:00 hs a 18:00 hs',
              detalle: 'Intervalo: 30 min (8 consultas posibles)',
            ),

            const SizedBox(height: 14),

            // Boton para agregar nueva franja horaria
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: ColoresApp.fondoIcono,
                  foregroundColor: ColoresApp.primario,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  'Agregar franja horaria',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Seccion: Parametros de atencion
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
                      Icon(Icons.tune, color: ColoresApp.primario, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Parametros de atencion',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Duracion promedio de consulta',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),
                  const SizedBox(height: 10),

                  // Fila de opciones de duracion (15, 20, 30, 45, 60 min)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [15, 20, 30, 45, 60].map((minutos) {
                        final bool seleccionado = _duracionMinutos == minutos;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _duracionMinutos = minutos;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: seleccionado ? ColoresApp.primario : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: seleccionado ? ColoresApp.primario : ColoresApp.bordeCampo,
                              ),
                            ),
                            child: Text(
                              '$minutos min',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: seleccionado ? Colors.white : ColoresApp.textoSecundario,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: ColoresApp.bordeCampo, height: 1),
                  const SizedBox(height: 16),

                  // Control de Cupo de sobreturnos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cupo de sobreturnos',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Maximo autorizado por jornada',
                            style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                          ),
                        ],
                      ),
                      // Stepper / Contador (- y +)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColoresApp.fondoIcono.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColoresApp.bordeCampo),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16, color: ColoresApp.primario),
                              onPressed: () {
                                if (_cupoSobretournos > 0) {
                                  setState(() => _cupoSobretournos--);
                                }
                              },
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '$_cupoSobretournos turnos',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16, color: ColoresApp.primario),
                              onPressed: () {
                                setState(() => _cupoSobretournos++);
                              },
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 6. Boton principal "Guardar configuracion de horarios"
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
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
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text(
                  'Guardar configuracion de horarios',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Los cambios impactaran de inmediato en la agenda de turnos online.',
                style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Barra de navegacion inferior de administrador con 'Horarios' seleccionado (indice 3)
      bottomNavigationBar: _construirNavegacionInferior(context),
    );
  }

  // Widget reutilizable para construir cada tarjeta de franja horaria (Manana / Tarde)
  Widget _construirTarjetaFranja({required String titulo, required String horario, required String detalle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 18, color: ColoresApp.primario),
                  const SizedBox(width: 8),
                  Text(
                    titulo,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: ColoresApp.textoSecundario),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            horario,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
          ),
          const SizedBox(height: 4),
          Text(
            detalle,
            style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }

  // Metodo que construye la barra de navegacion inferior del administrador
  Widget _construirNavegacionInferior(BuildContext context) {
    return BarraNavegacionApp(
      indiceSeleccionado: 0, // Como ya no esta la pestana Horarios, no marcamos ninguna por defecto o marcamos inicio
      alSeleccionar: (index) {
        if (index == 0) {
          // Va al inicio del admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaInicioAdmin()),
          );
        } else if (index == 1) {
          // Va a Todos los turnos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaTodosLosTurnos()),
          );
        } else if (index == 2) {
          // Va a Gestion de Medicos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaGestionMedicos()),
          );
        }
      },
      destinos: const [
        ElementoNavegacion(etiqueta: 'Inicio', icono: Icons.home_outlined, iconoSeleccionado: Icons.home),
        ElementoNavegacion(etiqueta: 'Turnos', icono: Icons.calendar_today_outlined, iconoSeleccionado: Icons.calendar_today),
        ElementoNavegacion(etiqueta: 'Medicos', icono: Icons.medical_services_outlined, iconoSeleccionado: Icons.medical_services),
        ElementoNavegacion(etiqueta: 'Mi perfil', icono: Icons.person_outline, iconoSeleccionado: Icons.person),
      ],
    );
  }
}
