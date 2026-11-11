class ConfiguracionServidor {
  // URL base definida con String.fromEnvironment para configurarla por linea de comandos.
  // Formas de conectar:
  // 1. Celular fisico por USB: adb reverse tcp:8080 tcp:8080 (valor por defecto http://localhost:8080)
  // 2. Celular por Wi-Fi: --dart-define=API_URL=http://IP_DE_LA_PC:8080
  // 3. Emulador de Android: --dart-define=API_URL=http://10.0.2.2:8080
  static const String urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const Duration tiempoEspera = Duration(seconds: 8);
}
