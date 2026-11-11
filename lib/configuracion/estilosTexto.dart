import 'package:flutter/material.dart';
import 'coloresApp.dart';

/// Estilos de texto reutilizables para MediTurnos.
class EstilosTexto {
  EstilosTexto._();

  // Títulos y subtítulos
  static const TextStyle tituloGrande = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: ColoresApp.textoTitulo,
    letterSpacing: -0.5,
  );

  static const TextStyle subtitulo = TextStyle(
    fontSize: 14,
    color: ColoresApp.textoSecundario,
  );

  // Campos de texto y etiquetas
  static const TextStyle etiquetaCampo = TextStyle(
    fontSize: 14,
    color: ColoresApp.textoSecundario,
  );

  static const TextStyle hintCampo = TextStyle(
    fontSize: 14,
    color: ColoresApp.textoHint,
  );

  // Botones y enlaces
  static const TextStyle textoBotonPrincipal = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: ColoresApp.textoBoton,
  );

  static const TextStyle enlace = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ColoresApp.primario,
  );

  static const TextStyle enlaceDestacado = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: ColoresApp.primario,
  );
}