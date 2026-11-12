import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../datos/repositorios/repositorioMedicos.dart';
import '../viewmodels/medicosViewModel.dart';
import '../../../componentes/medicos/barraAccionesGestionMedicos.dart';
import '../../../componentes/medicos/tarjetaMedicoGestion.dart';
import '../../../componentes/medicos/chipFiltroMedicos.dart';
import 'pantallaAgregarMedico.dart';
import 'pantallaGestionEspecialidades.dart';

class PantallaGestionMedicos extends StatelessWidget {
  const PantallaGestionMedicos({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicosViewModel(context.read<RepositorioMedicos>())..cargar(),
      child: const _VistaGestionMedicos(),
    );
  }
}

class _VistaGestionMedicos extends StatefulWidget {
  const _VistaGestionMedicos();

  @override
  State<_VistaGestionMedicos> createState() => _VistaGestionMedicosState();
}

class _VistaGestionMedicosState extends State<_VistaGestionMedicos> {
  final TextEditingController _buscarController = TextEditingController();

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _abrirAgregarMedico({medicoAEditar}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaAgregarMedico(medicoAEditar: medicoAEditar),
      ),
    );

    if (resultado == true && mounted) {
      context.read<MedicosViewModel>().cargar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Médico guardado.'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _abrirEspecialidades() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaGestionEspecialidades()),
    );

    if (mounted) {
      context.read<MedicosViewModel>().cargar();
    }
  }

  Future<void> _confirmarCambioEstado(MedicosViewModel vm, medico) async {
    if (medico.activo) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Desactivar médico'),
          content: Text('¿Desactivar a ${medico.nombreCompleto}? Dejará de estar disponible para nuevos turnos.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Desactivar'),
            ),
          ],
        ),
      );
      if (confirmar != true) return;
    }

    final exito = await vm.cambiarEstado(medico);
    if (!mounted) return;
    if (!exito && vm.errorAccion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorAccion!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicosViewModel>();
    final visibles = vm.visibles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de médicos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarraAccionesGestionMedicos(
              alAgregarMedico: () => _abrirAgregarMedico(),
              alAbrirEspecialidades: _abrirEspecialidades,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _buscarController,
              onChanged: (val) => vm.buscar(val),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, especialidad o matrícula',
                prefixIcon: const Icon(Icons.search, color: ColoresApp.textoSecundario),
                suffixIcon: vm.hayBusqueda
                    ? IconButton(
                        icon: const Icon(Icons.close, color: ColoresApp.textoSecundario),
                        onPressed: () {
                          _buscarController.clear();
                          vm.limpiarBusqueda();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: ColoresApp.bordeCampo),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChipFiltroMedicos(
                    texto: 'Todos (${vm.totalTodos})',
                    estaSeleccionado: vm.filtro == FiltroMedicos.todos,
                    onTap: () => vm.cambiarFiltro(FiltroMedicos.todos),
                  ),
                  const SizedBox(width: 8),
                  ChipFiltroMedicos(
                    texto: 'Activos (${vm.totalActivos})',
                    estaSeleccionado: vm.filtro == FiltroMedicos.activos,
                    onTap: () => vm.cambiarFiltro(FiltroMedicos.activos),
                  ),
                  const SizedBox(width: 8),
                  ChipFiltroMedicos(
                    texto: 'Inactivos (${vm.totalInactivos})',
                    estaSeleccionado: vm.filtro == FiltroMedicos.inactivos,
                    onTap: () => vm.cambiarFiltro(FiltroMedicos.inactivos),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                      : visibles.isEmpty
                          ? Center(
                              child: Text(
                                vm.hayBusqueda
                                    ? 'No se encontraron médicos con esa búsqueda.'
                                    : 'Todavía no hay médicos cargados.',
                                style: EstilosTexto.subtitulo,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: visibles.length,
                              itemBuilder: (context, index) {
                                final medico = visibles[index];
                                final procesando = vm.idCambiandoEstado == medico.id;
                                return TarjetaMedicoGestion(
                                  medico: medico,
                                  alEditar: () => _abrirAgregarMedico(medicoAEditar: medico),
                                  alAlternarEstado: () => _confirmarCambioEstado(vm, medico),
                                  procesando: procesando,
                                );
                              },
                            ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Mostrando ${visibles.length} de ${vm.totalTodos} profesionales registrados',
                style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
