import 'package:flutter/material.dart';
import 'autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'configuracion/temaApp.dart';
import 'package:mediturnos/servicios/verificadorConexion.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      navigatorKey: claveNavegacionGlobal,
      debugShowCheckedModeBanner: false,
      title: 'MediTurnos',
      theme: TemaApp.tema,
      home: const PantallaLogin(),
    );
  }
}
