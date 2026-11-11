import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/campoTexto.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../datos/repositorios/repositorioAutenticacion.dart';
import '../viewmodels/registroViewModel.dart';

class PantallaCrearCuenta extends StatelessWidget {
  const PantallaCrearCuenta({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistroViewModel(context.read<RepositorioAutenticacion>()),
      child: const _VistaCrearCuenta(),
    );
  }
}

class _VistaCrearCuenta extends StatefulWidget {
  const _VistaCrearCuenta();

  @override
  State<_VistaCrearCuenta> createState() => _VistaCrearCuentaState();
}

class _VistaCrearCuentaState extends State<_VistaCrearCuenta> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController = TextEditingController();

  bool mostrarContrasena = false;
  bool mostrarConfirmacion = false;

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    dniController.dispose();
    emailController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    final vm = context.read<RegistroViewModel>();
    final exito = await vm.registrar(
      nombre: nombreController.text,
      apellido: apellidoController.text,
      dni: dniController.text,
      email: emailController.text,
      contrasena: contrasenaController.text,
      confirmacion: confirmarContrasenaController.text,
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada. Ya podés iniciar sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, emailController.text.trim().toLowerCase());
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
    final vm = context.watch<RegistroViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person_add_outlined, size: 16, color: ColoresApp.primario),
                  SizedBox(width: 6),
                  Text(
                    'Nuevo paciente',
                    style: TextStyle(
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Completá tus datos para registrarte como paciente',
              style: EstilosTexto.tituloGrande,
            ),
            const SizedBox(height: 8),
            const Text(
              'Vas a poder solicitar y gestionar tus turnos médicos desde la app.',
              style: EstilosTexto.subtitulo,
            ),
            const SizedBox(height: 24),
            
            // Tarjeta Datos Personales
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
                  Row(
                    children: const [
                      Icon(Icons.person_outline, color: ColoresApp.primario, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '1. Datos personales',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: nombreController,
                    etiqueta: 'Nombre *',
                    hintText: 'Ej. Lucas',
                    iconoPrefijo: Icons.person_outline,
                    mensajeError: vm.errorNombre,
                    alCambiar: (_) => vm.limpiarError('nombre'),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: apellidoController,
                    etiqueta: 'Apellido *',
                    hintText: 'Ej. González',
                    iconoPrefijo: Icons.person_outline,
                    mensajeError: vm.errorApellido,
                    alCambiar: (_) => vm.limpiarError('apellido'),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: dniController,
                    etiqueta: 'DNI (Documento Nacional de Identidad) *',
                    hintText: '38450123',
                    tipoTeclado: TextInputType.number,
                    iconoPrefijo: Icons.badge_outlined,
                    mensajeError: vm.errorDni,
                    alCambiar: (_) => vm.limpiarError('dni'),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ℹ Ingresá tu DNI sin puntos ni espacios.',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta Datos de Acceso
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
                  Row(
                    children: const [
                      Icon(Icons.lock_outline, color: ColoresApp.primario, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '2. Datos de acceso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: emailController,
                    etiqueta: 'Correo electrónico *',
                    hintText: 'ejemplo@correo.com',
                    tipoTeclado: TextInputType.emailAddress,
                    iconoPrefijo: Icons.email_outlined,
                    mensajeError: vm.errorEmail,
                    alCambiar: (_) => vm.limpiarError('email'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ℹ Vas a usar este correo para iniciar sesión.',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: contrasenaController,
                    etiqueta: 'Contraseña *',
                    hintText: '••••••••',
                    ocultarTexto: !mostrarContrasena,
                    iconoPrefijo: Icons.lock_outline,
                    mensajeError: vm.errorContrasena,
                    alCambiar: (_) => vm.limpiarError('contrasena'),
                    iconoSufijo: IconButton(
                      icon: Icon(
                        mostrarContrasena ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: ColoresApp.textoSecundario,
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarContrasena = !mostrarContrasena;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '🔒 Mínimo 8 caracteres (recomendado incluir letras y números).',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: confirmarContrasenaController,
                    etiqueta: 'Confirmar contraseña *',
                    hintText: '••••••••',
                    ocultarTexto: !mostrarConfirmacion,
                    iconoPrefijo: Icons.lock_outline,
                    mensajeError: vm.errorConfirmacion,
                    alCambiar: (_) => vm.limpiarError('confirmacion'),
                    iconoSufijo: IconButton(
                      icon: Icon(
                        mostrarConfirmacion ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: ColoresApp.textoSecundario,
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarConfirmacion = !mostrarConfirmacion;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: ColoresApp.primario),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tus datos personales se guardan de forma confidencial.',
                      style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            BotonPrincipal(
              texto: 'Crear cuenta',
              onPressed: _registrar,
              cargando: vm.cargando,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Ya tenés cuenta? ',
                  style: EstilosTexto.subtitulo,
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Iniciar sesión',
                    style: EstilosTexto.enlaceDestacado,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
