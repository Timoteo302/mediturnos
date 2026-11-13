import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/componentes/inicio/bannerUrgencia.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/inicio/tarjetaAccesoRapido.dart';
import 'package:mediturnos/componentes/inicio/tarjetaProximoTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';

import 'package:mediturnos/navegacion/barraNavegacionPaciente.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaBuscarMedicos.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaMisTurnos.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaDetalleTurno.dart';
import 'package:mediturnos/turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'package:mediturnos/turnos/logica/formatoFechaEspanol.dart';
import '../viewmodels/inicioPacienteViewModel.dart';

/// Pantalla principal de inicio para el paciente (03A. Inicio).
class PantallaInicioPaciente extends StatelessWidget {
  const PantallaInicioPaciente({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AutenticacionViewModel>();
    final pacienteId = authVm.usuarioActual?.paciente?.id ?? 1;
    final nombre = authVm.usuarioActual?.nombre ?? 'Paciente';

    return ChangeNotifierProvider(
      create: (context) => InicioPacienteViewModel(
        context.read<RepositorioGestionTurnos>(),
        pacienteId: pacienteId,
        nombreUsuario: nombre,
      ),
      child: const _VistaInicioPaciente(),
    );
  }
}

class _VistaInicioPaciente extends StatelessWidget {
  const _VistaInicioPaciente();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InicioPacienteViewModel>();

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      body: SafeArea(
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirEncabezadoSuperior(context),
                        const SizedBox(height: 20),
                        _construirSeccionSaludo(context, vm),
                        const SizedBox(height: 20),
                        BotonPrincipal(
                          texto: '+ Solicitar turno',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PantallaBuscarMedicos(),
                              ),
                            ).then((_) => vm.cargar());
                          },
                        ),
                        const SizedBox(height: 28),
                        TarjetaProximoTurno(
                          turno: vm.proximoTurno,
                          tiempoRestante: vm.proximoTurno != null
                              ? FormatoFechaEspanolHelper.tiempoRestante(vm.proximoTurno!)
                              : '',
                          onVerDetalle: () {
                            if (vm.proximoTurno != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PantallaDetalleTurno(
                                    turno: vm.proximoTurno!,
                                    soloLectura: false,
                                  ),
                                ),
                              ).then((_) => vm.cargar());
                            }
                          },
                        ),
                        const SizedBox(height: 28),
                        _construirAccesosRapidos(context, vm),
                        const SizedBox(height: 24),
                        const BannerUrgencia(),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const BarraNavegacionPaciente(indiceActual: 0),
    );
  }

  Widget _construirEncabezadoSuperior(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.health_and_safety_outlined,
                color: ColoresApp.primario,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MediTurnos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Icons.logout_rounded,
            color: ColoresApp.primario,
            size: 26,
          ),
          onPressed: () {
            context.read<AutenticacionViewModel>().cerrarSesion();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PantallaLogin()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _construirSeccionSaludo(BuildContext context, InicioPacienteViewModel vm) {
    final authVm = context.watch<AutenticacionViewModel>();
    final nombreReal = authVm.usuarioActual?.nombre ?? 'Paciente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vm.fechaHoy,
          style: const TextStyle(
            fontSize: 13,
            color: ColoresApp.textoSecundario,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text('Hola, $nombreReal', style: EstilosTexto.tituloGrande),
        const SizedBox(height: 4),
        const Text(
          'Gestioná tus consultas y cuidá tu salud hoy.',
          style: EstilosTexto.subtitulo,
        ),
      ],
    );
  }

  Widget _construirAccesosRapidos(BuildContext context, InicioPacienteViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos rápidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TarjetaAccesoRapido(
              titulo: 'Mis turnos',
              subtitulo: 'Ver historial y fechas',
              icono: Icons.calendar_month_outlined,
              badgeTexto: vm.cantidadActivos > 0 ? '${vm.cantidadActivos} activos' : '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaMisTurnos(),
                  ),
                ).then((_) => vm.cargar());
              },
            ),
            const SizedBox(width: 14),
            TarjetaAccesoRapido(
              titulo: 'Buscar médicos',
              subtitulo: 'Por nombre o área',
              icono: Icons.person_search_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaBuscarMedicos(),
                  ),
                ).then((_) => vm.cargar());
              },
            ),
          ],
        ),
      ],
    );
  }
}

class FormatoFechaEspanolHelper {
  static String tiempoRestante(turno) {
    return FormatoFechaEspanol.textoTiempoRestante(turno.fecha, turno.hora);
  }
}
