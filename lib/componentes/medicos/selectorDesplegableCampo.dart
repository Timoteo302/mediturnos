import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';

class SelectorDesplegableCampo<T> extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final List<DropdownMenuItem<T>> opciones;
  final T? valorActual;
  final String hint;
  final String? mensajeError;
  final ValueChanged<T?> alCambiar;

  const SelectorDesplegableCampo({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.opciones,
    required this.valorActual,
    required this.hint,
    this.mensajeError,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColoresApp.textoTitulo,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: valorActual,
          hint: Text(hint, style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 14)),
          items: opciones,
          onChanged: alCambiar,
          decoration: InputDecoration(
            prefixIcon: Icon(icono, color: ColoresApp.textoSecundario),
            errorText: mensajeError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ColoresApp.bordeCampo),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
