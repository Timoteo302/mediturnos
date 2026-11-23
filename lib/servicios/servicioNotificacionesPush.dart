import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../autenticacion/presentacion/pantallas/pantallaLogin.dart';
import '../componentes/comunes/notificacionApp.dart';
import '../configuracion/clavesGlobales.dart';
import '../configuracion/clienteHttpAutenticado.dart';
import '../configuracion/configuracionServidor.dart';
import '../notificaciones/presentacion/pantallas/pantallaNotificaciones.dart';

// Función top-level anotada con @pragma('vm:entry-point') requerida por Firebase Messaging para notificaciones en segundo plano.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handler en segundo plano: no realiza tareas pesadas.
}

// Servicio para gestionar el registro de celulares, generación del installationId y recepción de notificaciones push.
class ServicioNotificacionesPush {
  static const String _claveInstallationId = 'mediturnos_installation_id';

  final FirebaseMessaging? _messagingInstance;
  final FlutterLocalNotificationsPlugin? _localNotificationsInstance;
  final FlutterSecureStorage _storage;
  final http.Client? _httpClient;

  String? _installationId;

  FirebaseMessaging get _messaging => _messagingInstance ?? FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin get _localNotifications => _localNotificationsInstance ?? FlutterLocalNotificationsPlugin();

  ServicioNotificacionesPush({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FlutterSecureStorage? storage,
    http.Client? httpClient,
  })  : _messagingInstance = messaging,
        _localNotificationsInstance = localNotifications,
        _storage = storage ?? const FlutterSecureStorage(),
        _httpClient = httpClient;

  // Obtiene el installationId guardado o genera un UUID nuevo único y persistente.
  Future<String> obtenerInstallationId() async {
    if (_installationId != null && _installationId!.isNotEmpty) {
      return _installationId!;
    }
    try {
      String? idGuardado = await _storage.read(key: _claveInstallationId);
      if (idGuardado == null || idGuardado.isEmpty) {
        idGuardado = const Uuid().v4();
        await _storage.write(key: _claveInstallationId, value: idGuardado);
      }
      _installationId = idGuardado;
      return idGuardado;
    } catch (_) {
      final idNuevo = const Uuid().v4();
      _installationId = idNuevo;
      return idNuevo;
    }
  }

  // Inicializa permisos, canal de alta prioridad en Android y listeners de FCM.
  Future<void> inicializar({
    bool Function()? estaAutenticado,
    void Function()? alRecibirNotificacion,
  }) async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const channel = AndroidNotificationChannel(
        'turnos',
        'Turnos',
        description: 'Notificaciones de turnos médicos',
        importance: Importance.high,
      );

      final androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(channel);

      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsDarwin = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          _manejarToqueNotificacion(estaAutenticado: estaAutenticado, data: {});
        },
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title ?? message.data['titulo'] ?? '';
        final body = message.notification?.body ?? message.data['cuerpo'] ?? '';

        if (title.isNotEmpty || body.isNotEmpty) {
          mostrarNotificacionAppGlobal(
            tipo: TipoNotificacionApp.informacion,
            titulo: title,
            mensaje: body,
          );
        }
        alRecibirNotificacion?.call();
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _manejarToqueNotificacion(
          estaAutenticado: estaAutenticado,
          data: message.data,
        );
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _manejarToqueNotificacion(
          estaAutenticado: estaAutenticado,
          data: initialMessage.data,
        );
      }

      _messaging.onTokenRefresh.listen((nuevoToken) {
        if (estaAutenticado != null && estaAutenticado()) {
          registrar(tokenFcmManual: nuevoToken);
        }
      });
    } catch (e) {
      debugPrint('Error al inicializar servicio push: $e');
    }
  }

  // Envia la solicitud PUT /dispositivos/{installationId} con el token FCM a la API. Si falla, no rompe el flujo.
  Future<void> registrar({
    ClienteHttpAutenticado? clienteHttp,
    String? tokenFcmManual,
  }) async {
    try {
      final installationId = await obtenerInstallationId();
      final tokenFcm = tokenFcmManual ?? await _messaging.getToken();

      if (tokenFcm == null || tokenFcm.isEmpty) {
        return;
      }

      final url = Uri.parse('${ConfiguracionServidor.urlBase}/dispositivos/$installationId');
      final body = jsonEncode({'tokenFcm': tokenFcm});
      final client = clienteHttp ?? _httpClient ?? http.Client();

      final res = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 204) {
        debugPrint('Dispositivo $installationId registrado en el servidor.');
      } else {
        debugPrint('Respuesta HTTP ${res.statusCode} al registrar dispositivo: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error al registrar dispositivo para notificaciones push: $e');
    }
  }

  // Elimina el registro del celular en el servidor y borra el token FCM. Los errores son ignorados.
  Future<void> desregistrar({
    ClienteHttpAutenticado? clienteHttp,
  }) async {
    try {
      final installationId = await obtenerInstallationId();
      final url = Uri.parse('${ConfiguracionServidor.urlBase}/dispositivos/$installationId');
      final client = clienteHttp ?? _httpClient ?? http.Client();

      await client.delete(url);
    } catch (e) {
      debugPrint('Error al eliminar registro de dispositivo push: $e');
    }

    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Error al eliminar token FCM: $e');
    }
  }

  void _manejarToqueNotificacion({
    bool Function()? estaAutenticado,
    required Map<String, dynamic> data,
  }) {
    final nav = claveNavegacionGlobal.currentState;
    if (nav == null) return;

    final autenticado = estaAutenticado != null ? estaAutenticado() : true;

    if (autenticado) {
      nav.push(
        MaterialPageRoute(builder: (_) => const PantallaNotificaciones()),
      );
    } else {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
        (route) => false,
      );
    }
  }
}
