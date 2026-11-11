enum RolUsuario { paciente, admin }

class RolUsuarioExtension {
  static RolUsuario desdeTexto(String texto) {
    switch (texto.toUpperCase()) {
      case 'ADMIN':
        return RolUsuario.admin;
      case 'PACIENTE':
      default:
        return RolUsuario.paciente;
    }
  }

  static String aTexto(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.admin:
        return 'ADMIN';
      case RolUsuario.paciente:
        return 'PACIENTE';
    }
  }
}
