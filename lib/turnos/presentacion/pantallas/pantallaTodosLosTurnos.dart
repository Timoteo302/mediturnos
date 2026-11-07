// Aqui importamos los paquetes de Flutter necesarios para la pantalla.
import 'package:flutter/material.dart';

// Importamos los colores y estilos centralizados de la aplicacion.
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos la barra de navegacion inferior de administrador.
import '../../../componentes/comunes/barraNavegacion.dart';

// Importamos otras pantallas de admin para conectar el menu inferior.
import 'pantallaInicioAdmin.dart';
import '../../../medicos/presentacion/pantallas/pantallaGestionMedicos.dart';

// Esta pantalla muestra al administrador la grilla completa de todos los turnos de la clinica,
// permitiendo filtrar por estado (Todos, Pendientes, Confirmados) y gestionar la atencion.
// Usamos StatefulWidget porque los filtros cambian al tocar los botones superiores.
class PantallaTodosLosTurnos extends StatefulWidget {
  const PantallaTodosLosTurnos({super.key});

  @override
  State<PantallaTodosLosTurnos> createState() => _PantallaTodosLosTurnosState();
}

class _PantallaTodosLosTurnosState extends State<PantallaTodosLosTurnos> {
  
  // Aca guardamos el filtro de estado seleccionado ('Todos', 'Pendientes', 'Confirmados').
  String _filtroEstado = 'Todos';

  // Indice de la barra de navegacion inferior (1 corresponde a 'Turnos').
  int _indiceNavegacion = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      
      // Barra superior con subtitulo de panel, titulo y botones de filtro
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context), // Vuelve al inicio del admin
        ),
        title: Column(
          children: const [
            Text(
              'PANEL ADMINISTRADOR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ColoresApp.primario,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Todos los turnos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
        ],
      ),

      // Cuerpo con scroll para mostrar todos los turnos
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Fila superior de selectores (Fecha y Medico)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today_outlined, size: 16, color: ColoresApp.primario),
                        SizedBox(width: 6),
                        Text(
                          'Hoy: Jueves 24 Oct 2024',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                        ),
                        Icon(Icons.arrow_drop_down, size: 18, color: ColoresApp.primario),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColoresApp.bordeCampo),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_outline, size: 16, color: ColoresApp.textoSecundario),
                        SizedBox(width: 6),
                        Text(
                          'Todos',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                        ),
                        Icon(Icons.arrow_drop_down, size: 18, color: ColoresApp.textoSecundario),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Fila horizontal de chips de estado (Todos, Pendientes, Confirmados)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _construirChipEstado('Todos', '28'),
                  const SizedBox(width: 8),
                  _construirChipEstado('Pendientes', '5'),
                  const SizedBox(width: 8),
                  _construirChipEstado('Confirmados', '23'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Contador de registros y boton de orden
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Mostrando 3 de 28 registros',
                  style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                ),
                Row(
                  children: [
                    Icon(Icons.sort, size: 14, color: ColoresApp.primario),
                    SizedBox(width: 4),
                    Text(
                      'Por horario',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Tarjeta Turno 1: Confirmado (Matias E. Romero)
            _construirTarjetaTurnoAdmin(
              horaConsultorio: '09:00 hs • Consultorio 4',
              estadoTexto: 'Confirmado',
              estadoColor: const Color(0xFF10B981),
              estadoFondo: const Color(0xFFD1FAE5),
              estadoIcono: Icons.check_circle_outline,
              nombrePaciente: 'Matias E. Romero',
              dniObraSocial: 'DNI 36.782.904 • OSDE 210',
              nombreMedico: 'Dra. Gabriela Pellegrini',
              especialidadMedico: 'Cardiologia',
              inicialesMedico: 'GP',
              tipoAtencion: 'Presencial',
              textoBotonPrimario: 'Asistio',
              iconoBotonPrimario: Icons.check,
              textoBotonSecundario: 'Ver detalle',
            ),

            const SizedBox(height: 16),

            // 5. Tarjeta Turno 2: Pendiente (Martina Gomez)
            _construirTarjetaTurnoAdmin(
              horaConsultorio: '09:30 hs • Consultorio 2',
              estadoTexto: 'Pendiente',
              estadoColor: const Color(0xFFD97706),
              estadoFondo: const Color(0xFFFEF3C7),
              estadoIcono: Icons.access_time_rounded,
              nombrePaciente: 'Martina Gomez',
              dniObraSocial: 'DNI 38.412.905 • OSDE 210',
              nombreMedico: 'Dr. Ramiro Vaca',
              especialidadMedico: 'Traumatologia',
              inicialesMedico: 'RV',
              tipoAtencion: 'En espera de check-in',
              textoBotonPrimario: 'Confirmar',
              iconoBotonPrimario: Icons.check,
              textoBotonSecundario: 'Llamar',
              esLlamada: true,
            ),

            const SizedBox(height: 16),

            // 6. Tarjeta Turno 3: Cancelado (Esteban Lopez)
            _construirTarjetaTurnoAdmin(
              horaConsultorio: '10:00 hs • Consultorio 5',
              estadoTexto: 'Cancelado',
              estadoColor: const Color(0xFFDC2626),
              estadoFondo: const Color(0xFFFEF2F2),
              estadoIcono: Icons.cancel_outlined,
              nombrePaciente: 'Esteban Lopez',
              dniObraSocial: 'DNI 29.834.112 • Swiss Medical',
              nombreMedico: 'Dra. Lucia Benitez',
              especialidadMedico: 'Cardiologia',
              inicialesMedico: 'LB',
              tipoAtencion: 'Cupo liberado',
              etiquetaExtra: 'Por el paciente',
              textoBotonSecundario: 'Ver detalle',
              soloUnBoton: true,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Boton flotante inferior derecho para agregar un nuevo turno
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: ColoresApp.primarioBoton,
        elevation: 2,
        icon: const Icon(Icons.add, color: ColoresApp.textoBoton),
        label: const Text(
          'Nuevo turno',
          style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoBoton),
        ),
      ),

      // Barra de navegacion inferior de administrador con 4 pestañas y 'Turnos' seleccionado (indice 1)
      bottomNavigationBar: _construirNavegacionInferior(context),
    );
  }

  // Widget para construir los botones de filtro superior (Todos, Pendientes, Confirmados)
  Widget _construirChipEstado(String etiqueta, String cantidad) {
    final bool seleccionado = _filtroEstado == etiqueta;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroEstado = etiqueta;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? ColoresApp.textoTitulo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? ColoresApp.textoTitulo : ColoresApp.bordeCampo,
          ),
        ),
        child: Row(
          children: [
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: seleccionado ? Colors.white : ColoresApp.textoTitulo,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: seleccionado ? ColoresApp.primario : ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                cantidad,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: seleccionado ? Colors.white : ColoresApp.primario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para construir cada tarjeta de turno en la grilla del administrador
  Widget _construirTarjetaTurnoAdmin({
    required String horaConsultorio,
    required String estadoTexto,
    required Color estadoColor,
    required Color estadoFondo,
    required IconData estadoIcono,
    required String nombrePaciente,
    required String dniObraSocial,
    required String nombreMedico,
    required String especialidadMedico,
    required String inicialesMedico,
    required String tipoAtencion,
    String? etiquetaExtra,
    required String textoBotonSecundario,
    String? textoBotonPrimario,
    IconData? iconoBotonPrimario,
    bool esLlamada = false,
    bool soloUnBoton = false,
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
          
          // Fila superior: Hora y consultorio + Badge de estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: ColoresApp.primario),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        horaConsultorio,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (etiquetaExtra != null) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            etiquetaExtra,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: estadoFondo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(estadoIcono, size: 12, color: estadoColor),
                          const SizedBox(width: 3),
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
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: ColoresApp.bordeCampo, height: 1),
          const SizedBox(height: 12),

          // Informacion del paciente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18, color: ColoresApp.textoSecundario),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombrePaciente,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dniObraSocial,
                            style: const TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.receipt_long_outlined, size: 18, color: ColoresApp.textoSecundario),
            ],
          ),

          const SizedBox(height: 12),

          // Subtarjeta interna con los datos del medico y tipo de atencion
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      inicialesMedico,
                      style: const TextStyle(color: ColoresApp.primario, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreMedico,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        especialidadMedico,
                        style: const TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    tipoAtencion,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColoresApp.textoSecundario),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Botones inferiores de la tarjeta (Llamar/Ver detalle y Confirmar/Asistio)
          if (soloUnBoton) ...[
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColoresApp.textoTitulo,
                  side: const BorderSide(color: ColoresApp.bordeCampo),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  textoBotonSecundario,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: esLlamada ? ColoresApp.primario : ColoresApp.textoTitulo,
                      side: BorderSide(color: esLlamada ? ColoresApp.primario : ColoresApp.bordeCampo),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: Icon(esLlamada ? Icons.phone_outlined : Icons.visibility_outlined, size: 16),
                    label: Text(
                      textoBotonSecundario,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primarioBoton,
                      foregroundColor: ColoresApp.textoBoton,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: Icon(iconoBotonPrimario ?? Icons.check, size: 16),
                    label: Text(
                      textoBotonPrimario ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Barra de navegacion inferior del Administrador con 4 elementos (Turnos seleccionado en indice 1)
  Widget _construirNavegacionInferior(BuildContext context) {
    return BarraNavegacionApp(
      indiceSeleccionado: _indiceNavegacion,
      alSeleccionar: (index) {
        setState(() {
          _indiceNavegacion = index;
        });

        if (index == 0) {
          // Va al inicio del admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaInicioAdmin()),
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
