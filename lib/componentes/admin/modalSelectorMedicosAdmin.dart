import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Modal desplegable inferior para filtrar la grilla de administración por médico.
void mostrarModalMedicosAdmin(
  BuildContext context, {
  required String medicoSeleccionado,
  required List<String> medicosDisponibles,
  required ValueChanged<String> alSeleccionar,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final opciones = ['Todos', ...medicosDisponibles];
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Todos los médicos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
              ),
              const Divider(),
              ...opciones.map((medico) {
                final esSeleccionado = medicoSeleccionado == medico;
                return ListTile(
                  title: Text(
                    medico == 'Todos' ? 'Todos los médicos' : medico,
                    style: TextStyle(
                      fontWeight:
                          esSeleccionado ? FontWeight.bold : FontWeight.normal,
                      color: esSeleccionado
                          ? ColoresApp.primario
                          : ColoresApp.textoTitulo,
                    ),
                  ),
                  trailing: esSeleccionado
                      ? const Icon(Icons.check, color: ColoresApp.primario)
                      : null,
                  onTap: () {
                    alSeleccionar(medico);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
