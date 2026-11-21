import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaCrearCuenta.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

// Diálogo emergente que avisa al invitado que se requiere una cuenta para acceder a ciertas secciones de la app.
class DialogoRequiereCuenta extends StatelessWidget {
  const DialogoRequiereCuenta({super.key});

  // Muestra el diálogo emergente para requerir cuenta.
  static Future<void> mostrar(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const DialogoRequiereCuenta(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AutenticacionViewModel>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Necesitás una cuenta',
        style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
      ),
      content: const Text(
        'Iniciá sesión o creá tu cuenta para usar esta sección.',
        style: TextStyle(color: ColoresApp.textoSecundario),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ahora no', style: TextStyle(color: ColoresApp.textoSecundario)),
        ),
        TextButton(
          onPressed: () {
            authVm.salirDeInvitado();
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PantallaLogin()),
              (route) => false,
            );
          },
          child: const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primario)),
        ),
        ElevatedButton(
          onPressed: () {
            // Salir del modo invitado y dejar la pila como [PantallaLogin, PantallaCrearCuenta]
            authVm.salirDeInvitado();
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PantallaLogin()),
              (route) => false,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PantallaCrearCuenta()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColoresApp.primario,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Crear cuenta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
