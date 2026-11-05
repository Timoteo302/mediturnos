import 'package:flutter/material.dart';

class PantallaCrearCuenta extends StatefulWidget {
  const PantallaCrearCuenta({super.key});

  @override
  State<PantallaCrearCuenta> createState() => _PantallaCrearCuentaState();
}

class _PantallaCrearCuentaState extends State<PantallaCrearCuenta> {

  // Controladores para obtener los datos ingresados por el usuario.
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController =
  TextEditingController();

  // Permite mostrar u ocultar las contraseñas.
  bool mostrarContrasena = false;
  bool mostrarConfirmacion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Título de la pantalla.
            const Text(
              'Crear cuenta',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Campo para ingresar el nombre.
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            // Campo para ingresar el apellido.
            TextField(
              controller: apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 15),

            // Campo para ingresar el DNI.
            TextField(
              controller: dniController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'DNI',
                prefixIcon: Icon(Icons.badge),
              ),
            ),

            const SizedBox(height: 15),

            // Campo para ingresar el correo electrónico.
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
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

            const SizedBox(height: 15),

            // Campo para confirmar la contraseña.
            TextField(
              controller: confirmarContrasenaController,
              obscureText: !mostrarConfirmacion,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    mostrarConfirmacion
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarConfirmacion = !mostrarConfirmacion;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Botón para crear la cuenta.
            ElevatedButton(
              onPressed: () {
                // Por ahora no guardamos los datos.
                // Más adelante este botón se conectará con la API.
              },
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}