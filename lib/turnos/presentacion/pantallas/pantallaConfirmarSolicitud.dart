import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/turnos/tarjetaDatosPacienteTurno.dart';
import '../../../componentes/turnos/tarjetaIndicacionesPaciente.dart';
import '../../../componentes/turnos/tarjetaMedicoSede.dart';
import '../../../componentes/turnos/tarjetaResumenTurno.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../../autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import '../viewmodels/solicitudTurnoViewModel.dart';
import 'pantallaMisTurnos.dart';
import '../../datos/modelos/turnoDetalle.dart';

/// Pantalla para confirmar los datos de la solicitud de turno médico (07. Confirmar solicitud).
class PantallaConfirmarSolicitud extends StatelessWidget {
  const PantallaConfirmarSolicitud({super.key});

  Future<void> _confirmarTurno(BuildContext context) async {
    final authVm = context.read<AutenticacionViewModel>();
    final pacienteId = authVm.usuarioActual?.paciente?.id;

    if (pacienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el perfil de paciente asociado.'), backgroundColor: Colors.red),
      );
      return;
    }

    final vm = context.read<SolicitudTurnoViewModel>();
    final turno = await vm.confirmar(pacienteId);

    if (!context.mounted) return;

    if (turno != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno solicitado. Queda pendiente de confirmación.'), backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PantallaMisTurnos()),
        (route) => false,
      );
    } else if (vm.huboConflictoDeHorario) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Horario no disponible'),
          content: Text(vm.errorGeneral ?? 'Ese horario ya fue reservado. Elegí otro.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                vm.reiniciar();
                Navigator.pop(context); // Volver a seleccionar turno
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else if (vm.errorGeneral != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorGeneral!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SolicitudTurnoViewModel>();
    final authVm = context.read<AutenticacionViewModel>();
    final paciente = authVm.usuarioActual?.paciente;

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
          'Confirmar Solicitud',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen de la cita', style: EstilosTexto.tituloGrande),
            const SizedBox(height: 16),
            TarjetaResumenTurno(
              medico: MedicoDetalle.fromJson(vm.medico.toJson()),
              fecha: vm.fechaSeleccionada,
              hora: vm.horaSeleccionada ?? '00:00',
            ),
            const SizedBox(height: 16),
            TarjetaMedicoSede(medico: MedicoDetalle.fromJson(vm.medico.toJson())),
            const SizedBox(height: 16),
            TarjetaDatosPacienteTurno(
              paciente: PacienteDetalle(
                id: paciente?.id ?? 1,
                nombre: authVm.usuarioActual?.nombre ?? 'Paciente',
                apellido: authVm.usuarioActual?.apellido ?? '',
                dni: paciente?.dni ?? '00000000',
                telefono: paciente?.telefono,
              ),
            ),
            const SizedBox(height: 16),
            const TarjetaIndicacionesPaciente(),
            const SizedBox(height: 24),
            BotonPrincipal(
              texto: 'Confirmar solicitud',
              onPressed: () => _confirmarTurno(context),
              cargando: vm.guardando,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Volver a editar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
