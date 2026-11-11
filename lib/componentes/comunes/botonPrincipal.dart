import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../configuracion/estilosTexto.dart';

/// Botón principal reutilizable de tipo "pill" azul con soporte de carga.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final double altura;
  final bool cargando;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.altura = 52.0,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: altura,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primarioBoton,
          foregroundColor: ColoresApp.textoBoton,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColoresApp.textoBoton,
                ),
              )
            : Text(
                texto,
                style: EstilosTexto.textoBotonPrincipal,
              ),
      ),
    );
  }
}
