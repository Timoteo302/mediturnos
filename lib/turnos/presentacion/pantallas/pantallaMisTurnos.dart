import 'package:flutter/material.dart';

import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'package:mediturnos/componentes/turnos/bannerNuevaConsulta.dart';
import 'package:mediturnos/componentes/turnos/estadoSinTurnos.dart';
import 'package:mediturnos/componentes/turnos/selectorPestanasTurnos.dart';
import 'package:mediturnos/componentes/turnos/tarjetaTurnoPaciente.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';
import 'package:mediturnos/perfil/presentacion/pantallas/pantallaPerfil.dart';
import 'package:mediturnos/turnos/datos/modelos/turno.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioTurnosImpl.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaBuscarMedicos.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaInicio.dart';

/// Pantalla "Mis Turnos" para gestionar consultas activas e historial médico.
class PantallaMisTurnos extends StatefulWidget {
  const PantallaMisTurnos({super.key});

  @override
  State<PantallaMisTurnos> createState() => _PantallaMisTurnosState();
}

class _PantallaMisTurnosState extends State<PantallaMisTurnos> {
  final RepositorioTurnosImpl _repositorio = RepositorioTurnosImpl();
  final ScrollController _scrollController = ScrollController();

  List<Turno> _turnos = [];
  bool _cargando = true;
  int _indiceNavegacion = 2;
  bool _verProximos = true;

  @override
  void initState() {
    super.initState();
    _cargarTurnos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarTurnos() async {
    final turnos = await _repositorio.obtenerTurnos();
    if (!mounted) return;
    setState(() {
      _turnos = turnos;
      _cargando = false;
    });
  }

  bool _esHistorial(Turno turno) {
    final estadoNorm = turno.estado.toLowerCase().trim();
    if (estadoNorm == 'cancelado' || estadoNorm == 'atendido') {
      return true;
    }
    final fechaDt = DateTime.tryParse(turno.fecha);
    if (fechaDt != null) {
      final fechaSolo = DateTime(fechaDt.year, fechaDt.month, fechaDt.day);
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      if (fechaSolo.isBefore(hoy)) return true;
    }
    return false;
  }

  List<Turno> get _turnosProximos {
    return _turnos.where((t) => !_esHistorial(t)).toList();
  }

  List<Turno> get _turnosHistorial {
    final historial = _turnos.where((t) => _esHistorial(t)).toList();
    historial.sort((a, b) {
      final compFecha = b.fecha.compareTo(a.fecha);
      if (compFecha != 0) return compFecha;
      return b.hora.compareTo(a.hora);
    });
    return historial;
  }

  void _irAHistorial() {
    setState(() => _verProximos = false);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _irABuscarMedicos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proximos = _turnosProximos;
    final historial = _turnosHistorial;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.health_and_safety_outlined,
                color: ColoresApp.primario, size: 22),
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
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mis turnos', style: EstilosTexto.tituloGrande),
            const SizedBox(height: 4),
            const Text(
              'Gestioná tus consultas y revisá tu historial médico',
              style: EstilosTexto.subtitulo,
            ),
            const SizedBox(height: 20),

            // Selector de pestañas (Próximos / Historial)
            SelectorPestanasTurnos(
              verProximos: _verProximos,
              cantProximos: proximos.length,
              onSeleccionarProximos: () => setState(() => _verProximos = true),
              onSeleccionarHistorial: () => setState(() => _verProximos = false),
            ),

            const SizedBox(height: 24),

            if (_cargando) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_verProximos) ...[
              // Pestaña PRÓXIMOS
              if (proximos.isEmpty) ...[
                EstadoSinTurnos(onSolicitarTurno: _irABuscarMedicos),
              ] else ...[
                ...proximos.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TarjetaTurnoPaciente(turno: t, esHistorial: false),
                    )),
              ],

              const SizedBox(height: 32),

              // Encabezado de HISTORIAL RECIENTE
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
                    onTap: _irAHistorial,
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
                        Icon(Icons.chevron_right,
                            size: 16, color: ColoresApp.primario),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (historial.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Todavía no tenés turnos en tu historial.',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else ...[
                ...historial.take(2).map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TarjetaTurnoPaciente(turno: t, esHistorial: true),
                    )),
              ],
            ] else ...[
              // Pestaña HISTORIAL
              if (historial.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Todavía no tenés turnos en tu historial.',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else ...[
                ...historial.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TarjetaTurnoPaciente(turno: t, esHistorial: true),
                    )),
              ],
            ],

            const SizedBox(height: 20),

            // Banner promocional para reservar consulta
            BannerNuevaConsulta(onReservar: _irABuscarMedicos),
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
              MaterialPageRoute(builder: (context) => const PantallaInicio()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
            ).then((_) => setState(() => _indiceNavegacion = 2));
          } else if (index == 3) {
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
      ),
    );
  }
}
