import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../componentes/comunes/indicadorConexion.dart';
import '../../../componentes/turnos/dialogoAsistenciaTurno.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../turnos/datos/modelos/estadoTurno.dart';
import '../../../turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../../../turnos/presentacion/pantallas/pantallaDetalleTurno.dart';
import '../../../turnos/presentacion/pantallas/pantallaTodosLosTurnos.dart';
import '../../datos/modelos/notificacion.dart';
import '../viewmodels/notificacionesViewModel.dart';

// Pantalla principal de notificaciones del usuario con refresco al deslizar y acciones por tipo.
class PantallaNotificaciones extends StatefulWidget {
  const PantallaNotificaciones({super.key});

  @override
  State<PantallaNotificaciones> createState() => _PantallaNotificacionesState();
}

class _PantallaNotificacionesState extends State<PantallaNotificaciones> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificacionesViewModel>().cargar();
    });
  }

  // Formatea el tiempo transcurrido desde la creación de la notificación.
  String _formatearTiempoRelativo(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) {
      return 'hace un momento';
    } else if (diferencia.inMinutes < 60) {
      return 'hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'hace ${diferencia.inHours} h';
    } else if (diferencia.inDays == 1) {
      return 'ayer';
    } else if (diferencia.inDays < 7) {
      return 'hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  // Devuelve el ícono correspondiente para cada tipo de notificación.
  IconData _obtenerIconoTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.recordatorioAsistencia:
        return Icons.alarm;
      case TipoNotificacion.pacienteAsistira:
        return Icons.check_circle_outline;
      case TipoNotificacion.pacienteNoAsistira:
        return Icons.cancel_outlined;
      case TipoNotificacion.turnoReprogramado:
        return Icons.edit_calendar;
      case TipoNotificacion.turnoConfirmado:
        return Icons.verified_outlined;
      case TipoNotificacion.turnoCanceladoCentro:
        return Icons.event_busy;
    }
  }

  // Devuelve el color del ícono según el tipo de notificación.
  Color _obtenerColorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.recordatorioAsistencia:
        return Colors.orange;
      case TipoNotificacion.pacienteAsistira:
      case TipoNotificacion.turnoConfirmado:
        return Colors.green;
      case TipoNotificacion.pacienteNoAsistira:
      case TipoNotificacion.turnoCanceladoCentro:
        return Colors.red;
      case TipoNotificacion.turnoReprogramado:
        return ColoresApp.primario;
    }
  }

  // Maneja el toque en una notificación marcándola como leída y ejecutando su acción asociada.
  Future<void> _alTocarNotificacion(BuildContext context, Notificacion n) async {
    final vm = context.read<NotificacionesViewModel>();
    if (!n.leida) {
      await vm.marcarLeida(n.id);
    }

    if (!mounted) return;

    switch (n.tipo) {
      case TipoNotificacion.recordatorioAsistencia:
        final estado = n.turnoEstado;
        final resp = n.respuestaPaciente ?? 'SIN_RESPUESTA';
        if ((estado == EstadoTurno.pendiente || estado == EstadoTurno.confirmado) && resp == 'SIN_RESPUESTA' && n.turnoId != null) {
          final fechaTexto = n.turnoFecha != null ? '${n.turnoFecha!.day}/${n.turnoFecha!.month}/${n.turnoFecha!.year}' : '';
          showDialog(
            context: context,
            builder: (context) => DialogoAsistenciaTurno(
              turnoId: n.turnoId!,
              medicoNombre: 'tu profesional',
              fechaTexto: fechaTexto,
              hora: n.turnoHora ?? '08:00',
            ),
          );
        }
        break;

      case TipoNotificacion.turnoConfirmado:
      case TipoNotificacion.turnoCanceladoCentro:
        if (n.turnoId != null) {
          final repoTurnos = context.read<RepositorioGestionTurnos>();
          try {
            final turno = await repoTurnos.obtenerTurno(n.turnoId!);
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaDetalleTurno(
                    turno: turno,
                    soloLectura: n.tipo == TipoNotificacion.turnoCanceladoCentro,
                  ),
                ),
              );
            }
          } catch (_) {}
        }
        break;

      case TipoNotificacion.pacienteAsistira:
      case TipoNotificacion.turnoReprogramado:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaTodosLosTurnos(
              filtroInicial: EstadoTurno.pendiente,
              fechaInicial: n.turnoFecha,
            ),
          ),
        );
        break;

      case TipoNotificacion.pacienteNoAsistira:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaTodosLosTurnos(
              fechaInicial: n.turnoFecha,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificacionesViewModel>();
    final lista = vm.notificaciones;

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
          'Notificaciones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
        ),
        centerTitle: true,
        actions: const [IndicadorConexion()],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.cargar(),
        child: vm.cargando
            ? const Center(child: CircularProgressIndicator())
            : vm.error != null
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(vm.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: () => vm.cargar(), child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    ],
                  )
                : lista.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No tenés notificaciones.',
                              style: TextStyle(fontSize: 15, color: ColoresApp.textoSecundario),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          if (vm.cantidadNoLeidas > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => vm.marcarTodasLeidas(),
                                    icon: const Icon(Icons.done_all, size: 18),
                                    label: const Text('Marcar todas como leídas', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: lista.length,
                              itemBuilder: (context, index) {
                                final notif = lista[index];
                                final iconData = _obtenerIconoTipo(notif.tipo);
                                final iconColor = _obtenerColorTipo(notif.tipo);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: notif.leida ? Colors.white : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: notif.leida ? ColoresApp.bordeCampo : const Color(0xFFBFDBFE),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: iconColor.withValues(alpha: 0.1),
                                      child: Icon(iconData, color: iconColor, size: 22),
                                    ),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.titulo,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: notif.leida ? FontWeight.normal : FontWeight.bold,
                                              color: ColoresApp.textoTitulo,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatearTiempoRelativo(notif.fechaCreacion),
                                          style: const TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        notif.mensaje,
                                        style: const TextStyle(fontSize: 13, color: ColoresApp.textoSecundario),
                                      ),
                                    ),
                                    onTap: () => _alTocarNotificacion(context, notif),
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
