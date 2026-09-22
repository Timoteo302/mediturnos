import 'package:flutter/material.dart';

import '../controladores/controladorTurnos.dart';
import '../../logica/casosDeUsoTurnos.dart';
import '../../datos/repositorios/repositorioTurnosImpl.dart';
import '../../datos/modelos/turno.dart';

class PantallaRegistrarTurno extends StatefulWidget {
  const PantallaRegistrarTurno({super.key});

  @override
  State<PantallaRegistrarTurno> createState() =>
      _PantallaRegistrarTurnoState();
}

class _PantallaRegistrarTurnoState extends State<PantallaRegistrarTurno> {
  final TextEditingController medicoController = TextEditingController();
  final TextEditingController especialidadController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();

  final ControladorTurnos controlador = ControladorTurnos(
    CasosDeUsoTurnos(
      RepositorioTurnosImpl(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar turno'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: medicoController,
              decoration: const InputDecoration(
                labelText: 'Médico',
              ),
            ),

            TextField(
              controller: especialidadController,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
              ),
            ),

            TextField(
              controller: fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha',
              ),
            ),

            TextField(
              controller: horaController,
              decoration: const InputDecoration(
                labelText: 'Hora',
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () async {
                final turno = Turno(
                  id: DateTime.now().millisecondsSinceEpoch,
                  paciente: 'Timoteo Wierna',
                  medico: medicoController.text,
                  especialidad: especialidadController.text,
                  fecha: fechaController.text,
                  hora: horaController.text,
                  estado: 'Pendiente',
                  sincronizado: false,
                );

                await controlador.casosDeUso.registrarTurno(turno);

                if (!mounted) return;

                Navigator.pop(context);
              },
              child: const Text('Registrar turno'),
            ),
          ],
        ),
      ),
    );
  }
}