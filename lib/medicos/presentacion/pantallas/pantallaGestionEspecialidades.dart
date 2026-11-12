import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/medicos/chipFiltroMedicos.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../datos/modelos/especialidad.dart';
import '../../datos/repositorios/repositorioMedicos.dart';
import '../viewmodels/especialidadesViewModel.dart';

class PantallaGestionEspecialidades extends StatelessWidget {
  const PantallaGestionEspecialidades({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EspecialidadesViewModel(context.read<RepositorioMedicos>())..cargar(),
      child: const _VistaGestionEspecialidades(),
    );
  }
}

class _VistaGestionEspecialidades extends StatefulWidget {
  const _VistaGestionEspecialidades();

  @override
  State<_VistaGestionEspecialidades> createState() => _VistaGestionEspecialidadesState();
}

class _VistaGestionEspecialidadesState extends State<_VistaGestionEspecialidades> {
  void _mostrarDialogoGuardar(EspecialidadesViewModel vm, {Especialidad? especialidadAEditar}) {
    showDialog(
      context: context,
      builder: (context) => _DialogoEspecialidad(
        vm: vm,
        especialidadAEditar: especialidadAEditar,
      ),
    );
  }

  Future<void> _confirmarCambioEstado(EspecialidadesViewModel vm, Especialidad especialidad) async {
    if (especialidad.activo) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Desactivar especialidad'),
          content: Text('¿Desactivar ${especialidad.nombre}? Dejará de aparecer al agregar médicos.'),
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

    final exito = await vm.cambiarEstado(especialidad);
    if (!mounted) return;
    if (!exito && vm.errorAccion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorAccion!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EspecialidadesViewModel>();
    final visibles = vm.visibles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Especialidades médicas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _mostrarDialogoGuardar(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioBoton,
                  foregroundColor: ColoresApp.textoBoton,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Agregar nueva especialidad', style: EstilosTexto.textoBotonPrincipal),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChipFiltroMedicos(
                    texto: 'Todas (${vm.totalTodas})',
                    estaSeleccionado: vm.filtro == FiltroEspecialidades.todas,
                    onTap: () => vm.cambiarFiltro(FiltroEspecialidades.todas),
                  ),
                  const SizedBox(width: 8),
                  ChipFiltroMedicos(
                    texto: 'Activas (${vm.totalActivas})',
                    estaSeleccionado: vm.filtro == FiltroEspecialidades.activas,
                    onTap: () => vm.cambiarFiltro(FiltroEspecialidades.activas),
                  ),
                  const SizedBox(width: 8),
                  ChipFiltroMedicos(
                    texto: 'Inactivas (${vm.totalInactivas})',
                    estaSeleccionado: vm.filtro == FiltroEspecialidades.inactivas,
                    onTap: () => vm.cambiarFiltro(FiltroEspecialidades.inactivas),
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
                          ? const Center(
                              child: Text('Todavía no hay especialidades.', style: EstilosTexto.subtitulo),
                            )
                          : ListView.builder(
                              itemCount: visibles.length,
                              itemBuilder: (context, index) {
                                final esp = visibles[index];
                                final procesando = vm.idProcesando == esp.id;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: ColoresApp.bordeCampo),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    esp.nombre,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: ColoresApp.textoTitulo,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: esp.activo ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    esp.activo ? 'Activa' : 'Inactiva',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: esp.activo ? Colors.green[700] : Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (esp.descripcion != null && esp.descripcion!.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                esp.descripcion!,
                                                style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 13),
                                              ),
                                            ],
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () => _mostrarDialogoGuardar(vm, especialidadAEditar: esp),
                                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                                  label: const Text('Editar'),
                                                ),
                                                const SizedBox(width: 8),
                                                procesando
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      )
                                                    : TextButton(
                                                        onPressed: () => _confirmarCambioEstado(vm, esp),
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: esp.activo ? Colors.red : Colors.green,
                                                        ),
                                                        child: Text(esp.activo ? 'Desactivar' : 'Activar'),
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoEspecialidad extends StatefulWidget {
  final EspecialidadesViewModel vm;
  final Especialidad? especialidadAEditar;

  const _DialogoEspecialidad({required this.vm, this.especialidadAEditar});

  @override
  State<_DialogoEspecialidad> createState() => _DialogoEspecialidadState();
}

class _DialogoEspecialidadState extends State<_DialogoEspecialidad> {
  late final TextEditingController nombreController;
  late final TextEditingController descripcionController;

  @override
  void initState() {
    super.initState();
    widget.vm.limpiarErroresFormulario();
    nombreController = TextEditingController(text: widget.especialidadAEditar?.nombre ?? '');
    descripcionController = TextEditingController(text: widget.especialidadAEditar?.descripcion ?? '');
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final exito = await widget.vm.guardar(
      id: widget.especialidadAEditar?.id,
      nombre: nombreController.text,
      descripcion: descripcionController.text,
    );

    if (!mounted) return;

    if (exito) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Especialidad guardada.'), backgroundColor: Colors.green),
      );
    } else if (widget.vm.errorGeneral != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.vm.errorGeneral!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return AlertDialog(
      title: Text(widget.especialidadAEditar == null ? 'Nueva especialidad' : 'Editar especialidad'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              onChanged: (_) => vm.limpiarErroresFormulario(),
              decoration: InputDecoration(
                labelText: 'Nombre *',
                hintText: 'Ej. Cardiología',
                errorText: vm.errorNombre,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              onChanged: (_) => vm.limpiarErroresFormulario(),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Breve descripción de la especialidad',
                errorText: vm.errorDescripcion,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: vm.guardando ? null : _guardar,
          child: vm.guardando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
