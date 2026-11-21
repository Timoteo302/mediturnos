import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mediturnos/autenticacion/datos/fuentes/almacenToken.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/comunes/campoTexto.dart';
import 'package:mediturnos/componentes/comunes/indicadorConexion.dart';
import 'package:mediturnos/componentes/comunes/notificacionApp.dart';
import 'package:mediturnos/componentes/turnos/tarjetaResumenTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';
import 'package:mediturnos/inicio/presentacion/pantallas/pantallaInicioPaciente.dart';
import 'package:mediturnos/invitado/datos/fuentes/clienteInvitadoApi.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitadoApi.dart';
import 'package:mediturnos/invitado/presentacion/viewmodels/activarCuentaViewModel.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';

// Pantalla para activar la cuenta ingresando el código recibido por correo y definiendo la contraseña.
class PantallaActivarCuenta extends StatelessWidget {
  final String email;
  final int venceEnDias;
  final TurnoDetalle? turno;
  final String? codigoDemostracion;
  final bool vieneDeLogin;

  const PantallaActivarCuenta({
    super.key,
    required this.email,
    this.venceEnDias = 7,
    this.turno,
    this.codigoDemostracion,
    this.vieneDeLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<RepositorioInvitado>(
      create: (context) => RepositorioInvitadoApi(ClienteInvitadoApi(context.read<http.Client>(), almacenToken: context.read<AlmacenToken>())),
      child: ChangeNotifierProvider<ActivarCuentaViewModel>(
        create: (context) => ActivarCuentaViewModel(context.read<RepositorioInvitado>()),
        child: _VistaActivarCuenta(
          emailInicial: email,
          venceEnDias: venceEnDias,
          turno: turno,
          codigoDemostracionInicial: codigoDemostracion,
          vieneDeLogin: vieneDeLogin,
        ),
      ),
    );
  }
}

class _VistaActivarCuenta extends StatefulWidget {
  final String emailInicial;
  final int venceEnDias;
  final TurnoDetalle? turno;
  final String? codigoDemostracionInicial;
  final bool vieneDeLogin;

  const _VistaActivarCuenta({
    required this.emailInicial,
    required this.venceEnDias,
    this.turno,
    this.codigoDemostracionInicial,
    required this.vieneDeLogin,
  });

  @override
  State<_VistaActivarCuenta> createState() => _VistaActivarCuentaState();
}

class _VistaActivarCuentaState extends State<_VistaActivarCuenta> {
  late final TextEditingController emailController;
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController repetirController = TextEditingController();

  bool mostrarContrasena = false;
  bool mostrarRepetir = false;
  String? codigoDemoActual;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.emailInicial);
    codigoDemoActual = widget.codigoDemostracionInicial;
  }

  @override
  void dispose() {
    emailController.dispose();
    codigoController.dispose();
    contrasenaController.dispose();
    repetirController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final vm = context.read<ActivarCuentaViewModel>();
    final authVm = context.read<AutenticacionViewModel>();

    final usuario = await vm.confirmar(
      email: emailController.text.trim(),
      codigo: codigoController.text.trim(),
      contrasena: contrasenaController.text,
      repetir: repetirController.text,
    );

    if (!mounted) return;

    if (usuario != null) {
      await authVm.actualizarUsuarioActual(usuario);
      authVm.salirDeInvitado();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PantallaInicioPaciente()),
        (route) => false,
      );

      mostrarNotificacionAppGlobal(
        tipo: TipoNotificacionApp.exito,
        titulo: 'Cuenta activada',
        mensaje: 'Ya podés ver tus turnos.',
      );
    }
  }

  Future<void> _reenviar() async {
    final vm = context.read<ActivarCuentaViewModel>();
    final emailStr = emailController.text.trim();

    if (emailStr.isEmpty) {
      mostrarNotificacionApp(
        context,
        tipo: TipoNotificacionApp.error,
        titulo: 'Correo requerido',
        mensaje: 'Ingresá tu correo electrónico para solicitar el código.',
      );
      return;
    }

    final res = await vm.reenviar(emailStr);

    if (!mounted) return;

    if (res != null) {
      setState(() {
        codigoDemoActual = res['codigoDemostracion']?.toString();
      });
      mostrarNotificacionApp(
        context,
        tipo: TipoNotificacionApp.informacion,
        titulo: 'Código enviado',
        mensaje: 'Te enviamos un código a tu correo.',
      );
    }
  }

  void _loHagoDespues() {
    final authVm = context.read<AutenticacionViewModel>();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PantallaInicioPaciente()),
      (route) => false,
    );

    if (authVm.esInvitado) {
      mostrarNotificacionAppGlobal(
        tipo: TipoNotificacionApp.informacion,
        titulo: 'Tu turno quedó reservado',
        mensaje: 'Para verlo, creá tu contraseña con el código que te mandamos.',
      );
    }
  }

  String _obtenerSubtitulo() {
    final emailText = emailController.text.trim();
    if (emailText.isNotEmpty) {
      return 'Te mandamos un código a $emailText. Ingresalo y creá tu contraseña para ver tus turnos. Vence en ${widget.venceEnDias} días.';
    }
    return 'Ingresá tu correo electrónico y solicitá el código para activar tu cuenta y crear tu contraseña. Vence en ${widget.venceEnDias} días.';
  }

  String _obtenerTextoBotonReenviar(ActivarCuentaViewModel vm) {
    if (vm.reenvioBloqueado) {
      return 'Reenviar código (${vm.segundosRestantes}s)';
    }
    if (widget.vieneDeLogin || emailController.text.trim().isEmpty) {
      return 'Enviarme el código';
    }
    return 'Reenviar código';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivarCuentaViewModel>();

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Activar Cuenta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
        ),
        centerTitle: true,
        actions: const [IndicadorConexion()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.turno != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF166534)),
                      SizedBox(width: 8),
                      Text('¡Turno reservado!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ],
                  ),
                ),
                TarjetaResumenTurno(
                  medico: widget.turno!.medico,
                  fecha: widget.turno!.fecha,
                  hora: widget.turno!.hora,
                ),
                const SizedBox(height: 20),
              ],
              Text(
                _obtenerSubtitulo(),
                style: EstilosTexto.subtitulo,
              ),
              const SizedBox(height: 16),
              if (codigoDemoActual != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: ColoresApp.primario),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Modo demostración: tu código es $codigoDemoActual',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primario),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (widget.vieneDeLogin || emailController.text.trim().isEmpty) ...[
                CampoTexto(
                  controller: emailController,
                  etiqueta: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  iconoPrefijo: Icons.email_outlined,
                  tipoTeclado: TextInputType.emailAddress,
                  alCambiar: (_) {
                    setState(() {});
                    vm.limpiarError('email');
                  },
                ),
                const SizedBox(height: 14),
              ],
              CampoTexto(
                controller: codigoController,
                etiqueta: 'Código de 6 dígitos',
                hintText: '123456',
                iconoPrefijo: Icons.key_outlined,
                tipoTeclado: TextInputType.number,
                mensajeError: vm.errorCodigo,
                alCambiar: (_) => vm.limpiarError('codigo'),
              ),
              const SizedBox(height: 14),
              CampoTexto(
                controller: contrasenaController,
                etiqueta: 'Nueva contraseña',
                hintText: '••••••••••••',
                iconoPrefijo: Icons.lock_outline,
                ocultarTexto: !mostrarContrasena,
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
              const SizedBox(height: 14),
              CampoTexto(
                controller: repetirController,
                etiqueta: 'Repetir contraseña',
                hintText: '••••••••••••',
                iconoPrefijo: Icons.lock_outline,
                ocultarTexto: !mostrarRepetir,
                mensajeError: vm.errorRepetir,
                alCambiar: (_) => vm.limpiarError('repetir'),
                iconoSufijo: IconButton(
                  icon: Icon(
                    mostrarRepetir ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: ColoresApp.textoSecundario,
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarRepetir = !mostrarRepetir;
                    });
                  },
                ),
              ),
              if (vm.errorGeneral != null) ...[
                const SizedBox(height: 16),
                Text(vm.errorGeneral!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: 'Crear contraseña',
                onPressed: vm.cargando ? null : () => _confirmar(),
                cargando: vm.cargando,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: (vm.reenvioBloqueado || vm.cargando) ? null : () => _reenviar(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(_obtenerTextoBotonReenviar(vm)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _loHagoDespues,
                  child: const Text('Lo hago después', style: TextStyle(color: ColoresApp.textoSecundario)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
