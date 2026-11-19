import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/servicios/servicioMonitoreoSincronizacion.dart';

// Falso ServicioMonitoreoSincronizacion para verificar que sincronizarAhora sea invocado.
class FakeServicioMonitoreoSincronizacionEstado extends ServicioMonitoreoSincronizacion {
  bool sincronizarLlamado = false;

  @override
  Future<void> iniciar() async {}

  @override
  void detener() {}

  @override
  void sincronizarAhora() {
    sincronizarLlamado = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('EstadoConexionViewModel: de null a true no avisa; 1 fallo no cambia; 2 fallos pasa a false y avisa; al volver avisa y sincroniza', () async {
    final servicioSinc = FakeServicioMonitoreoSincronizacionEstado();

    bool estadoVerificador = true;
    final List<bool> avisosEmitidos = [];

    final vm = EstadoConexionViewModel(
      servicioSinc,
      alCambiarConexion: (conectado) {
        avisosEmitidos.add(conectado);
      },
      verificadorConexion: () async => estadoVerificador,
    );

    // Damos tiempo a la inicialización asíncrona (null -> true)
    await Future.delayed(Duration.zero);

    // 1. De null a true no debe haber emitido aviso.
    expect(vm.conectado, isTrue);
    expect(avisosEmitidos, isEmpty);

    // 2. 1 fallo consecutivo no cambia el estado.
    estadoVerificador = false;
    await vm.chequearConexionParaTest();

    expect(vm.conectado, isTrue);
    expect(avisosEmitidos, isEmpty);

    // 3. 2 fallos consecutivos cambian el estado a false y emiten aviso false.
    await vm.chequearConexionParaTest();

    expect(vm.conectado, isFalse);
    expect(avisosEmitidos, equals([false]));

    // 4. Al volver la conexión pasa a true, notifica true y llama a sincronizarAhora().
    estadoVerificador = true;
    await vm.chequearConexionParaTest();

    expect(vm.conectado, isTrue);
    expect(avisosEmitidos, equals([false, true]));
    expect(servicioSinc.sincronizarLlamado, isTrue);

    vm.dispose();
  });
}
