class ConfiguracionServidor {
  // URL base de la API. Se puede cambiar al correr la app, sin tocar el código:
  //   flutter run --dart-define=API_URL=http://OTRA_DIRECCION:8080
  //
  // Valor por defecto: http://localhost:8080
  //   - Celular por USB: hay que correr antes "adb reverse tcp:8080 tcp:8080".
  //   - PC con Chrome/Edge: funciona directo.
  //
  // Para otros casos, usar --dart-define=API_URL=...
  //   - Emulador de Android: http://10.0.2.2:8080
  //   - Celular por Wi-Fi:   http://IP_DE_LA_PC:8080
  static const String urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const Duration tiempoEspera = Duration(seconds: 8);

  // Constante compartida de expresion regular para email igual a la del servidor
  static const String regexEmail = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
}
