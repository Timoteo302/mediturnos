import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediturnos/componentes/comunes/notificacionApp.dart';
import 'package:mediturnos/configuracion/clavesGlobales.dart';

// Pruebas para verificar que mostrarNotificacionApp muestra el título y el ícono según el tipo.
void main() {
  Widget crearWidgetPrueba({
    required TipoNotificacionApp tipo,
    required String titulo,
    required String mensaje,
  }) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                mostrarNotificacionApp(
                  context,
                  tipo: tipo,
                  titulo: titulo,
                  mensaje: mensaje,
                );
              },
              child: const Text('Mostrar'),
            );
          },
        ),
      ),
    );
  }

  testWidgets('Muestra el título y el ícono correspondiente para tipo EXITO', (tester) async {
    await tester.pumpWidget(
      crearWidgetPrueba(
        tipo: TipoNotificacionApp.exito,
        titulo: 'Título Éxito',
        mensaje: 'Mensaje Éxito',
      ),
    );

    await tester.tap(find.text('Mostrar'));
    await tester.pump();

    expect(find.text('Título Éxito'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('Muestra el título y el ícono correspondiente para tipo ERROR', (tester) async {
    await tester.pumpWidget(
      crearWidgetPrueba(
        tipo: TipoNotificacionApp.error,
        titulo: 'Título Error',
        mensaje: 'Mensaje Error',
      ),
    );

    await tester.tap(find.text('Mostrar'));
    await tester.pump();

    expect(find.text('Título Error'), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('Muestra el título y el ícono correspondiente para tipo ADVERTENCIA', (tester) async {
    await tester.pumpWidget(
      crearWidgetPrueba(
        tipo: TipoNotificacionApp.advertencia,
        titulo: 'Título Advertencia',
        mensaje: 'Mensaje Advertencia',
      ),
    );

    await tester.tap(find.text('Mostrar'));
    await tester.pump();

    expect(find.text('Título Advertencia'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('Muestra el título y el ícono correspondiente para tipo INFORMACION', (tester) async {
    await tester.pumpWidget(
      crearWidgetPrueba(
        tipo: TipoNotificacionApp.informacion,
        titulo: 'Título Información',
        mensaje: 'Mensaje Información',
      ),
    );

    await tester.tap(find.text('Mostrar'));
    await tester.pump();

    expect(find.text('Título Información'), findsOneWidget);
    expect(find.byIcon(Icons.info), findsOneWidget);
  });
}
