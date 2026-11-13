import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/componentes/medicos/tarjetaMedico.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';

import 'pantallaSeleccionarTurno.dart';
import 'package:mediturnos/navegacion/barraNavegacionPaciente.dart';
import 'pantallaMisTurnos.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';
import '../viewmodels/buscarMedicosViewModel.dart';

/// Pantalla para buscar médicos y consultar cartilla (05. Buscar médicos).
class PantallaBuscarMedicos extends StatelessWidget {
  const PantallaBuscarMedicos({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BuscarMedicosViewModel(context.read<RepositorioMedicos>()),
      child: const _VistaBuscarMedicos(),
    );
  }
}

class _VistaBuscarMedicos extends StatefulWidget {
  const _VistaBuscarMedicos();

  @override
  State<_VistaBuscarMedicos> createState() => _VistaBuscarMedicosState();
}

class _VistaBuscarMedicosState extends State<_VistaBuscarMedicos> {
  final TextEditingController _buscarController = TextEditingController();

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BuscarMedicosViewModel>();
    final medicosVisibles = vm.visibles;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Especialistas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _buscarController,
                    onChanged: (val) => vm.buscar(val),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o especialidad...',
                      hintStyle: const TextStyle(color: ColoresApp.textoHint, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: ColoresApp.textoSecundario),
                      suffixIcon: _buscarController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: ColoresApp.textoHint),
                              onPressed: () {
                                _buscarController.clear();
                                vm.buscar('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: ColoresApp.fondoPantalla,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Todas'),
                            selected: vm.especialidadIdSeleccionada == null,
                            onSelected: (_) => vm.seleccionarEspecialidad(null),
                            selectedColor: ColoresApp.fondoIcono,
                            labelStyle: TextStyle(
                              color: vm.especialidadIdSeleccionada == null ? ColoresApp.primario : ColoresApp.textoTitulo,
                              fontWeight: vm.especialidadIdSeleccionada == null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        ...vm.especialidades.map((esp) {
                          final seleccionado = vm.especialidadIdSeleccionada == esp.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(esp.nombre),
                              selected: seleccionado,
                              onSelected: (_) => vm.seleccionarEspecialidad(esp.id),
                              selectedColor: ColoresApp.fondoIcono,
                              labelStyle: TextStyle(
                                color: seleccionado ? ColoresApp.primario : ColoresApp.textoTitulo,
                                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${vm.cantidad} ESPECIALISTAS DISPONIBLES',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoHint,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: vm.cargando
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(vm.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: () => vm.cargar(), child: const Text('Reintentar')),
                            ],
                          ),
                        )
                      : medicosVisibles.isEmpty
                          ? const Center(
                              child: Text('No encontramos médicos con esos filtros.', style: EstilosTexto.subtitulo),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: medicosVisibles.length,
                              itemBuilder: (context, index) {
                                final medico = medicosVisibles[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TarjetaMedico(
                                    iniciales: medico.iniciales,
                                    nombre: medico.nombreCompleto,
                                    especialidad: medico.especialidad.nombre,
                                    onVerDisponibilidad: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PantallaSeleccionarTurno(medico: medico),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BarraNavegacionPaciente(indiceActual: 1),
    );
  }
}
