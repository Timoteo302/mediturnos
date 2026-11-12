import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/medicos/selectorDiasSemanaAgenda.dart';
import '../../../componentes/medicos/tarjetaFranjaHoraria.dart';
import '../../../componentes/medicos/tarjetaParametrosAtencion.dart';
import '../../../componentes/medicos/tarjetaProfesionalAsignado.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../datos/modelos/medico.dart';
import '../../datos/repositorios/repositorioMedicos.dart';
import '../viewmodels/horariosViewModel.dart';

class PantallaGestionHorarios extends StatelessWidget {
  final Medico? medico;

  const PantallaGestionHorarios({super.key, this.medico});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HorariosViewModel(
        context.read<RepositorioMedicos>(),
        medico,
      ),
      child: const _VistaGestionHorarios(),
    );
  }
}

class _VistaGestionHorarios extends StatefulWidget {
  const _VistaGestionHorarios();

  @override
  State<_VistaGestionHorarios> createState() => _VistaGestionHorariosState();
}

class _VistaGestionHorariosState extends State<_VistaGestionHorarios> {
  void _mostrarSelectorMedicos(BuildContext context, HorariosViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seleccionar médico', style: EstilosTexto.tituloGrande),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.medicosActivos.length,
                  itemBuilder: (context, index) {
                    final m = vm.medicosActivos[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ColoresApp.fondoIcono,
                        child: Text(m.iniciales, style: const TextStyle(color: ColoresApp.primario)),
                      ),
                      title: Text(m.nombreCompleto),
                      subtitle: Text(m.especialidad.nombre),
                      onTap: () {
                        Navigator.pop(ctx);
                        vm.seleccionarMedico(m);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _agregarOEditarFranja(HorariosViewModel vm, {int? indice, TimeOfDay? inicioIni, TimeOfDay? finIni}) async {
    TimeOfDay inicio = inicioIni ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay fin = finIni ?? const TimeOfDay(hour: 12, minute: 0);

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(indice == null ? 'Agregar franja horaria' : 'Editar franja horaria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Hora de inicio'),
                    trailing: Text(
                      '${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primario),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: inicio);
                      if (picked != null) {
                        setStateDialog(() => inicio = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Hora de fin'),
                    trailing: Text(
                      '${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primario),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: fin);
                      if (picked != null) {
                        setStateDialog(() => fin = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true && mounted) {
      final inicioMin = inicio.hour * 60 + inicio.minute;
      final finMin = fin.hour * 60 + fin.minute;

      String? errorMsg;
      if (indice == null) {
        errorMsg = vm.agregarFranja(inicioMin, finMin);
      } else {
        errorMsg = vm.editarFranja(indice, inicioMin, finMin);
      }

      if (errorMsg != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _guardar(HorariosViewModel vm) async {
    final exito = await vm.guardar();
    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agenda guardada.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else if (vm.errorAccion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorAccion!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HorariosViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de horarios'),
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
                      ElevatedButton(onPressed: () => vm.cargarAgenda(vm.medicoSeleccionado!.id), child: const Text('Reintentar')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vm.medicoSeleccionado == null
                          ? TarjetaProfesionalAsignado.sinSeleccion(
                              alTocar: () => _mostrarSelectorMedicos(context, vm),
                            )
                          : TarjetaProfesionalAsignado(
                              iniciales: vm.medicoSeleccionado!.iniciales,
                              nombreCompleto: vm.medicoSeleccionado!.nombreCompleto,
                              especialidad: vm.medicoSeleccionado!.especialidad.nombre,
                            ),
                      const SizedBox(height: 20),
                      if (vm.medicoSeleccionado != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Días de atención', style: EstilosTexto.tituloGrande),
                            Text(
                              '${vm.cantidadDiasActivos} días activos',
                              style: const TextStyle(color: ColoresApp.primario, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SelectorDiasSemanaAgenda(
                          diasActivos: vm.diasActivos,
                          alAlternarDia: (dia) => vm.alternarDia(dia),
                        ),
                        const SizedBox(height: 24),
                        TarjetaParametrosAtencion(
                          duracionMinutos: vm.duracionMinutos,
                          opcionesDuracion: vm.opcionesDuracion,
                          alCambiarDuracion: (dur) => vm.cambiarDuracion(dur),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Franjas horarias', style: EstilosTexto.tituloGrande),
                            Text(
                              '${vm.cantidadFranjasActivas} activas',
                              style: const TextStyle(color: ColoresApp.primario, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (vm.agendaNoUniforme)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Text(
                              'Este médico tiene horarios distintos según el día. Al guardar, se aplicarán las mismas franjas a todos los días seleccionados.',
                              style: TextStyle(fontSize: 13, color: Colors.orange),
                            ),
                          ),
                        if (vm.franjas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text('No hay franjas horarias configuradas.', style: EstilosTexto.subtitulo),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vm.franjas.length,
                            itemBuilder: (context, index) {
                              final f = vm.franjas[index];
                              return TarjetaFranjaHoraria(
                                franja: f,
                                duracionTurno: vm.duracionMinutos,
                                onEditar: () {
                                  final iniH = f.inicioMin ~/ 60;
                                  final iniM = f.inicioMin % 60;
                                  final finH = f.finMin ~/ 60;
                                  final finM = f.finMin % 60;
                                  _agregarOEditarFranja(
                                    vm,
                                    indice: index,
                                    inicioIni: TimeOfDay(hour: iniH, minute: iniM),
                                    finIni: TimeOfDay(hour: finH, minute: finM),
                                  );
                                },
                                onEliminar: () => vm.eliminarFranja(index),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _agregarOEditarFranja(vm),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColoresApp.primario,
                              side: const BorderSide(color: ColoresApp.primario),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Agregar franja horaria', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        BotonPrincipal(
                          texto: 'Guardar configuración de horarios',
                          onPressed: () => _guardar(vm),
                          cargando: vm.guardando,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
