import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/campoTexto.dart';
import '../../../componentes/comunes/iconoEncabezado.dart';
import '../../../componentes/comunes/indicadorConexion.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos pantallas de destino segun rol
import '../../../inicio/presentacion/pantallas/pantallaInicioPaciente.dart';
import '../../../inicio/presentacion/pantallas/pantallaInicioAdmin.dart';
import '../../../invitado/presentacion/pantallas/pantallaActivarCuenta.dart';
import '../../../medicos/datos/modelos/especialidad.dart';
import '../../../medicos/datos/modelos/medico.dart';
import '../../../medicos/datos/repositorios/repositorioMedicos.dart';
import '../../../turnos/datos/repositorios/repositorioGestionTurnos.dart';
import '../../../turnos/presentacion/pantallas/pantallaConfirmarSolicitud.dart';
import '../../../turnos/presentacion/viewmodels/solicitudTurnoViewModel.dart';
import '../../datos/modelos/excepcionAutenticacion.dart';
import 'pantallaCrearCuenta.dart';
import 'pantallaOlvideContrasena.dart';

import '../viewmodels/autenticacionViewModel.dart';

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
            duration: Duration(seconds: 3),
          ),
        );
        // Pequeña pausa para que el SnackBar llegue a visualizarse antes de navegar
        await Future.delayed(const Duration(milliseconds: 800));
      }

      if (!mounted) return;

      if (!vm.esAdmin && vm.reservaPendiente != null) {
        final pendiente = vm.reservaPendiente!;
        vm.limpiarReservaPendiente();

        final medicoModel = Medico(
          id: pendiente.medicoId,
          nombre: pendiente.medicoNombre,
          apellido: '',
          matricula: '',
          activo: true,
          especialidad: Especialidad(id: 0, nombre: pendiente.especialidadNombre, activo: true),
        );

        final solicitudVm = SolicitudTurnoViewModel(
          context.read<RepositorioGestionTurnos>(),
          context.read<RepositorioMedicos>(),
          medicoModel,
        );

        await solicitudVm.cargarDisponibilidad(pendiente.fecha);
        solicitudVm.seleccionarHora(pendiente.hora);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<SolicitudTurnoViewModel>.value(
              value: solicitudVm,
              child: const PantallaConfirmarSolicitud(),
            ),
          ),
        );
      } else if (vm.esAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicioAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicioPaciente()),
        );
      }
    } else if (vm.errorGeneral != null) {
      if (vm.ultimoError == ErrorAutenticacion.activacionPendiente) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Cuenta pendiente de activación', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
            content: Text(vm.errorGeneral!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Volver', style: TextStyle(color: ColoresApp.textoSecundario)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaActivarCuenta(
                        email: emailController.text.trim(),
                        venceEnDias: 3,
                        vieneDeLogin: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primario,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Activar mi cuenta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorGeneral!),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  void _irAActivarCuenta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaActivarCuenta(
          email: emailController.text.trim(),
          venceEnDias: 7,
          vieneDeLogin: true,
        ),
      ),
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
                const Align(
                  alignment: Alignment.topRight,
                  child: IndicadorConexion(),
                ),
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _irAActivarCuenta,
                    child: const Text(
                      '¿Reservaste como invitado? Activá tu cuenta',
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: vm.cargando ? null : () {
                      vm.entrarComoInvitado();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaInicioPaciente()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ColoresApp.primario, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entrar como invitado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ),
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
