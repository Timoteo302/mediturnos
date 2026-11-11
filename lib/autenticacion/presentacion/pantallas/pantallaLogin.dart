import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/campoTexto.dart';
import '../../../componentes/comunes/iconoEncabezado.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos pantallas de destino segun rol
import '../../../turnos/presentacion/pantallas/pantallaInicio.dart';
import '../../../turnos/presentacion/pantallas/pantallaInicioAdmin.dart';
import 'pantallaCrearCuenta.dart';
import 'pantallaOlvideContrasena.dart';

import '../viewmodels/autenticacionViewModel.dart';
import '../../datos/modelos/usuario.dart';

class PantallaLogin extends StatefulWidget {
  final String? emailPrellenado;

  const PantallaLogin({super.key, this.emailPrellenado});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  late final TextEditingController emailController;
  final TextEditingController contrasenaController = TextEditingController();
  bool mostrarContrasena = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.emailPrellenado ?? '');
  }

  @override
  void dispose() {
    emailController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();

    final vm = context.read<AutenticacionViewModel>();
    final exito = await vm.iniciarSesion(emailController.text, contrasenaController.text);

    if (!mounted) return;

    if (exito) {
      if (vm.modoSinConexion) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingresaste sin conexión. Se usan los datos guardados en este dispositivo.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      if (vm.esAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicioAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicio()),
        );
      }
    } else if (vm.errorGeneral != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorGeneral!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _irACrearCuenta() async {
    final emailCreado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const PantallaCrearCuenta()),
    );

    if (emailCreado != null && mounted) {
      setState(() {
        emailController.text = emailCreado;
      });
    }
  }

  void _irAOlvideContrasena() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaOlvideContrasena()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AutenticacionViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const IconoEncabezado(),
                const SizedBox(height: 24),
                const Text('MediTurnos', style: EstilosTexto.tituloGrande),
                const SizedBox(height: 8),
                const Text(
                  'Accedé a tu gestión de turnos médicos',
                  style: EstilosTexto.subtitulo,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                CampoTexto(
                  controller: emailController,
                  etiqueta: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  iconoPrefijo: Icons.email_outlined,
                  tipoTeclado: TextInputType.emailAddress,
                  mensajeError: vm.errorEmail,
                  alCambiar: (_) => vm.limpiarErrores(),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controller: contrasenaController,
                  etiqueta: 'Contraseña',
                  hintText: '••••••••••••',
                  iconoPrefijo: Icons.lock_outline,
                  ocultarTexto: !mostrarContrasena,
                  mensajeError: vm.errorContrasena,
                  alCambiar: (_) => vm.limpiarErrores(),
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _irAOlvideContrasena,
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: EstilosTexto.enlace,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                BotonPrincipal(
                  texto: 'Iniciar sesión',
                  onPressed: _iniciarSesion,
                  cargando: vm.cargando,
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tenés una cuenta? ',
                      style: EstilosTexto.subtitulo,
                    ),
                    GestureDetector(
                      onTap: _irACrearCuenta,
                      child: const Text(
                        'Crear cuenta',
                        style: EstilosTexto.enlaceDestacado,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
