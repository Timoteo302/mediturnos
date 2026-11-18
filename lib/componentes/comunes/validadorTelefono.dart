import 'package:flutter/services.dart';

// Formateadores para campos de teléfono: limita a 30 caracteres y solo deja tipear números, espacios, +, - y paréntesis.
final formateadoresTelefono = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[\d\s+\-()]')),
  LengthLimitingTextInputFormatter(30),
];

// Valida que el campo teléfono no esté vacío y que tenga entre 8 y 15 números reales.
String? validarTelefono(String? v) {
  if (v == null || v.trim().isEmpty) {
    return 'El teléfono es obligatorio.';
  }
  // Cuento solo los dígitos numéricos para la longitud requerida
  final soloDigitos = v.replaceAll(RegExp(r'\D'), '');
  if (soloDigitos.length < 8 || soloDigitos.length > 15) {
    return 'El teléfono debe tener entre 8 y 15 dígitos.';
  }
  return null;
}
