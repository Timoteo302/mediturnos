import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'configuracion/temaApp.dart';
import 'package:mediturnos/servicios/verificadorConexion.dart';

import 'autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'autenticacion/datos/repositorios/repositorioAutenticacionOfflineFirst.dart';
import 'autenticacion/datos/fuentes/clienteAutenticacionApi.dart';
import 'autenticacion/datos/fuentes/almacenSesionLocalSqlite.dart';
import 'autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';

void main() {
  // Inicializa Flutter para permitir temporizadores antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicia la vigilancia de red continua para toda la app
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
    return MultiProvider(
      providers: [
        Provider<RepositorioAutenticacion>(
          create: (_) => RepositorioAutenticacionOfflineFirst(
            remoto: ClienteAutenticacionApi(http.Client()),
            local: AlmacenSesionLocalSqlite(),
          ),
        ),
        ChangeNotifierProvider<AutenticacionViewModel>(
          create: (context) => AutenticacionViewModel(
            context.read<RepositorioAutenticacion>(),
          ),
        ),
      ],
      child: MaterialApp(
        // 👈 Clave para poder abrir la pantalla de sin conexión desde cualquier parte
        navigatorKey: claveNavegacionGlobal,
        debugShowCheckedModeBanner: false,
        title: 'MediTurnos',
        theme: TemaApp.tema,
        home: const PantallaLogin(),
      ),
    );
  }
}
