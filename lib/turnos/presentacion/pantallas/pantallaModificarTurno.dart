import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/indicadorConexion.dart';
import '../../../componentes/comunes/notificacionApp.dart';
import '../../../componentes/turnos/carruselCalendario.dart';
import '../../../componentes/turnos/grillaHorariosTurno.dart';
import '../../../componentes/turnos/tarjetaTurnoActualAsignado.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../../medicos/datos/modelos/medico.dart';
import '../../../medicos/datos/modelos/especialidad.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../viewmodels/modificarTurnoViewModel.dart';

/// Pantalla para modificar la fecha y hora de un turno existente (10. Modificar turno).
class PantallaModificarTurno extends StatelessWidget {
  final TurnoDetalle turno;

  const PantallaModificarTurno({super.key, required this.turno});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModificarTurnoViewModel(
        context.read<RepositorioGestionTurnos>(),
        context.read<RepositorioMedicos>(),
        turno,
        Medico(
          id: turno.medico.id,
          nombre: turno.medico.nombre,
          apellido: turno.medico.apellido,
          matricula: turno.medico.matricula,
          activo: true,
          especialidad: Especialidad(id: turno.medico.especialidad.id, nombre: turno.medico.especialidad.nombre, activo: true),
        ),
      ),
      child: _VistaModificarTurno(turno: turno),
    );
  }
}

class _VistaModificarTurno extends StatelessWidget {
  final TurnoDetalle turno;

  const _VistaModificarTurno({required this.turno});

  // Guarda la modificación del turno. Si estaba confirmado, muestra un aviso previo antes de enviar.
  Future<void> _guardar(BuildContext context, ModificarTurnoViewModel vm) async {
    if (turno.estado == EstadoTurno.confirmado) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Cambiar un turno confirmado?'),
          content: const Text(
            'Si lo cambiás, el turno vuelve a quedar pendiente hasta que el centro lo confirme de nuevo y el horario actual queda libre.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Volver'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, cambiar'),
            ),
          ],
        ),
      );
      if (confirmar != true) return;
    }

    final exito = await vm.guardar();
    if (!context.mounted) return;

    if (exito) {
      mostrarNotificacionApp(
        context,
        tipo: TipoNotificacionApp.exito,
        titulo: 'Turno reprogramado',
        mensaje: 'Queda pendiente hasta que el centro lo confirme.',
      );
      Navigator.pop(context, true);
    } else if (vm.errorGeneral != null) {
      mostrarNotificacionApp(
        context,
        tipo: TipoNotificacionApp.error,
        titulo: 'Error',
        mensaje: vm.errorGeneral!,
      );
    }
  }

  Future<void> _cancelarTurno(BuildContext context, ModificarTurnoViewModel vm) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar turno?'),
        content: const Text('¿Estás seguro de que deseas cancelar este turno?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Volver')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final exito = await vm.cancelar();
      if (!context.mounted) return;
      if (exito) {
        Navigator.pop(context, true);
      } else if (vm.errorGeneral != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorGeneral!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ModificarTurnoViewModel>();

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
          'Modificar Turno',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
        ),
        centerTitle: true,
        actions: const [IndicadorConexion()],
      ),
      body: vm.cargandoAgenda
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TarjetaTurnoActualAsignado(turno: turno),
                  const SizedBox(height: 24),
                  const Text('Seleccioná la nueva fecha', style: EstilosTexto.tituloGrande),
                  const SizedBox(height: 12),
                  CarruselCalendario(
                    fechaSeleccionada: vm.fechaSeleccionada,
                    diasHabilitados: vm.diasConAtencion,
                    alSeleccionarFecha: (nuevaFecha) => vm.cargarDisponibilidad(nuevaFecha),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Horarios para el ${vm.fechaSeleccionada.day}/${vm.fechaSeleccionada.month}/${vm.fechaSeleccionada.year}',
                    style: EstilosTexto.tituloGrande,
                  ),
                  const SizedBox(height: 12),
                  GrillaHorariosTurno(
                    horarios: vm.horariosDisponibles,
                    horaSeleccionada: vm.horaSeleccionada,
                    cargando: vm.cargandoHorarios,
                    alSeleccionarHora: (hora) => vm.seleccionarHora(hora),
                  ),
                  if (vm.errorGeneral != null) ...[
                    const SizedBox(height: 16),
                    Text(vm.errorGeneral!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 32),
                  BotonPrincipal(
                    texto: 'Guardar cambios',
                    onPressed: vm.puedeGuardar
                        ? () => _guardar(context, vm)
                        : () {
                            if (vm.horaSeleccionada == null) {
                              mostrarNotificacionApp(
                                context,
                                tipo: TipoNotificacionApp.error,
                                titulo: 'Elegí un horario',
                                mensaje: 'Seleccioná un horario disponible para continuar.',
                              );
                            }
                          },
                    cargando: vm.guardando,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: vm.guardando ? null : () => _cancelarTurno(context, vm),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('Cancelar turno'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
