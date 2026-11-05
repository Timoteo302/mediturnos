import 'package:flutter/material.dart';
import '../configuracion/coloresApp.dart';

/// Componente para el ícono de encabezado con fondo redondeado.
class IconoEncabezado extends StatelessWidget {
  final IconData icono;
  final double tamanio;

  const IconoEncabezado({
    super.key,
    this.icono = Icons.health_and_safety_outlined,
    this.tamanio = 72.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanio,
      height: tamanio,
      decoration: BoxDecoration(
        color: ColoresApp.fondoIcono,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icono,
        color: ColoresApp.primario,
        size: tamanio * 0.52,
      ),
    );
  }
}