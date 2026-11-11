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

  // Valores seleccionados para modificar el turno.
  String? medicoSeleccionado;
  String? especialidadSeleccionada;

  // Controladores para obtener y modificar los datos.
  late TextEditingController fechaController;
  late TextEditingController horaController;

  // Lista de médicos disponibles DE PRUEBA; LUEGO SE HACE CON DATOS DESDE LA API.
  final List<String> medicos = [
    'Dr. Juan Pérez',
    'Dra. María Gómez',
    'Dr. Carlos López',
  ];

  // Lista de especialidades disponibles.
  final List<String> especialidades = [
    'Clínica médica',
    'Cardiología',
    'Pediatría',
  ];

  // Controlador que conecta la pantalla con los casos de uso.
  final ControladorTurnos controlador = ControladorTurnos(
    CasosDeUsoTurnos(
      RepositorioTurnosImpl(),
    ),
  );

  @override
  void initState() {
    super.initState();

    // Cargamos los datos actuales del turno.
    medicoSeleccionado = widget.turno.medico;
    especialidadSeleccionada = widget.turno.especialidad;

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Selector para modificar el médico.
            DropdownButtonFormField<String>(
              value: medicoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Médico',
              ),
              items: medicos.map((medico) {
                return DropdownMenuItem<String>(
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

            // Selector para modificar la especialidad.
            DropdownButtonFormField<String>(
              value: especialidadSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
              ),
              items: especialidades.map((especialidad) {
                return DropdownMenuItem<String>(
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

            // Campo para modificar la fecha.
            TextField(
              controller: fechaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                // Abrimos el calendario para seleccionar una nueva fecha.
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

            // Campo para modificar la hora.
            TextField(
              controller: horaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Hora',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                // Abrimos el selector de hora.
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

            // Guarda los cambios realizados.
            ElevatedButton(
              onPressed: () async {

                final turnoModificado = Turno(
                  id: widget.turno.id,
                  paciente: widget.turno.paciente,
                  medico: medicoSeleccionado ?? '',
                  especialidad: especialidadSeleccionada ?? '',
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