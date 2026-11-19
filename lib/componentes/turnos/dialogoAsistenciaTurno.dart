import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configuracion/coloresApp.dart';
import '../comunes/notificacionApp.dart';
import '../../notificaciones/presentacion/viewmodels/notificacionesViewModel.dart';

// Diálogo emergente para confirmar o rechazar asistencia a un turno médico con segunda confirmación al cancelar.
class DialogoAsistenciaTurno extends StatefulWidget {
  final int turnoId;
  final String medicoNombre;
  final String fechaTexto;
  final String hora;

  const DialogoAsistenciaTurno({
    super.key,
    required this.turnoId,
    required this.medicoNombre,
    required this.fechaTexto,
    required this.hora,
  });

  @override
  State<DialogoAsistenciaTurno> createState() => _DialogoAsistenciaTurnoState();
}

class _DialogoAsistenciaTurnoState extends State<DialogoAsistenciaTurno> {
  bool _procesando = false;

  // Procesa la respuesta de asistencia ("Sí, voy a asistir" o "No puedo ir").
  Future<void> _responder(bool asistira) async {
    if (asistira) {
      setState(() => _procesando = true);
      try {
        await context.read<NotificacionesViewModel>().responderAsistencia(widget.turnoId, true);
        if (!mounted) return;
        Navigator.pop(context, true);
        mostrarNotificacionApp(
          context,
          tipo: TipoNotificacionApp.exito,
          titulo: '¡Gracias!',
          mensaje: 'Avisamos al centro.',
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _procesando = false);
        mostrarNotificacionApp(
          context,
          tipo: TipoNotificacionApp.error,
          titulo: 'Error',
          mensaje: 'Necesitás conexión para responder.',
        );
      }
    } else {
      // Si indica que no puede ir, pedimos la segunda confirmación aclarando que el turno se cancela.
      final segundaConfirmacion = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Cancelar turno?'),
          content: const Text('Tu turno se va a cancelar y el horario queda libre.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Volver'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sí, cancelar'),
            ),
          ],
        ),
      );

      if (segundaConfirmacion == true && mounted) {
        setState(() => _procesando = true);
        try {
          await context.read<NotificacionesViewModel>().responderAsistencia(widget.turnoId, false);
          if (!mounted) return;
          Navigator.pop(context, false);
          mostrarNotificacionApp(
            context,
            tipo: TipoNotificacionApp.advertencia,
            titulo: 'Turno cancelado',
            mensaje: 'Turno cancelado.',
          );
        } catch (e) {
          if (!mounted) return;
          setState(() => _procesando = false);
          mostrarNotificacionApp(
            context,
            tipo: TipoNotificacionApp.error,
            titulo: 'Error',
            mensaje: 'Necesitás conexión para responder.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '¿Vas a asistir a tu turno?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Médico: ${widget.medicoNombre}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
          ),
          const SizedBox(height: 4),
          Text(
            'Fecha: ${widget.fechaTexto} a las ${widget.hora} hs',
            style: const TextStyle(fontSize: 13, color: ColoresApp.textoSecundario),
          ),
        ],
      ),
      actions: [
        if (_procesando)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _responder(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primarioBoton,
                    foregroundColor: ColoresApp.textoBoton,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Sí, voy a asistir'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _responder(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('No puedo ir'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
