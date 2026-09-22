import 'package:flutter/material.dart';

import '../../datos/modelos/turno.dart';
import '../../datos/repositorios/repositorioTurnosImpl.dart';
import '../../logica/casosDeUsoTurnos.dart';
import '../controladores/controladorTurnos.dart';

class PantallaModificarTurno extends StatefulWidget {
  // Recibimos el turno que queremos modificar.
  final Turno turno;

  const PantallaModificarTurno({
    super.key,
    required this.turno,
  });

  @override
  State<PantallaModificarTurno> createState() =>
      _PantallaModificarTurnoState();
}

class _PantallaModificarTurnoState extends State<PantallaModificarTurno> {

  // Controladores para obtener y modificar los datos escritos.
  late TextEditingController medicoController;
  late TextEditingController especialidadController;
  late TextEditingController fechaController;
  late TextEditingController horaController;

  // Controlador que conecta la pantalla con los casos de uso.
  final ControladorTurnos controlador = ControladorTurnos(
    CasosDeUsoTurnos(
      RepositorioTurnosImpl(),
    ),
  );

  @override
  void initState() {
    super.initState();

    // Cargamos los datos actuales del turno en los campos.
    medicoController = TextEditingController(
      text: widget.turno.medico,
    );

    especialidadController = TextEditingController(
      text: widget.turno.especialidad,
    );

    fechaController = TextEditingController(
      text: widget.turno.fecha,
    );

    horaController = TextEditingController(
      text: widget.turno.hora,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar turno'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Campo para modificar el médico.
            TextField(
              controller: medicoController,
              decoration: const InputDecoration(
                labelText: 'Médico',
              ),
            ),

            // Campo para modificar la especialidad.
            TextField(
              controller: especialidadController,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
              ),
            ),

            // Campo para modificar la fecha.
            TextField(
              controller: fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha',
              ),
            ),

            // Campo para modificar la hora.
            TextField(
              controller: horaController,
              decoration: const InputDecoration(
                labelText: 'Hora',
              ),
            ),

            const SizedBox(height: 25),

            // Guarda los cambios realizados.
            ElevatedButton(
              onPressed: () async {

                final turnoModificado = Turno(
                  id: widget.turno.id,
                  paciente: widget.turno.paciente,
                  medico: medicoController.text,
                  especialidad: especialidadController.text,
                  fecha: fechaController.text,
                  hora: horaController.text,
                  estado: widget.turno.estado,
                  sincronizado: false,
                );

                // Envía el turno modificado al caso de uso.
                await controlador.casosDeUso.modificarTurno(
                  turnoModificado,
                );

                if (!mounted) return;

                // Volvemos a la pantalla anterior.
                Navigator.pop(context);
              },

              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}