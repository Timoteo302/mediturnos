import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/comunes/campoTexto.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Pantalla para editar los datos de perfil del usuario.
class PantallaEditarPerfil extends StatefulWidget {
  const PantallaEditarPerfil({super.key});

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  String _dni = '—';

  @override
  void initState() {
    super.initState();
    final usuario = context.read<AutenticacionViewModel>().usuarioActual;
    _nombreController = TextEditingController(text: usuario?.nombre ?? '');
    _apellidoController = TextEditingController(text: usuario?.apellido ?? '');
    _emailController = TextEditingController(text: usuario?.email ?? '');
    _telefonoController = TextEditingController(text: usuario?.paciente?.telefono ?? '');
    if (usuario?.paciente?.dni != null && usuario!.paciente!.dni.isNotEmpty) {
      _dni = usuario.paciente!.dni;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    // TODO(MVVM): los cambios no se persisten aún porque el endpoint de actualización de perfil se conecta en la fase de perfil.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por ahora los cambios no se guardan: se conecta con el servidor en la fase de perfil.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            ),
            const SizedBox(height: 16),
            CampoTexto(
              controller: _apellidoController,
              etiqueta: 'Apellido',
              hintText: 'Ingresá tu apellido',
              iconoPrefijo: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CampoTexto(
              controller: _emailController,
              etiqueta: 'Correo electrónico',
              hintText: 'ejemplo@correo.com',
              iconoPrefijo: Icons.email_outlined,
              tipoTeclado: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CampoTexto(
              controller: _telefonoController,
              etiqueta: 'Teléfono',
              hintText: 'Ej: +54 11 1234-5678',
              iconoPrefijo: Icons.phone_outlined,
              tipoTeclado: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _construirCampoDniLectura(),
            const SizedBox(height: 32),
            BotonPrincipal(
              texto: 'Guardar cambios',
              onPressed: _guardarCambios,
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
