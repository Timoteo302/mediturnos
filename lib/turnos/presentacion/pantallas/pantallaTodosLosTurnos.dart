import 'package:flutter/material.dart';

import 'package:mediturnos/componentes/admin/barraSelectoresAdmin.dart';
import 'package:mediturnos/componentes/admin/chipFiltroEstadoAdmin.dart';
import 'package:mediturnos/componentes/admin/datosEjemploTurnosAdmin.dart';
import 'package:mediturnos/componentes/admin/modalSelectorMedicosAdmin.dart';
import 'package:mediturnos/componentes/admin/tarjetaTurnoAdmin.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/navegacion/barraNavegacionAdmin.dart';

/// Esta pantalla muestra al administrador la grilla completa de todos los turnos de la clínica,
/// permitiendo filtrar por fecha, médico y estado (Todos, Pendientes, Confirmados).
class PantallaTodosLosTurnos extends StatefulWidget {
  const PantallaTodosLosTurnos({super.key});

  @override
  State<PantallaTodosLosTurnos> createState() => _PantallaTodosLosTurnosState();
}

class _PantallaTodosLosTurnosState extends State<PantallaTodosLosTurnos> {
  String _filtroEstado = 'Todos';
  String _medicoSeleccionado = 'Todos';
  DateTime _fechaSeleccionada = DateTime.now();

  bool _esHoy(DateTime fecha) {
    final ahora = DateTime.now();
    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
  }

  String _formatearFechaBarra(DateTime fecha) {
    final diasSemana = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    final nombreDia = diasSemana[fecha.weekday % 7];
    final nombreMes = meses[fecha.month - 1];
    final textoFecha = '$nombreDia ${fecha.day} $nombreMes ${fecha.year}';

    return _esHoy(fecha) ? 'Hoy: $textoFecha' : textoFecha;
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      setState(() => _fechaSeleccionada = seleccionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicosDisponibles =
        datosEjemploTurnosAdmin.map((t) => t.nombreMedico).toSet().toList();

    final turnosHoyBase =
        _esHoy(_fechaSeleccionada) ? datosEjemploTurnosAdmin : <TurnoEjemploAdmin>[];
    final turnosBaseFechaMedico = turnosHoyBase.where((t) {
      if (_medicoSeleccionado == 'Todos') return true;
      return t.nombreMedico == _medicoSeleccionado;
    }).toList();

    final turnosFiltrados = turnosBaseFechaMedico.where((t) {
      if (_filtroEstado == 'Pendientes') return t.estadoTexto == 'Pendiente';
      if (_filtroEstado == 'Confirmados') return t.estadoTexto == 'Confirmado';
      return true;
    }).toList();

    final cantTodos = turnosBaseFechaMedico.length;
    final cantPendientes =
        turnosBaseFechaMedico.where((t) => t.estadoTexto == 'Pendiente').length;
    final cantConfirmados =
        turnosBaseFechaMedico.where((t) => t.estadoTexto == 'Confirmado').length;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text(
              'PANEL ADMINISTRADOR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ColoresApp.primario,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Todos los turnos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selectores de Fecha y Médico
            BarraSelectoresAdmin(
              textoFecha: _formatearFechaBarra(_fechaSeleccionada),
              textoMedico: _medicoSeleccionado,
              onTapFecha: _seleccionarFecha,
              onTapMedico: () => mostrarModalMedicosAdmin(
                context,
                medicoSeleccionado: _medicoSeleccionado,
                medicosDisponibles: medicosDisponibles,
                alSeleccionar: (medico) =>
                    setState(() => _medicoSeleccionado = medico),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Chips de estado (Todos, Pendientes, Confirmados)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChipFiltroEstadoAdmin(
                    etiqueta: 'Todos',
                    cantidad: '$cantTodos',
                    seleccionado: _filtroEstado == 'Todos',
                    onTap: () => setState(() => _filtroEstado = 'Todos'),
                  ),
                  const SizedBox(width: 8),
                  ChipFiltroEstadoAdmin(
                    etiqueta: 'Pendientes',
                    cantidad: '$cantPendientes',
                    seleccionado: _filtroEstado == 'Pendientes',
                    onTap: () => setState(() => _filtroEstado = 'Pendientes'),
                  ),
                  const SizedBox(width: 8),
                  ChipFiltroEstadoAdmin(
                    etiqueta: 'Confirmados',
                    cantidad: '$cantConfirmados',
                    seleccionado: _filtroEstado == 'Confirmados',
                    onTap: () => setState(() => _filtroEstado = 'Confirmados'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Contador de registros
            Text(
              'Mostrando ${turnosFiltrados.length} de ${turnosBaseFechaMedico.length} registros',
              style: const TextStyle(
                  fontSize: 12, color: ColoresApp.textoSecundario),
            ),

            const SizedBox(height: 16),

            // 4. Lista de tarjetas o mensaje según resultado de filtros
            if (!_esHoy(_fechaSeleccionada)) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No hay turnos para esta fecha.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primario,
                    ),
                  ),
                ),
              ),
            ] else if (turnosFiltrados.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No hay turnos con estos filtros.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primario,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ...turnosFiltrados.map((turno) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TarjetaTurnoAdmin(turno: turno),
                );
              }),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: ColoresApp.primarioBoton,
        elevation: 2,
        icon: const Icon(Icons.add, color: ColoresApp.textoBoton),
        label: const Text(
          'Nuevo turno',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: ColoresApp.textoBoton),
        ),
      ),
      bottomNavigationBar: const BarraNavegacionAdmin(indiceActual: 1),
    );
  }
}
