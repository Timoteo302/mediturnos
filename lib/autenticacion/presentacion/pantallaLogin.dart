import 'package:flutter/material.dart';

import '../../turnos/presentacion/pantallas/pantallaTurnos.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {

  // Controladores para obtener los datos ingresados.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  // Permite mostrar u ocultar la contraseña.
  bool mostrarContrasena = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediTurnos'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Título de la aplicación.
            const Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Campo para ingresar el correo.
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 15),

            // Campo para ingresar la contraseña.
            TextField(
              controller: contrasenaController,
              obscureText: !mostrarContrasena,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    mostrarContrasena
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarContrasena = !mostrarContrasena;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Botón para iniciar sesión.
            ElevatedButton(
              onPressed: () {
                // Por ahora ingresamos directamente a la pantalla de turnos.
                // Más adelante la validación se hará mediante la API.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaTurnos(),
                  ),
                );
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}