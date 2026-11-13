import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mediturnos/navegacion/barraNavegacionPaciente.dart';
import 'package:mediturnos/componentes/turnos/bannerNuevaConsulta.dart';
import 'package:mediturnos/componentes/turnos/estadoSinTurnos.dart';
import 'package:mediturnos/componentes/turnos/selectorPestanasTurnos.dart';
import 'package:mediturnos/componentes/turnos/tarjetaTurnoPaciente.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../viewmodels/misTurnosViewModel.dart';
import 'pantallaDetalleTurno.dart';
import 'pantallaBuscarMedicos.dart';

/// Pantalla "Mis Turnos" para gestionar consultas activas e historial médico.
class PantallaMisTurnos extends StatelessWidget {
  const PantallaMisTurnos({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AutenticacionViewModel>();
    final pacienteId = authVm.usuarioActual?.paciente?.id ?? 1;

    return ChangeNotifierProvider(
      create: (context) => MisTurnosViewModel(
        context.read<RepositorioGestionTurnos>(),
        pacienteId: pacienteId,
      ),
      child: const _VistaMisTurnos(),
    );
  }
}

class _VistaMisTurnos extends StatefulWidget {
  const _VistaMisTurnos();

  @override
  State<_VistaMisTurnos> createState() => _VistaMisTurnosState();
}

class _VistaMisTurnosState extends State<_VistaMisTurnos> {
  final ScrollController _scrollController = ScrollController();
  int _indicePestana = 0; // 0 = Próximos, 1 = Historial

  Future<void> _confirmarCancelar(BuildContext context, MisTurnosViewModel vm, turno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar turno?'),
        content: const Text('¿Estás seguro de que deseas cancelar este turno? Esta acción no se puede deshacer.'),
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

    if (confirmar == true && mounted) {
      final exito = await vm.cancelar(turno);
      if (!mounted) return;
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno cancelado con éxito.'), backgroundColor: Colors.orange),
        );
      } else if (vm.errorAccion != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorAccion!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MisTurnosViewModel>();
    final turnosMostrados = _indicePestana == 0 ? vm.proximos : vm.historial;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis Turnos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  SelectorPestanasTurnos(
                    verProximos: _indicePestana == 0,
                    cantProximos: vm.cantProximos,
                    onSeleccionarProximos: () => setState(() => _indicePestana = 0),
                    onSeleccionarHistorial: () => setState(() => _indicePestana = 1),
                  ),
                  const SizedBox(height: 12),
                  BannerNuevaConsulta(
                    onReservar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
                      ).then((_) => vm.cargar());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
                      : turnosMostrados.isEmpty
                          ? SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: _indicePestana == 0
                                    ? EstadoSinTurnos(
                                        onSolicitarTurno: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
                                          ).then((_) => vm.cargar());
                                        },
                                      )
                                    : const Column(
                                        children: [
                                          SizedBox(height: 40),
                                          Text('Todavía no tenés turnos en el historial.', style: EstilosTexto.subtitulo),
                                        ],
                                      ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: turnosMostrados.length,
                              itemBuilder: (context, index) {
                                final turno = turnosMostrados[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TarjetaTurnoPaciente(
                                    turno: turno,
                                    esHistorial: _indicePestana == 1,
                                    alVerDetalle: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PantallaDetalleTurno(
                                            turno: turno,
                                            soloLectura: _indicePestana == 1,
                                          ),
                                        ),
                                      ).then((_) => vm.cargar());
                                    },
                                    alCancelar: _indicePestana == 0
                                        ? () => _confirmarCancelar(context, vm, turno)
                                        : null,
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BarraNavegacionPaciente(indiceActual: 2),
    );
  }
}
