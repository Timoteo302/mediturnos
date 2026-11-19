import 'package:flutter/material.dart';

// Claves globales para controlar la navegación y los mensajes emergentes en toda la app sin requerir BuildContext.
final GlobalKey<NavigatorState> claveNavegacionGlobal = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
