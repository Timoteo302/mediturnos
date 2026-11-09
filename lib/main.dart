import 'package:flutter/material.dart';

import 'autenticacion/presentacion/pantallas/pantallaLogin.dart';

import 'configuracion/temaApp.dart';

import 'package:mediturnos/servicios/verificadorConexion.dart';

void main() {
  //Inicializa Flutter para permitir temporizadores antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 👈 Inicia la vigilancia de red continua para toda la app
  VerificadorConexion.iniciarMonitoreoGlobal();

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
      // 👈 Clave para poder abrir la pantalla de sin conexión desde cualquier parte
      navigatorKey: claveNavegacionGlobal,
      debugShowCheckedModeBanner: false,
      title: 'MediTurnos',
      theme: TemaApp.tema,
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