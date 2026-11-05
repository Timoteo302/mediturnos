import 'package:flutter/material.dart';
import '../configuracion/coloresApp.dart';

/// Campo de texto reutilizable personalizable para correos, contraseñas, etc.

/// Componente de entrada de texto reutilizable.
class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final String hintText;
  final IconData iconoPrefijo;
  final Widget? iconoSufijo;
  final bool ocultarTexto;
  final TextInputType tipoTeclado;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.hintText,
    required this.iconoPrefijo,
    this.iconoSufijo,
    this.ocultarTexto = false,
    this.tipoTeclado = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: ocultarTexto,
      keyboardType: tipoTeclado,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: hintText,
        prefixIcon: Icon(iconoPrefijo, color: ColoresApp.textoSecundario),
        suffixIcon: iconoSufijo,
      ),
    );
  }
}