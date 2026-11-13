import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import '../../medicos/datos/modelos/medico.dart';

/// Modal desplegable inferior para filtrar la grilla de administración por médico.
void mostrarModalMedicosAdmin(
  BuildContext context, {
  required Medico? medicoSeleccionado,
  required List<Medico> medicosDisponibles,
  required ValueChanged<Medico?> alSeleccionar,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
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
                  'Filtrar por médico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Todos los médicos',
                  style: TextStyle(
                    fontWeight: medicoSeleccionado == null ? FontWeight.bold : FontWeight.normal,
                    color: medicoSeleccionado == null ? ColoresApp.primario : ColoresApp.textoTitulo,
                  ),
                ),
                trailing: medicoSeleccionado == null ? const Icon(Icons.check, color: ColoresApp.primario) : null,
                onTap: () {
                  alSeleccionar(null);
                  Navigator.pop(ctx);
                },
              ),
              ...medicosDisponibles.map((medico) {
                final esSeleccionado = medicoSeleccionado?.id == medico.id;
                return ListTile(
                  title: Text(
                    medico.nombreCompleto,
                    style: TextStyle(
                      fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                      color: esSeleccionado ? ColoresApp.primario : ColoresApp.textoTitulo,
                    ),
                  ),
                  trailing: esSeleccionado ? const Icon(Icons.check, color: ColoresApp.primario) : null,
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
