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

  // DE PRUEBA PARA SELECCIONAR , Luego se cambia por la API por los datos de MYSQL
  String? medicoSeleccionado;
  String? especialidadSeleccionada;

  final List<String> medicos = [
    'Dr. Juan Pérez',
    'Dra. María Gómez',
    'Dr. Carlos López',
  ];

  final List<String> especialidades = [
    'Clínica médica',
    'Cardiología',
    'Pediatría',
  ];

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: medicoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Médico',
              ),
              items: medicos.map((medico) {
                return DropdownMenuItem(
                  value: medico,
                  child: Text(medico),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  medicoSeleccionado = valor;
                });
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: especialidadSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
              ),
              items: especialidades.map((especialidad) {
                return DropdownMenuItem(
                  value: especialidad,
                  child: Text(especialidad),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  especialidadSeleccionada = valor;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fechaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final fechaSeleccionada = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (fechaSeleccionada != null) {
                  fechaController.text =
                  '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}';
                }
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: horaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Hora',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final horaSeleccionada = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (horaSeleccionada != null) {
                  horaController.text =
                  '${horaSeleccionada.hour.toString().padLeft(2, '0')}:${horaSeleccionada.minute.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () async {
                final turno = Turno(
                  id: DateTime.now().millisecondsSinceEpoch,
                  paciente: 'Timoteo Wierna',
                  medico: medicoSeleccionado ?? '',
                  especialidad: especialidadSeleccionada ?? '',
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