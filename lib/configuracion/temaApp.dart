import 'package:flutter/material.dart';
import 'coloresApp.dart';
import 'estilosTexto.dart';

/// Configuración global de ThemeData para MediTurnos.
class TemaApp {
  TemaApp._();

  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ColoresApp.fondoPantalla,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColoresApp.primario,
        primary: ColoresApp.primario,
        surface: ColoresApp.fondoPantalla,
      ),

      // Estilo por defecto de los inputs en toda la app
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColoresApp.fondoPantalla,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: EstilosTexto.etiquetaCampo,
        hintStyle: EstilosTexto.hintCampo,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresApp.bordeCampo),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresApp.bordeCampo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresApp.bordeCampoEnfocado, width: 1.5),
        ),
      ),
    );
  }
}