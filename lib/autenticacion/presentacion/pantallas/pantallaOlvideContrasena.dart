import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/campoTexto.dart';
import '../../../componentes/comunes/iconoEncabezado.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../datos/repositorios/repositorioAutenticacion.dart';
import '../viewmodels/recuperacionViewModel.dart';

class PantallaOlvideContrasena extends StatelessWidget {
  const PantallaOlvideContrasena({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecuperacionViewModel(context.read<RepositorioAutenticacion>()),
      child: const _VistaOlvideContrasena(),
    );
  }
}

class _VistaOlvideContrasena extends StatefulWidget {
  const _VistaOlvideContrasena();

  @override
  State<_VistaOlvideContrasena> createState() => _VistaOlvideContrasenaState();
}

class _VistaOlvideContrasenaState extends State<_VistaOlvideContrasena> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController nuevaContrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController = TextEditingController();

  bool mostrarContrasena = false;
  bool mostrarConfirmacion = false;

  @override
  void dispose() {
    inputController.dispose();
    codigoController.dispose();
    nuevaContrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _solicitar(RecuperacionViewModel vm) async {
    FocusScope.of(context).unfocus();
    await vm.solicitarCodigo(inputController.text);

    if (!mounted) return;

    if (vm.errorGeneral != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorGeneral!), backgroundColor: Colors.red),
      );
    } else if (vm.codigoDemostracion != null) {
      // Mostrar dialogo de modo demostracion
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Código de recuperación'),
          content: Text('Todavía no hay un servidor de correo conectado (modo demostración), por eso te mostramos el código acá: ${vm.codigoDemostracion}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _restablecer(RecuperacionViewModel vm) async {
    FocusScope.of(context).unfocus();
    final exito = await vm.restablecer(
      codigo: codigoController.text,
      nuevaContrasena: nuevaContrasenaController.text,
      confirmacion: confirmarContrasenaController.text,
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada. Ya podés iniciar sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (vm.errorGeneral != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorGeneral!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecuperacionViewModel>();

    if (vm.paso == PasoRecuperacion.listo) {
      // Por seguridad, si ya se completo, cerramos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.health_and_safety_outlined, color: ColoresApp.primario, size: 22),
            SizedBox(width: 8),
            Text('MediTurnos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColoresApp.bordeCampo),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: vm.paso == PasoRecuperacion.solicitar
                  ? _PasoSolicitar(
                      inputController: inputController,
                      vm: vm,
                      onEnviar: () => _solicitar(vm),
                    )
                  : _PasoRestablecer(
                      codigoController: codigoController,
                      nuevaContrasenaController: nuevaContrasenaController,
                      confirmarContrasenaController: confirmarContrasenaController,
                      mostrarContrasena: mostrarContrasena,
                      mostrarConfirmacion: mostrarConfirmacion,
                      onTogglePass: () => setState(() => mostrarContrasena = !mostrarContrasena),
                      onToggleConf: () => setState(() => mostrarConfirmacion = !mostrarConfirmacion),
                      vm: vm,
                      onCambiar: () => _restablecer(vm),
                    ),
            ),

            const SizedBox(height: 20),

            // Tarjeta de ayuda inferior
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.help_outline, color: ColoresApp.primario, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '¿No recibiste el correo?\n',
                            style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo, fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Revisá tu carpeta de correo no deseado (spam) o contactá a la central de turnos de tu clínica al ',
                            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 12),
                          ),
                          TextSpan(
                            text: '0800-TURNO-MED',
                            style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo, fontSize: 12),
                          ),
                          TextSpan(
                            text: '.',
                            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_back, size: 16, color: ColoresApp.primario),
                  SizedBox(width: 6),
                  Text(
                    'Volver a Iniciar sesión',
                    style: EstilosTexto.enlaceDestacado,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PasoSolicitar extends StatelessWidget {
  final TextEditingController inputController;
  final RecuperacionViewModel vm;
  final VoidCallback onEnviar;

  const _PasoSolicitar({
    required this.inputController,
    required this.vm,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
              Icon(Icons.lock_reset_outlined, size: 16, color: ColoresApp.primario),
              SizedBox(width: 6),
              Text(
                'Recuperar contraseña',
                style: TextStyle(
                  color: ColoresApp.primario,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: IconoEncabezado(
            icono: Icons.lock_outline,
            tamanio: 80,
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            '¿Olvidaste tu contraseña?',
            style: EstilosTexto.tituloGrande,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ingresá el correo electrónico asociado a tu cuenta o tu DNI. Te enviaremos un código de verificación de 6 dígitos para restablecerla.',
          style: EstilosTexto.subtitulo,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => vm.cambiarMetodo(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !vm.porDni ? ColoresApp.fondoIcono : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: !vm.porDni ? ColoresApp.primario : ColoresApp.bordeCampo,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: !vm.porDni ? ColoresApp.primario : ColoresApp.textoSecundario,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Por Correo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !vm.porDni ? ColoresApp.primario : ColoresApp.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => vm.cambiarMetodo(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: vm.porDni ? ColoresApp.fondoIcono : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: vm.porDni ? ColoresApp.primario : ColoresApp.bordeCampo,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 18,
                        color: vm.porDni ? ColoresApp.primario : ColoresApp.textoSecundario,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Por DNI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: vm.porDni ? ColoresApp.primario : ColoresApp.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CampoTexto(
          controller: inputController,
          etiqueta: !vm.porDni ? 'Correo electrónico registrado' : 'DNI registrado',
          hintText: !vm.porDni ? 'ejemplo@mediturnos.com.ar' : '38450123',
          tipoTeclado: !vm.porDni ? TextInputType.emailAddress : TextInputType.number,
          iconoPrefijo: !vm.porDni ? Icons.email_outlined : Icons.badge_outlined,
          mensajeError: vm.errorDato,
        ),
        const SizedBox(height: 6),
        Text(
          !vm.porDni
              ? 'ℹ Enviaremos el código temporal a esta casilla.'
              : 'ℹ Enviaremos las instrucciones al correo vinculado a este DNI.',
          style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
        ),
        const SizedBox(height: 28),
        BotonPrincipal(
          texto: 'Enviar código de recuperación',
          onPressed: onEnviar,
          cargando: vm.cargando,
        ),
      ],
    );
  }
}

class _PasoRestablecer extends StatelessWidget {
  final TextEditingController codigoController;
  final TextEditingController nuevaContrasenaController;
  final TextEditingController confirmarContrasenaController;
  final bool mostrarContrasena;
  final bool mostrarConfirmacion;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConf;
  final RecuperacionViewModel vm;
  final VoidCallback onCambiar;

  const _PasoRestablecer({
    required this.codigoController,
    required this.nuevaContrasenaController,
    required this.confirmarContrasenaController,
    required this.mostrarContrasena,
    required this.mostrarConfirmacion,
    required this.onTogglePass,
    required this.onToggleConf,
    required this.vm,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Icon(Icons.lock_reset_outlined, size: 16, color: ColoresApp.primario),
                  SizedBox(width: 6),
                  Text(
                    'Restablecer contraseña',
                    style: TextStyle(
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => vm.volverASolicitar(),
              child: const Text('Volver', style: EstilosTexto.enlace),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Center(
          child: IconoEncabezado(
            icono: Icons.lock_open_outlined,
            tamanio: 80,
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Ingresá el código y tu nueva contraseña',
            style: EstilosTexto.tituloGrande,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Te enviamos un código de verificación. Ingresalo abajo junto con tu nueva clave.',
          style: EstilosTexto.subtitulo,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CampoTexto(
          controller: codigoController,
          etiqueta: 'Código de 6 dígitos',
          hintText: '123456',
          tipoTeclado: TextInputType.number,
          iconoPrefijo: Icons.pin_outlined,
          mensajeError: vm.errorCodigo,
        ),
        const SizedBox(height: 16),
        CampoTexto(
          controller: nuevaContrasenaController,
          etiqueta: 'Nueva contraseña',
          hintText: '••••••••',
          ocultarTexto: !mostrarContrasena,
          iconoPrefijo: Icons.lock_outline,
          mensajeError: vm.errorContrasena,
          iconoSufijo: IconButton(
            icon: Icon(
              mostrarContrasena ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: ColoresApp.textoSecundario,
            ),
            onPressed: onTogglePass,
          ),
        ),
        const SizedBox(height: 16),
        CampoTexto(
          controller: confirmarContrasenaController,
          etiqueta: 'Confirmar contraseña',
          hintText: '••••••••',
          ocultarTexto: !mostrarConfirmacion,
          iconoPrefijo: Icons.lock_outline,
          mensajeError: vm.errorConfirmacion,
          iconoSufijo: IconButton(
            icon: Icon(
              mostrarConfirmacion ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: ColoresApp.textoSecundario,
            ),
            onPressed: onToggleConf,
          ),
        ),
        const SizedBox(height: 28),
        BotonPrincipal(
          texto: 'Cambiar contraseña',
          onPressed: onCambiar,
          cargando: vm.cargando,
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => vm.solicitarCodigo(codigoController.text),
            child: const Text('Reenviar código', style: EstilosTexto.enlace),
          ),
        ),
      ],
    );
  }
}
