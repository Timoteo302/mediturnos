// Aqui importamos los paquetes de Flutter necesarios para la pantalla.
import 'package:flutter/material.dart';

// Importamos los colores y estilos centralizados de la aplicacion.
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos la barra de navegacion inferior exclusiva para administradores.
import '../../../componentes/comunes/barraNavegacion.dart';

// Importamos las otras pantallas de admin para que funcione el menu inferior.
import '../../../turnos/presentacion/pantallas/pantallaInicioAdmin.dart';
import '../../../turnos/presentacion/pantallas/pantallaTodosLosTurnos.dart';
import 'pantallaAgregarMedico.dart';

// Esta pantalla muestra la lista de medicos registrados, permitiendo filtrar por activos o inactivos,
// agregar un nuevo medico, editar sus datos o desactivarlos.
// Usamos StatefulWidget porque los filtros y el estado de activo/inactivo cambian al tocar botones.
class PantallaGestionMedicos extends StatefulWidget {
  const PantallaGestionMedicos({super.key});

  @override
  State<PantallaGestionMedicos> createState() => _PantallaGestionMedicosState();
}

class _PantallaGestionMedicosState extends State<PantallaGestionMedicos> {
  
  // Aca guardamos que filtro esta seleccionado ('Todos', 'Activos' o 'Inactivos').
  String _filtroSeleccionado = 'Todos';

  // Indice de la barra de navegacion inferior (2 corresponde a 'Medicos').
  int _indiceNavegacion = 2;

  // Lista de ejemplo con los medicos de la clinica. Cada uno tiene su estado de activo o inactivo.
  final List<Map<String, dynamic>> _medicos = [
    {
      'iniciales': 'JG',
      'nombre': 'Dr. Juan Manuel Gomez',
      'matricula': 'MN 114.820',
      'especialidad': 'Cardiologia',
      'activo': true,
    },
    {
      'iniciales': 'LB',
      'nombre': 'Dra. Lucia Benitez',
      'matricula': 'MN 128.450',
      'especialidad': 'Cardiologia / Electrofisiologia',
      'activo': true,
    },
    {
      'iniciales': 'RV',
      'nombre': 'Dr. Ramiro Vaca',
      'matricula': 'MN 98.712',
      'especialidad': 'Traumatologia',
      'activo': true,
    },
    {
      'iniciales': 'MS',
      'nombre': 'Dr. Martin Soria',
      'matricula': 'MN 76.540',
      'especialidad': 'Pediatria',
      'activo': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtramos la lista segun el boton de filtro que haya elegido el administrador.
    final medicosFiltrados = _medicos.where((medico) {
      if (_filtroSeleccionado == 'Activos') return medico['activo'] == true;
      if (_filtroSeleccionado == 'Inactivos') return medico['activo'] == false;
      return true; // 'Todos'
    }).toList();

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      
      // Barra superior (AppBar) con titulo y boton de opciones
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context), // Vuelve al panel de inicio del admin
        ),
        title: const Text(
          'Gestion de medicos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
        ],
      ),

      // Cuerpo con scroll para mostrar toda la lista
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Barra de busqueda de medicos
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar medico por nombre o especialidad...',
                prefixIcon: const Icon(Icons.search, color: ColoresApp.textoSecundario),
                suffixIcon: const Icon(Icons.close, color: ColoresApp.textoSecundario),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Boton principal para agregar un nuevo medico
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Abrimos la pantalla para agregar un nuevo medico
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaAgregarMedico(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: ColoresApp.fondoIcono,
                  foregroundColor: ColoresApp.primario,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Agregar nuevo medico',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Botones de filtro (Todos, Activos, Inactivos)
            Row(
              children: [
                _construirChipFiltro('Todos (14)'),
                const SizedBox(width: 8),
                _construirChipFiltro('Activos (12)'),
                const SizedBox(width: 8),
                _construirChipFiltro('Inactivos (2)'),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Lista dinamica de tarjetas de medicos segun el filtro
            ListView.builder(
              shrinkWrap: true, // Importante para que funcione dentro de un SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Desactiva su propio scroll para usar el de la pagina
              itemCount: medicosFiltrados.length,
              itemBuilder: (context, index) {
                final medico = medicosFiltrados[index];
                return _construirTarjetaMedico(medico, index);
              },
            ),

            const SizedBox(height: 20),

            // Texto inferior que indica cuantos profesionales se muestran
            Center(
              child: Text(
                'Mostrando ${medicosFiltrados.length} de 14 profesionales registrados',
                style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Barra de navegacion inferior del Administrador
      bottomNavigationBar: _construirNavegacionInferior(context),
    );
  }

  // Widget para construir cada boton de filtro superior
  Widget _construirChipFiltro(String texto) {
    // Limpiamos el texto para comparar solo la palabra clave (ej: 'Todos', 'Activos', 'Inactivos')
    final claveFiltro = texto.split(' ')[0];
    final estaSeleccionado = _filtroSeleccionado == claveFiltro;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSeleccionado = claveFiltro;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: estaSeleccionado ? ColoresApp.primario : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: estaSeleccionado ? ColoresApp.primario : ColoresApp.bordeCampo,
          ),
        ),
        child: Row(
          children: [
            if (estaSeleccionado) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: estaSeleccionado ? Colors.white : ColoresApp.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir la tarjeta de cada medico con sus botones de Editar y Activar/Desactivar
  Widget _construirTarjetaMedico(Map<String, dynamic> medico, int index) {
    final bool esActivo = medico['activo'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              // Circulo con las iniciales del medico
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ColoresApp.fondoIcono,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    medico['iniciales'],
                    style: const TextStyle(
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre, matricula y especialidad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medico['nombre'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Matricula: ${medico['matricula']}',
                      style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColoresApp.fondoIcono,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        medico['especialidad'],
                        style: const TextStyle(fontSize: 11, color: ColoresApp.primario, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de Estado (Activo en verde o Inactivo en gris)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: esActivo ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: esActivo ? const Color(0xFF10B981) : const Color(0xFF64748B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      esActivo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: esActivo ? const Color(0xFF10B981) : const Color(0xFF64748B),
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
          const Divider(color: ColoresApp.bordeCampo, height: 1),
          const SizedBox(height: 12),

          // Botones inferiores de Editar y Desactivar / Activar
          Row(
            children: [
              // Boton Editar
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Abrimos la misma pantalla de agregar medico pero pasandole los datos para editar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaAgregarMedico(medicoAEditar: medico),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.textoTitulo,
                    side: const BorderSide(color: ColoresApp.bordeCampo),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              // Boton Desactivar (rojo) o Activar (azul) segun corresponda
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Cambiamos el estado del medico al tocar el boton
                    setState(() {
                      medico['activo'] = !esActivo;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: esActivo ? const Color(0xFFDC2626) : ColoresApp.primario,
                    side: BorderSide(
                      color: esActivo ? const Color(0xFFFCA5A5) : const Color(0xFFBFDBFE),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: Icon(
                    esActivo ? Icons.block_outlined : Icons.check_circle_outline,
                    size: 16,
                  ),
                  label: Text(
                    esActivo ? 'Desactivar' : 'Activar',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Barra de navegacion inferior del Administrador
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
        } else if (index == 1) {
          // Va a Todos los turnos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaTodosLosTurnos()),
          );
        } else if (index == 2) {
          // Ya estamos en medicos
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
