import 'package:flutter/material.dart';
import '../controladores/controladorTurnos.dart';
import '../../logica/casosDeUsoTurnos.dart';
import '../../datos/repositorios/repositorioTurnosImpl.dart';

import '../../datos/modelos/turno.dart';


import 'pantallaRegistrarTurno.dart';
import 'pantallaModificarTurno.dart';

class PantallaTurnos extends StatefulWidget {
  const PantallaTurnos({super.key});

  @override
  State<PantallaTurnos> createState() => _PantallaTurnosState();
}

class _PantallaTurnosState extends State<PantallaTurnos> {
  late ControladorTurnos controlador;
  List turnos = [];

  @override
  void initState() {
    super.initState();

    controlador = ControladorTurnos(
      CasosDeUsoTurnos(
        RepositorioTurnosImpl(),
      ),
    );

    cargarTurnos();
  }

  // Carga los turnos guardados en la base de datos local.
  Future<void> cargarTurnos() async {
    final datos = await controlador.cargarTurnos();

    setState(() {
      turnos = datos;
    });
  }

  // Guarda un turno de prueba en la base de datos local.
  Future<void> guardarTurnoPrueba() async {
    final turno = Turno(
      id: 1,
      paciente: 'Timoteo Wierna',
      medico: 'Dr. Juan Pérez',
      especialidad: 'Clínica Médica',
      fecha: '22/09/2026',
      hora: '10:30',
      estado: 'Pendiente',
      sincronizado: false,
    );

    await controlador.casosDeUso.registrarTurno(turno);

    await cargarTurnos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Turnos'),
      ),
      body: turnos.isEmpty
          ? const Center(
        child: Text('No hay turnos registrados'),
      )
          : ListView.builder(
        itemCount: turnos.length,
        itemBuilder: (context, index) {
          final turno = turnos[index];

          return ListTile(
            title: Text(
              '${turno.medico} - ${turno.especialidad}',
            ),
            subtitle: Text(
              '${turno.fecha} - ${turno.hora}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Botón para modificar el turno.
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaModificarTurno(
                          turno: turno,
                        ),
                      ),
                    );

                    // Actualizamos la lista al volver.
                    await cargarTurnos();
                  },
                ),

                // Botón para eliminar el turno.
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await controlador.casosDeUso.cancelarTurno(turno.id);

                    await cargarTurnos();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PantallaRegistrarTurno(),
            ),
          );

          // Vuelve a cargar los turnos después de registrar uno.
          await cargarTurnos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}