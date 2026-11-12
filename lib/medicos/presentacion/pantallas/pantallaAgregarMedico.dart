import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/campoTexto.dart';
import '../../../componentes/medicos/selectorDesplegableCampo.dart';
import '../../../componentes/medicos/tarjetaConfiguracionAgenda.dart';
import '../../../componentes/medicos/tarjetaSwitchEstadoMedico.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../datos/modelos/medico.dart';
import '../../datos/repositorios/repositorioMedicos.dart';
import '../viewmodels/formularioMedicoViewModel.dart';
import 'pantallaGestionHorarios.dart';

class PantallaAgregarMedico extends StatelessWidget {
  final Medico? medicoAEditar;

  const PantallaAgregarMedico({super.key, this.medicoAEditar});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FormularioMedicoViewModel(
        context.read<RepositorioMedicos>(),
        medicoAEditar,
      ),
      child: _VistaAgregarMedico(medicoAEditar: medicoAEditar),
    );
  }
}

class _VistaAgregarMedico extends StatefulWidget {
  final Medico? medicoAEditar;

  const _VistaAgregarMedico({this.medicoAEditar});

  @override
  State<_VistaAgregarMedico> createState() => _VistaAgregarMedicoState();
}

class _VistaAgregarMedicoState extends State<_VistaAgregarMedico> {
  late final TextEditingController nombreController;
  late final TextEditingController apellidoController;
  late final TextEditingController matriculaController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.medicoAEditar?.nombre ?? '');
    apellidoController = TextEditingController(text: widget.medicoAEditar?.apellido ?? '');
    matriculaController = TextEditingController(text: widget.medicoAEditar?.matricula ?? '');
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    matriculaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    final vm = context.read<FormularioMedicoViewModel>();
    final medicoGuardado = await vm.guardar(
      nombre: nombreController.text,
      apellido: apellidoController.text,
      matricula: matriculaController.text,
    );

    if (!mounted) return;

    if (medicoGuardado != null) {
      Navigator.pop(context, true);
    } else if (vm.errorGeneral != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorGeneral!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FormularioMedicoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.esEdicion ? 'Modificar médico' : 'Agregar médico'),
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información profesional',
                    style: EstilosTexto.tituloGrande,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColoresApp.bordeCampo),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CampoTexto(
                          controller: nombreController,
                          etiqueta: 'Nombre *',
                          hintText: 'Ej. Juan Manuel',
                          iconoPrefijo: Icons.person_outline,
                          mensajeError: vm.errorNombre,
                          alCambiar: (_) => vm.limpiarError('nombre'),
                        ),
                        const SizedBox(height: 16),
                        CampoTexto(
                          controller: apellidoController,
                          etiqueta: 'Apellido *',
                          hintText: 'Ej. Gómez',
                          iconoPrefijo: Icons.person_outline,
                          mensajeError: vm.errorApellido,
                          alCambiar: (_) => vm.limpiarError('apellido'),
                        ),
                        const SizedBox(height: 16),
                        CampoTexto(
                          controller: matriculaController,
                          etiqueta: 'Matrícula *',
                          hintText: '114820',
                          tipoTeclado: TextInputType.number,
                          iconoPrefijo: Icons.badge_outlined,
                          mensajeError: vm.errorMatricula,
                          alCambiar: (_) => vm.limpiarError('matricula'),
                        ),
                        const SizedBox(height: 16),
                        SelectorDesplegableCampo<int>(
                          etiqueta: 'Especialidad médica *',
                          icono: Icons.category_outlined,
                          hint: 'Seleccioná una especialidad',
                          valorActual: vm.especialidadId,
                          mensajeError: vm.errorEspecialidad,
                          opciones: vm.especialidades
                              .map((esp) => DropdownMenuItem<int>(
                                    value: esp.id,
                                    child: Text(esp.nombre),
                                  ))
                              .toList(),
                          alCambiar: (id) => vm.seleccionarEspecialidad(id),
                        ),
                        const SizedBox(height: 16),
                        TarjetaSwitchEstadoMedico(
                          activo: vm.activo,
                          alCambiar: (val) => vm.cambiarActivo(val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TarjetaConfiguracionAgenda(
                    alDefinirAgenda: vm.esEdicion
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PantallaGestionHorarios(medico: widget.medicoAEditar),
                              ),
                            );
                          }
                        : null,
                  ),
                  const SizedBox(height: 24),
                  BotonPrincipal(
                    texto: vm.esEdicion ? 'Guardar cambios' : 'Guardar médico',
                    onPressed: _guardar,
                    cargando: vm.guardando,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
