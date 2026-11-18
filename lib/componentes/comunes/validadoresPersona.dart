// Valida el campo nombre exigiendo que no esté vacío, tenga entre 2 y 100 caracteres y solo letras.
String? validarNombre(String? v) {
  if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio.';
  final val = v.trim();
  if (val.length < 2 || val.length > 100) return 'El nombre debe tener entre 2 y 100 caracteres.';
  final regex = RegExp(r"^[\p{L}\s'\-]+$", unicode: true);
  if (!regex.hasMatch(val)) return 'El nombre contiene caracteres inválidos.';
  return null;
}

// Valida el campo apellido exigiendo que no esté vacío, tenga entre 2 y 100 caracteres y solo letras.
String? validarApellido(String? v) {
  if (v == null || v.trim().isEmpty) return 'El apellido es obligatorio.';
  final val = v.trim();
  if (val.length < 2 || val.length > 100) return 'El apellido debe tener entre 2 y 100 caracteres.';
  final regex = RegExp(r"^[\p{L}\s'\-]+$", unicode: true);
  if (!regex.hasMatch(val)) return 'El apellido contiene caracteres inválidos.';
  return null;
}
