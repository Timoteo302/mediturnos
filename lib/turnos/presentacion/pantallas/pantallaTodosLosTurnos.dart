import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:mediturnos/componentes/admin/barraSelectoresAdmin.dart';
import 'package:mediturnos/componentes/admin/chipFiltroEstadoAdmin.dart';
import 'package:mediturnos/componentes/admin/modalSelectorMedicosAdmin.dart';
import 'package:mediturnos/componentes/admin/tarjetaTurnoAdmin.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/navegacion/barraNavegacionAdmin.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';
import '../viewmodels/turnosAdminViewModel.dart';
import 'pantallaDetalleTurno.dart';

/// Esta pantalla muestra al administrador la grilla completa de todos los turnos de la clínica.
class PantallaTodosLosTurnos extends StatelessWidget {
  final EstadoTurno? filtroInicial;

  const PantallaTodosLosTurnos({super.key, this.filtroInicial});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TurnosAdminViewModel(
        context.read<RepositorioGestionTurnos>(),
        context.read<RepositorioMedicos>(),
        filtroInicial: filtroInicial,
      ),
      child: const _VistaTodosLosTurnos(),
    );
  }
}

class _VistaTodosLosTurnos extends StatefulWidget {
  const _VistaTodosLosTurnos();

  @override
  State<_VistaTodosLosTurnos> createState() => _VistaTodosLosTurnosState();
}

class _VistaTodosLosTurnosState extends State<_VistaTodosLosTurnos> {
  Future<void> _seleccionarFecha(BuildContext context, TurnosAdminViewModel vm) async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: vm.fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      await vm.cambiarFecha(seleccionada);
    }
  }

  void _mostrarDialogoLlamar(BuildContext context, TurnoDetalle turno) {
    final telefono = turno.paciente.telefono;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Llamar a ${turno.paciente.nombreCompleto}'),
        content: Text(
          telefono != null && telefono.isNotEmpty
              ? 'Teléfono de contacto:\n$telefono'
              : 'El paciente no cargó un teléfono.',
        ),
        actions: [
          if (telefono != null && telefono.isNotEmpty)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: telefono));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Teléfono copiado al portapapeles.'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Copiar'),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Future<void> _confirmarTurno(TurnosAdminViewModel vm, TurnoDetalle turno) async {
    final exito = await vm.confirmar(turno);
    if (!mounted) return;
    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno confirmado.'), backgroundColor: Colors.green),
      );
    } else if (vm.errorAccion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorAccion!), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _marcarAtendido(TurnosAdminViewModel vm, TurnoDetalle turno) async {
    final exito = await vm.marcarAtendido(turno);
    if (!mounted) return;
    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno marcado como atendido.'), backgroundColor: Colors.green),
      );
    } else if (vm.errorAccion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorAccion!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TurnosAdminViewModel>();
    final visibles = vm.visibles;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context),
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
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(vm.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: () => vm.cargarTurnos(), child: const Text('Reintentar')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarraSelectoresAdmin(
                        textoFecha: '${vm.fechaSeleccionada.day}/${vm.fechaSeleccionada.month}/${vm.fechaSeleccionada.year}',
                        textoMedico: vm.medicoSeleccionado?.nombreCompleto ?? 'Todos los médicos',
                        onTapFecha: () => _seleccionarFecha(context, vm),
                        onTapMedico: () => mostrarModalMedicosAdmin(
                          context,
                          medicoSeleccionado: vm.medicoSeleccionado,
                          medicosDisponibles: vm.medicosActivos,
                          alSeleccionar: (medico) => vm.seleccionarMedico(medico),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChipFiltroEstadoAdmin(
                              etiqueta: 'Todos',
                              cantidad: '${vm.cantTodos}',
                              seleccionado: vm.filtroEstado == 'todos',
                              onTap: () => vm.cambiarFiltroEstado('todos'),
                            ),
                            const SizedBox(width: 8),
                            ChipFiltroEstadoAdmin(
                              etiqueta: 'Pendientes',
                              cantidad: '${vm.cantPendientes}',
                              seleccionado: vm.filtroEstado == 'pendientes',
                              onTap: () => vm.cambiarFiltroEstado('pendientes'),
                            ),
                            const SizedBox(width: 8),
                            ChipFiltroEstadoAdmin(
                              etiqueta: 'Confirmados',
                              cantidad: '${vm.cantConfirmados}',
                              seleccionado: vm.filtroEstado == 'confirmados',
                              onTap: () => vm.cambiarFiltroEstado('confirmados'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mostrando ${visibles.length} de ${vm.cantTodos} registros',
                        style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                      ),
                      const SizedBox(height: 16),
                      if (vm.cantTodos == 0) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No hay turnos para esta fecha.',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                            ),
                          ),
                        ),
                      ] else if (visibles.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No hay turnos con estos filtros.',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                            ),
                          ),
                        ),
                      ] else ...[
                        ...visibles.map((turno) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TarjetaTurnoAdmin(
                              turno: turno,
                              procesando: vm.idProcesando == turno.id,
                              alConfirmar: () => _confirmarTurno(vm, turno),
                              alMarcarAtendido: () => _marcarAtendido(vm, turno),
                              alVerDetalle: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PantallaDetalleTurno(turno: turno, soloLectura: true),
                                  ),
                                ).then((_) => vm.cargarTurnos());
                              },
                              alLlamar: () => _mostrarDialogoLlamar(context, turno),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: const BarraNavegacionAdmin(indiceActual: 1),
    );
  }
}
