import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/turnos/tarjetaDoctorResumen.dart';
import '../../../componentes/turnos/carruselCalendario.dart';
import '../../../componentes/turnos/grillaHorariosTurno.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../../medicos/datos/modelos/medico.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../viewmodels/solicitudTurnoViewModel.dart';
import 'pantallaConfirmarSolicitud.dart';

/// Pantalla para seleccionar la fecha y hora de un turno con un médico (06. Seleccionar turno).
class PantallaSeleccionarTurno extends StatelessWidget {
  final Medico medico;

  const PantallaSeleccionarTurno({super.key, required this.medico});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SolicitudTurnoViewModel(
        context.read<RepositorioGestionTurnos>(),
        context.read<RepositorioMedicos>(),
        medico,
      ),
      child: _VistaSeleccionarTurno(medico: medico),
    );
  }
}

class _VistaSeleccionarTurno extends StatelessWidget {
  final Medico medico;

  const _VistaSeleccionarTurno({required this.medico});

  Future<bool> _onWillPop(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar selección?'),
        content: const Text('Si salís, perderás el horario seleccionado.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir aquí')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return confirmar ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SolicitudTurnoViewModel>();

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: ColoresApp.fondoPantalla,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
            onPressed: () async {
              if (await _onWillPop(context)) {
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            'Seleccionar Turno',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
          ),
          centerTitle: true,
        ),
        body: vm.cargandoAgenda
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TarjetaDoctorResumen(
                      nombre: medico.nombreCompleto,
                      especialidad: medico.especialidad.nombre,
                      matricula: medico.matricula,
                    ),
                    const SizedBox(height: 24),
                    const Text('Seleccioná el día', style: EstilosTexto.tituloGrande),
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
                      texto: 'Continuar',
                      onPressed: vm.horaSeleccionada == null
                          ? () {}
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider<SolicitudTurnoViewModel>.value(
                                    value: vm,
                                    child: const PantallaConfirmarSolicitud(),
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
