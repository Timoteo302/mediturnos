import 'package:http/http.dart' as http;
import '../autenticacion/datos/fuentes/almacenToken.dart';

// Cliente HTTP personalizado que inyecta automáticamente el token JWT y notifica si la sesión vence (401).
class ClienteHttpAutenticado extends http.BaseClient {
  final http.Client _inner;
  final AlmacenToken _almacenToken;
  final void Function()? alSesionVencida;

  bool _notificadoSesionVencida = false;

  ClienteHttpAutenticado(
    this._inner, {
    required AlmacenToken almacenToken,
    this.alSesionVencida,
  }) : _almacenToken = almacenToken;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _almacenToken.leerToken();
    bool teniaHeaderAuth = false;

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      teniaHeaderAuth = true;
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401 && teniaHeaderAuth) {
      if (!_notificadoSesionVencida) {
        _notificadoSesionVencida = true;
        alSesionVencida?.call();
      }
    } else if (response.statusCode != 401) {
      _notificadoSesionVencida = false;
    }

    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
