import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'configuracion/clavesGlobales.dart';

import 'turnos/datos/repositorios/repositorioGestionTurnosOfflineFirst.dart';
import 'turnos/datos/fuentes/local/almacenTurnosLocal.dart';

import 'autenticacion/datos/repositorios/repositorioAutenticacion.dart';
import 'autenticacion/datos/repositorios/repositorioAutenticacionOfflineFirst.dart';
import 'autenticacion/datos/fuentes/clienteAutenticacionApi.dart';
import 'autenticacion/datos/fuentes/almacenSesionLocalSqlite.dart';
import 'autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'configuracion/temaApp.dart';

import 'medicos/datos/repositorios/repositorioMedicosOfflineFirst.dart';
import 'medicos/datos/fuentes/almacenMedicosLocal.dart';
import 'medicos/datos/repositorios/repositorioMedicos.dart';
import 'medicos/datos/repositorios/repositorioMedicosApi.dart';
import 'medicos/datos/fuentes/clienteMedicosApi.dart';

import 'turnos/datos/repositorios/repositorioGestionTurnos.dart';
import 'turnos/datos/fuentes/clienteTurnosApi.dart';

import 'notificaciones/datos/repositorios/repositorioNotificaciones.dart';
import 'notificaciones/datos/repositorios/repositorioNotificacionesApi.dart';
import 'notificaciones/datos/fuentes/clienteNotificacionesApi.dart';
import 'notificaciones/presentacion/viewmodels/notificacionesViewModel.dart';

import 'servicios/servicioMonitoreoSincronizacion.dart';
import 'servicios/estadoConexionViewModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de SQLite para Flutter Web Edge.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }

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
          create: (_) => RepositorioMedicosOfflineFirst(
            remoto: RepositorioMedicosApi(ClienteMedicosApi(http.Client())),
            local: AlmacenMedicosLocal(),
          ),
        ),
        Provider<RepositorioGestionTurnos>(
          create: (_) => RepositorioGestionTurnosOfflineFirst(
            ClienteTurnosApi(http.Client()),
            AlmacenTurnosLocal(),
          ),
        ),
        Provider<RepositorioNotificaciones>(
          create: (_) => RepositorioNotificacionesApi(
            ClienteNotificacionesApi(http.Client()),
          ),
        ),

        Provider<ServicioMonitoreoSincronizacion>(
          lazy: false,
          create: (_) => ServicioMonitoreoSincronizacion()..iniciar(),
          dispose: (_, servicio) => servicio.detener(),
        ),
        ChangeNotifierProvider<EstadoConexionViewModel>(
          lazy: false,
          create: (context) => EstadoConexionViewModel(
            context.read<ServicioMonitoreoSincronizacion>(),
          ),
        ),
        ChangeNotifierProvider<NotificacionesViewModel>(
          lazy: false,
          create: (context) => NotificacionesViewModel(
            repositorioNotificaciones: context.read<RepositorioNotificaciones>(),
            repositorioTurnos: context.read<RepositorioGestionTurnos>(),
            authVm: context.read<AutenticacionViewModel>(),
            conexionVm: context.read<EstadoConexionViewModel>(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: claveNavegacionGlobal,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'MediTurnos',
        theme: TemaApp.tema,
        home: const PantallaLogin(),
      ),
    );
  }
}
