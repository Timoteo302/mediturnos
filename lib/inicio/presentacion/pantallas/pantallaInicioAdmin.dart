import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:mediturnos/componentes/admin/tarjetaAccionAdmin.dart';
import 'package:mediturnos/componentes/admin/tarjetaResumenJornada.dart';
import 'package:mediturnos/componentes/admin/tarjetaTurnoPendiente.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/datosInstitucion.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';

import 'package:mediturnos/navegacion/barraNavegacionAdmin.dart';
import '../../../autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import '../../../autenticacion/presentacion/pantallas/pantallaLogin.dart';
import '../../../medicos/presentacion/pantallas/pantallaGestionHorarios.dart';
import '../../../medicos/presentacion/pantallas/pantallaGestionMedicos.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';
import '../../../turnos/datos/modelos/estadoTurno.dart';
import '../../../turnos/datos/modelos/turnoDetalle.dart';
import '../../../turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../../../turnos/presentacion/pantallas/pantallaTodosLosTurnos.dart';
import '../../../turnos/presentacion/pantallas/pantallaDetalleTurno.dart';
import '../viewmodels/panelAdminViewModel.dart';

/// Pantalla principal de inicio para el Administrador (03B. Inicio Admin).
class PantallaInicioAdmin extends StatelessWidget {
  const PantallaInicioAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PanelAdminViewModel(
        context.read<RepositorioGestionTurnos>(),
        context.read<RepositorioMedicos>(),
      ),
      child: const _VistaInicioAdmin(),
    );
  }
}

class _VistaInicioAdmin extends StatefulWidget {
  const _VistaInicioAdmin();

  @override
  State<_VistaInicioAdmin> createState() => _VistaInicioAdminState();
}

class _VistaInicioAdminState extends State<_VistaInicioAdmin> {
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PanelAdminViewModel>();

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
                        _construirEncabezadoAdmin(context),
                        const SizedBox(height: 20),
                        _construirTituloPanel(),
                        const SizedBox(height: 20),
                        TarjetaResumenJornada(
                          turnosHoy: vm.turnosHoy.length,
                          pendientes: vm.pendientes,
                          medicosActivos: vm.medicosActivos,
                        ),
                        const SizedBox(height: 24),
                        _construirSeccionAcciones(context, vm),
                        const SizedBox(height: 24),
                        _construirSeccionPendientes(context, vm),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const BarraNavegacionAdmin(indiceActual: 0),
    );
  }

  Widget _construirEncabezadoAdmin(BuildContext context) {
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
                Icons.admin_panel_settings_outlined,
                color: ColoresApp.primario,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'MediTurnos Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                Text(
                  'Panel de Administración',
                  style: TextStyle(
                    fontSize: 11,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ],
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

  Widget _construirTituloPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panel de Gestión - ${DatosInstitucion.nombre}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Resumen operativo y control de agendas en tiempo real.',
          style: EstilosTexto.subtitulo,
        ),
      ],
    );
  }

  Widget _construirSeccionAcciones(BuildContext context, PanelAdminViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones directas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 12),
        TarjetaAccionAdmin(
          titulo: 'Ver todos los turnos',
          subtitulo: 'Consultá la grilla completa, reprogramaciones y cancelaciones del día.',
          icono: Icons.grid_view_rounded,
          infoPie: '${vm.confirmados} confirmados • ${vm.pendientes} en espera',
          textoEnlace: 'Abrir grilla >',
          esBannerAncho: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaTodosLosTurnos(),
              ),
            ).then((_) => vm.cargar());
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TarjetaAccionAdmin(
                titulo: 'Gestionar médicos',
                subtitulo: 'Nómina de especialistas y disponibilidad diaria.',
                icono: Icons.medical_services_outlined,
                infoPie: '${vm.totalMedicos} registros',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaGestionMedicos(),
                    ),
                  ).then((_) => vm.cargar());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TarjetaAccionAdmin(
                titulo: 'Gestionar horarios',
                subtitulo: 'Configuración de franjas y días de atención.',
                icono: Icons.access_time_outlined,
                infoPie: '${vm.medicosActivos} médicos activos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaGestionHorarios(),
                    ),
                  ).then((_) => vm.cargar());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirSeccionPendientes(BuildContext context, PanelAdminViewModel vm) {
    final pendientesHoy = vm.pendientesHoy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Próximos turnos a confirmar hoy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                const SizedBox(width: 8),
                if (vm.pendientes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${vm.pendientes}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaTodosLosTurnos(filtroInicial: EstadoTurno.pendiente),
                  ),
                ).then((_) => vm.cargar());
              },
              child: const Text(
                'Ver pendientes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primario,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendientesHoy.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text('No hay turnos pendientes para hoy.', style: EstilosTexto.subtitulo),
            ),
          )
        else
          ...pendientesHoy.map((turno) {
            return TarjetaTurnoPendiente(
              iniciales: turno.paciente.nombre.isNotEmpty ? turno.paciente.nombre.substring(0, 2).toUpperCase() : 'PA',
              nombrePaciente: turno.paciente.nombreCompleto,
              dniObraSocial: 'DNI: ${turno.paciente.dni}',
              medicoEspecialidad: '${turno.medico.nombreCompleto} • ${turno.medico.especialidad.nombre}',
              horaConsultorio: '${turno.hora} hs',
              onLlamar: () => _mostrarDialogoLlamar(context, turno),
              onRevisar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaDetalleTurno(turno: turno, soloLectura: true),
                  ),
                ).then((_) => vm.cargar());
              },
            );
          }),
      ],
    );
  }
}
