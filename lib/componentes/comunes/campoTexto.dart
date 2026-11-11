import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';

/// Componente de entrada de texto reutilizable.
class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final String hintText;
  final IconData iconoPrefijo;
  final Widget? iconoSufijo;
  final bool ocultarTexto;
  final TextInputType tipoTeclado;
  final String? mensajeError;
  final ValueChanged<String>? alCambiar;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.hintText,
    required this.iconoPrefijo,
    this.iconoSufijo,
    this.ocultarTexto = false,
    this.tipoTeclado = TextInputType.text,
    this.mensajeError,
    this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: ocultarTexto,
      keyboardType: tipoTeclado,
      onChanged: alCambiar,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: hintText,
        errorText: mensajeError,
        prefixIcon: Icon(iconoPrefijo, color: ColoresApp.textoSecundario),
        suffixIcon: iconoSufijo,
      ),
    );
  }
}
