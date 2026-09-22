import 'package:flutter/material.dart';
import 'turnos/presentacion/pantallas/pantallaTurnos.dart';

import 'autenticacion/presentacion/pantallaLogin.dart';

void main() {
  runApp(const MediTurnosApp());
}

/*
Esta clase representa la aplicación en sí.
Aquí configuramos aspectos generales como:
- título
- tema
- primera pantalla
*/
class MediTurnosApp extends StatelessWidget {
  const MediTurnosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediTurnos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const PantallaLogin(),
    );
  }
}

/*Pantalla de nuestra aplicacion, aqui podemos tener
-PantallInicio, PantallaTurnos, RegistrarTurno, DetalleTurno*/
/*
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediTurnos'),
      ),
      body: const Center(
        child: Text(
          'Bienvenido a MediTurnos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
*/