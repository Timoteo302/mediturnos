import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'autenticacion/datos/repositorios/repositorioAutenticacionOfflineFirst.dart';
import 'autenticacion/datos/fuentes/clienteAutenticacionApi.dart';
import 'autenticacion/datos/fuentes/almacenSesionLocalSqlite.dart';
import 'autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'configuracion/temaApp.dart';

import 'medicos/datos/repositorios/repositorioMedicos.dart';
import 'medicos/datos/repositorios/repositorioMedicosApi.dart';
import 'medicos/datos/fuentes/clienteMedicosApi.dart';

import 'package:mediturnos/servicios/verificadorConexion.dart';

import 'servicios/servicioMonitoreoSincronizacion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de SQLite para Flutter Web Edge.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }

  // Por ahora no iniciamos el monitoreo global para evitar
  // interrupciones en la navegación.
  // VerificadorConexion.iniciarMonitoreoGlobal();

  runApp(const MediTurnosApp());
}

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
          create: (context) =>
              AutenticacionViewModel(context.read<RepositorioAutenticacion>()),
        ),
        Provider<RepositorioMedicos>(
          create: (_) => RepositorioMedicosApi(
            ClienteMedicosApi(http.Client()),
          ),
        ),

        Provider<ServicioMonitoreoSincronizacion>(
          lazy: false,
          create: (_) => ServicioMonitoreoSincronizacion()..iniciar(),
          dispose: (_, servicio) => servicio.detener(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: claveNavegacionGlobal,
        debugShowCheckedModeBanner: false,
        title: 'MediTurnos',
        theme: TemaApp.tema,
        home: const PantallaLogin(),
      ),
    );
  }
}
