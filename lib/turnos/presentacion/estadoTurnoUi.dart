import 'package:flutter/material.dart';
import '../datos/modelos/estadoTurno.dart';

/// Extensión visual para asociar colores, fondos e íconos a cada EstadoTurno.
extension EstadoTurnoUiExtension on EstadoTurno {
  Color get color {
    switch (this) {
      case EstadoTurno.pendiente:
        return const Color(0xFFD97706); // Amber/Orange
      case EstadoTurno.confirmado:
        return const Color(0xFF059669); // Green
      case EstadoTurno.cancelado:
        return const Color(0xFFDC2626); // Red
      case EstadoTurno.atendido:
        return const Color(0xFF2563EB); // Blue
    }
  }

  Color get fondo {
    switch (this) {
      case EstadoTurno.pendiente:
        return const Color(0xFFFEF3C7);
      case EstadoTurno.confirmado:
        return const Color(0xFFD1FAE5);
      case EstadoTurno.cancelado:
        return const Color(0xFFFEE2E2);
      case EstadoTurno.atendido:
        return const Color(0xFFDBEAFE);
    }
  }

  IconData get icono {
    switch (this) {
      case EstadoTurno.pendiente:
        return Icons.schedule_rounded;
      case EstadoTurno.confirmado:
        return Icons.check_circle_outline_rounded;
      case EstadoTurno.cancelado:
        return Icons.cancel_outlined;
      case EstadoTurno.atendido:
        return Icons.verified_user_outlined;
    }
  }
}
