import 'package:flutter/material.dart';
import '../configuracion/coloresApp.dart';
import '../configuracion/estilosTexto.dart';

/// Botón azul redondeado desplegado a lo ancho.
/// Botón principal reutilizable de tipo "pill" azul.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final double altura;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.altura = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: altura,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primarioBoton,
          foregroundColor: ColoresApp.textoBoton,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          texto,
          style: EstilosTexto.textoBotonPrincipal,
        ),
      ),
    );
  }
}