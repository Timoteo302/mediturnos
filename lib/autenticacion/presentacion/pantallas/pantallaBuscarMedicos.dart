import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'package:mediturnos/componentes/comunes/filtroCategoriaChip.dart';
import 'package:mediturnos/componentes/medicos/tarjetaMedico.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

import 'pantallaInicio.dart';
import 'pantallaPerfil.dart';

/// Pantalla para buscar médicos y consultar cartilla (05. Buscar médicos).
class PantallaBuscarMedicos extends StatefulWidget {
  const PantallaBuscarMedicos({super.key});

  @override
  State<PantallaBuscarMedicos> createState() => _PantallaBuscarMedicosState();
}

class _PantallaBuscarMedicosState extends State<PantallaBuscarMedicos> {
  int _indiceNavegacion = 1; // Pestaña seleccionada: "Especialistas"
  String _categoriaSeleccionada = 'Todas';

  final List<String> _categorias = ['Todas', 'Cardiología', 'Traumatología', 'Pediatría'];

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
          'Buscar médicos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de Búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, especialidad o sede...',
                prefixIcon: const Icon(Icons.search, color: ColoresApp.textoSecundario),
                suffixIcon: const Icon(Icons.tune, color: ColoresApp.textoSecundario),
              ),
            ),
            const SizedBox(height: 8),

            // Texto informativo
            Row(
              children: const [
                Icon(Icons.info_outline, size: 14, color: ColoresApp.textoSecundario),
                SizedBox(width: 4),
                Text(
                  'Filtrá por profesional de cartilla o consultorio',
                  style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fila horizontal de Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categorias.map((categoria) {
                  return FiltroCategoriaChip(
                    texto: categoria,
                    estaSeleccionado: _categoriaSeleccionada == categoria,
                    onTap: () {
                      setState(() {
                        _categoriaSeleccionada = categoria;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Encabezado de Resultados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '5 ESPECIALISTAS DISPONIBLES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: ColoresApp.primario),
                    SizedBox(width: 2),
                    Text(
                      'CABA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Ejemplo de Médico Reutilizable (Juan Manuel Gómez)
            TarjetaMedico(
              iniciales: 'JG',
              nombre: 'Dr. Juan Manuel Gómez',
              especialidad: 'Cardiología',
              sede: 'Sede Central',
              consultorio: 'Consultorio 4',
              proximoTurno: 'Hoy 15:30 hs',
              onVerDisponibilidad: () {},
            ),

            const SizedBox(height: 16),

            // Banner de soporte WhatsApp
            _construirBannerSoporte(),
          ],
        ),
      ),
      bottomNavigationBar: BarraNavegacionApp(
        indiceSeleccionado: _indiceNavegacion,
        alSeleccionar: (index) {
          // Si toca la casita de "Inicio" (índice 0)
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaInicio(),
              ),
            );
          } else if (index == 3) { // 👈 Pestaña "Mi Perfil"
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaPerfil()),
            );
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
      ),
    );
  }

  Widget _construirBannerSoporte() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: const [
          Icon(Icons.headset_mic_outlined, color: ColoresApp.primario, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Buscás otra especialidad o estudio?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Podés solicitar asistencia por turnos especiales por WhatsApp.',
                  style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}