import 'package:flutter/material.dart';
import 'package:mediturnos/componentes/turnos/barraInferiorContinuar.dart';
import 'package:mediturnos/componentes/turnos/carruselCalendario.dart';
import 'package:mediturnos/componentes/turnos/grillaHorariosTurno.dart';
import 'package:mediturnos/componentes/turnos/tarjetaDoctorResumen.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'pantallaConfirmarSolicitud.dart';

import 'package:mediturnos/componentes/comunes/dialogoDescartarCambios.dart';
import 'package:mediturnos/componentes/turnos/dialogoHorarioOcupado.dart';

/// Pantalla para seleccionar fecha y hora disponible de un médico (07. Seleccionar turno).
class PantallaSeleccionarTurno extends StatefulWidget {
  const PantallaSeleccionarTurno({super.key});

  @override
  State<PantallaSeleccionarTurno> createState() => _PantallaSeleccionarTurnoState();
}

class _PantallaSeleccionarTurnoState extends State<PantallaSeleccionarTurno> {
  DateTime _fechaSeleccionada = DateTime.now();
  // 👈 La hora empieza vacía / nula (sin selección por defecto)
  String? _horaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () async {
            // 👈 Abre el diálogo modal de confirmación antes de salir
            final bool? descarto = await mostrarDialogoDescartarCambios(context);
            if (descarto == true && context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Seleccionar turno',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TarjetaDoctorResumen(),
            const SizedBox(height: 20),

            // Carrusel dinámico de días
            CarruselCalendario(
              fechaSeleccionada: _fechaSeleccionada,
              alSeleccionarFecha: (fecha) {
                setState(() {
                  _fechaSeleccionada = fecha;
                  _horaSeleccionada = null; // Al cambiar de día, reseteamos la hora
                });
              },
            ),

            const SizedBox(height: 20),
            _construirEncabezadoHorarios(),
            const SizedBox(height: 14),

            // Grilla de horarios dinámica
            GrillaHorariosTurno(
              horaSeleccionada: _horaSeleccionada ?? '',
              alSeleccionarHora: (hora) {
                setState(() {
                  _horaSeleccionada = hora;
                });
              },
            ),

            const SizedBox(height: 20),
            _construirBannerProvisorio(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BarraInferiorContinuar(
        resumenTurno: _horaSeleccionada != null
            ? '${_fechaSeleccionada.day}/${_fechaSeleccionada.month} - $_horaSeleccionada'
            : 'Seleccioná un horario',
        onContinuar: _horaSeleccionada != null
            ? () {
                // Avanzar a la pantalla de confirmación
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaConfirmarSolicitud(),
                  ),
                );
              }
            : () {}, // Deshabilitado si no eligió hora
      ),
    );
  }

  Widget _construirEncabezadoHorarios() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 18, color: ColoresApp.primario),
            const SizedBox(width: 6),
            Text(
              'Horarios para el ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
            ),
          ],
        ),
        const Text('Zona horaria: ART', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
      ],
    );
  }

  Widget _construirBannerProvisorio() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: const [
          Icon(Icons.lock_clock_outlined, color: ColoresApp.primario, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Los turnos se reservan de forma provisoria durante 10 minutos para completar la solicitud.',
              style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}