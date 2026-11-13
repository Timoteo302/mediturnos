import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/turnos/tarjetaDatosPacienteTurno.dart';
import '../../../componentes/turnos/tarjetaEstadoReserva.dart';
import '../../../componentes/turnos/tarjetaIndicacionesPaciente.dart';
import '../../../componentes/turnos/tarjetaMedicoSede.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../datos/modelos/estadoTurno.dart';
import '../../datos/modelos/turnoDetalle.dart';
import '../../datos/repositorios/repositorioGestionTurnos.dart';
import '../viewmodels/detalleTurnoViewModel.dart';
import 'pantallaModificarTurno.dart';

/// Pantalla para ver el detalle completo de un turno médico (08. Detalle del turno).
class PantallaDetalleTurno extends StatelessWidget {
  final TurnoDetalle turno;
  final bool soloLectura;

  const PantallaDetalleTurno({
    super.key,
    required this.turno,
    this.soloLectura = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DetalleTurnoViewModel(
        context.read<RepositorioGestionTurnos>(),
        turno,
      ),
      child: _VistaDetalleTurno(soloLectura: soloLectura),
    );
  }
}

class _VistaDetalleTurno extends StatelessWidget {
  final bool soloLectura;

  const _VistaDetalleTurno({required this.soloLectura});

  Future<void> _confirmarCancelar(BuildContext context, DetalleTurnoViewModel vm) async {
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
      } else if (vm.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleTurnoViewModel>();
    final t = vm.turno;
    final bool ocultarAcciones = soloLectura || t.estado == EstadoTurno.cancelado || t.estado == EstadoTurno.atendido;

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
          'Detalle del Turno',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TarjetaEstadoReserva(turno: t),
            const SizedBox(height: 16),
            TarjetaMedicoSede(medico: t.medico),
            const SizedBox(height: 16),
            TarjetaDatosPacienteTurno(paciente: t.paciente),
            const SizedBox(height: 16),
            const TarjetaIndicacionesPaciente(),
            if (!ocultarAcciones) ...[
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: 'Modificar turno',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaModificarTurno(turno: t),
                    ),
                  ).then((resultado) {
                    if (resultado == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  });
                },
                cargando: vm.procesando,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: vm.procesando ? null : () => _confirmarCancelar(context, vm),
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
          ],
        ),
      ),
    );
  }
}
