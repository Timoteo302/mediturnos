import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/comunes/indicadorConexion.dart';
import 'package:mediturnos/componentes/comunes/campoTexto.dart';
import 'package:mediturnos/componentes/comunes/notificacionCambiosGuardados.dart';
import 'package:mediturnos/componentes/comunes/validadorTelefono.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import '../../datos/fuentes/clientePerfilApi.dart';
import '../../datos/repositorios/repositorioPerfilApi.dart';
import '../viewmodels/editarPerfilViewModel.dart';

import 'package:http/http.dart' as http;

// Pantalla para editar los datos de perfil del usuario.
class PantallaEditarPerfil extends StatelessWidget {
  const PantallaEditarPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditarPerfilViewModel(
        RepositorioPerfilApi(ClientePerfilApi(context.read<http.Client>())),
      ),
      child: const _VistaEditarPerfil(),
    );
  }
}

class _VistaEditarPerfil extends StatefulWidget {
  const _VistaEditarPerfil();

  @override
  State<_VistaEditarPerfil> createState() => _VistaEditarPerfilState();
}

class _VistaEditarPerfilState extends State<_VistaEditarPerfil> {
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _telefonoController;
  String _email = '—';
  String _dni = '—';
  bool _esPaciente = false;

  @override
  void initState() {
    super.initState();
    final usuario = context.read<AutenticacionViewModel>().usuarioActual;
    _nombreController = TextEditingController(text: usuario?.nombre ?? '');
    _apellidoController = TextEditingController(text: usuario?.apellido ?? '');
    _telefonoController = TextEditingController(text: usuario?.paciente?.telefono ?? '');
    _email = usuario?.email ?? '—';
    _esPaciente = usuario?.paciente != null;
    if (usuario?.paciente?.dni != null && usuario!.paciente!.dni.isNotEmpty) {
      _dni = usuario.paciente!.dni;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Guarda los cambios del perfil consultando la API e iguala la copia local si hay conexión a internet.
  Future<void> _guardarCambios() async {
    FocusScope.of(context).unfocus();
    final authVm = context.read<AutenticacionViewModel>();
    final usuario = authVm.usuarioActual;
    if (usuario == null) return;

    if (authVm.modoSinConexion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitás conexión para guardar los cambios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vm = context.read<EditarPerfilViewModel>();
    final usuarioActualizado = await vm.guardar(
      usuario: usuario,
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      telefono: _telefonoController.text,
    );

    if (!mounted) return;

    if (usuarioActualizado != null) {
      await authVm.actualizarUsuarioActual(usuarioActualizado);
      if (!mounted) return;
      mostrarNotificacionCambiosGuardados(context);
      Navigator.pop(context);
    } else if (vm.errorGeneral != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorGeneral!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditarPerfilViewModel>();

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: true,
        actions: const [IndicadorConexion()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoTexto(
              controller: _nombreController,
              etiqueta: 'Nombre',
              hintText: 'Ingresá tu nombre',
              iconoPrefijo: Icons.person_outline,
              mensajeError: vm.errorNombre,
              alCambiar: (_) => vm.limpiarError('nombre'),
            ),
            const SizedBox(height: 16),
            CampoTexto(
              controller: _apellidoController,
              etiqueta: 'Apellido',
              hintText: 'Ingresá tu apellido',
              iconoPrefijo: Icons.person_outline,
              mensajeError: vm.errorApellido,
              alCambiar: (_) => vm.limpiarError('apellido'),
            ),
            const SizedBox(height: 16),
            _construirCampoEmailLectura(),
            if (_esPaciente) ...[
              const SizedBox(height: 16),
              CampoTexto(
                controller: _telefonoController,
                etiqueta: 'Teléfono',
                hintText: 'Ej: 3841 404667',
                iconoPrefijo: Icons.phone_outlined,
                tipoTeclado: TextInputType.phone,
                formateadoresEntrada: formateadoresTelefono,
                mensajeError: vm.errorTelefono,
                alCambiar: (_) => vm.limpiarError('telefono'),
              ),
              const SizedBox(height: 16),
              _construirCampoDniLectura(),
            ],
            const SizedBox(height: 32),
            BotonPrincipal(
              texto: 'Guardar cambios',
              onPressed: _guardarCambios,
              cargando: vm.cargando,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCampoEmailLectura() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: ColoresApp.textoSecundario),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Correo electrónico - Solo lectura',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirCampoDniLectura() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_ind_outlined, color: ColoresApp.textoSecundario),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Documento Nacional (DNI) - Solo lectura',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _dni,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
