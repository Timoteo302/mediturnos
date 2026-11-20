import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/comunes/botonPrincipal.dart';
import 'package:mediturnos/componentes/comunes/campoTexto.dart';
import 'package:mediturnos/componentes/comunes/indicadorConexion.dart';
import 'package:mediturnos/componentes/comunes/notificacionApp.dart';
import 'package:mediturnos/componentes/turnos/bannerSinConexionTurno.dart';
import 'package:mediturnos/componentes/turnos/tarjetaResumenTurno.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/estilosTexto.dart';
import 'package:mediturnos/invitado/datos/fuentes/clienteInvitadoApi.dart';
import 'package:mediturnos/invitado/datos/modelos/excepcionInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitado.dart';
import 'package:mediturnos/invitado/datos/repositorios/repositorioInvitadoApi.dart';
import 'package:mediturnos/invitado/presentacion/viewmodels/datosInvitadoViewModel.dart';
import 'package:mediturnos/invitado/presentacion/pantallas/pantallaActivarCuenta.dart';
import 'package:mediturnos/medicos/datos/modelos/medico.dart';
import 'package:mediturnos/servicios/estadoConexionViewModel.dart';
import 'package:mediturnos/turnos/datos/modelos/turnoDetalle.dart';

// Pantalla para completar los datos personales del invitado antes de confirmar la reserva.
class PantallaDatosInvitado extends StatelessWidget {
  final Medico medico;
  final DateTime fecha;
  final String hora;

  const PantallaDatosInvitado({
    super.key,
    required this.medico,
    required this.fecha,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<RepositorioInvitado>(
      create: (_) => RepositorioInvitadoApi(ClienteInvitadoApi(http.Client())),
      child: ChangeNotifierProvider<DatosInvitadoViewModel>(
        create: (context) => DatosInvitadoViewModel(context.read<RepositorioInvitado>()),
        child: _VistaDatosInvitado(
          medico: medico,
          fecha: fecha,
          hora: hora,
        ),
      ),
    );
  }
}

class _VistaDatosInvitado extends StatefulWidget {
  final Medico medico;
  final DateTime fecha;
  final String hora;

  const _VistaDatosInvitado({
    required this.medico,
    required this.fecha,
    required this.hora,
  });

  @override
  State<_VistaDatosInvitado> createState() => _VistaDatosInvitadoState();
}

class _VistaDatosInvitadoState extends State<_VistaDatosInvitado> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    dniController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  Future<void> _confirmarReserva() async {
    final vm = context.read<DatosInvitadoViewModel>();

    try {
      final resultado = await vm.reservar(
        nombre: nombreController.text,
        apellido: apellidoController.text,
        dni: dniController.text,
        telefono: telefonoController.text,
        email: emailController.text,
        medicoId: widget.medico.id,
        fecha: widget.fecha,
        hora: widget.hora,
      );

      if (!mounted) return;

      if (resultado != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaActivarCuenta(
              email: resultado.email,
              venceEnDias: resultado.venceEnDias,
              turno: resultado.turno,
              codigoDemostracion: resultado.codigoDemostracion,
            ),
          ),
        );
      }
    } on ExcepcionInvitado catch (e) {
      if (!mounted) return;

      if (e.tipo == TipoErrorInvitado.cuentaExistente) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Ya tenés una cuenta', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
            content: Text(e.mensaje ?? 'Ya existe una cuenta registrada con este correo o DNI.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Volver', style: TextStyle(color: ColoresApp.textoSecundario)),
              ),
              ElevatedButton(
                onPressed: () {
                  final authVm = context.read<AutenticacionViewModel>();
                  authVm.guardarReservaPendiente(
                    medicoId: widget.medico.id,
                    fecha: widget.fecha,
                    hora: widget.hora,
                    medicoNombre: widget.medico.nombreCompleto,
                    especialidadNombre: widget.medico.especialidad.nombre,
                  );
                  authVm.salirDeInvitado();
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaLogin(emailPrellenado: emailController.text.trim()),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primario,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else if (e.tipo == TipoErrorInvitado.horarioOcupado) {
        mostrarNotificacionApp(
          context,
          tipo: TipoNotificacionApp.error,
          titulo: 'Ese horario ya se ocupó',
          mensaje: 'Elegí otro horario.',
        );
        Navigator.pop(context);
      } else if (e.tipo == TipoErrorInvitado.limiteInvitado) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Límite alcanzado', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
            content: Text(e.mensaje ?? 'Alcanzaste el límite de reservas como invitado.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaActivarCuenta(
                        email: emailController.text.trim(),
                        venceEnDias: 3,
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
      } else if (e.mensaje != null) {
        mostrarNotificacionApp(
          context,
          tipo: TipoNotificacionApp.error,
          titulo: 'No pudimos procesar tu reserva',
          mensaje: e.mensaje!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DatosInvitadoViewModel>();
    final conectado = context.watch<EstadoConexionViewModel>().conectado;

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
          'Datos de Reserva',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
        ),
        centerTitle: true,
        actions: const [IndicadorConexion()],
      ),
      body: Column(
        children: [
          const BannerSinConexionTurno(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TarjetaResumenTurno(
                    medico: MedicoDetalle.fromJson(widget.medico.toJson()),
                    fecha: widget.fecha,
                    hora: widget.hora,
                  ),
                  const SizedBox(height: 24),
                  const Text('Completá tus datos para reservar', style: EstilosTexto.tituloGrande),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: nombreController,
                    etiqueta: 'Nombre',
                    hintText: 'Juan',
                    iconoPrefijo: Icons.person_outline,
                    mensajeError: vm.errorNombre,
                    alCambiar: (_) => vm.limpiarError('nombre'),
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    controller: apellidoController,
                    etiqueta: 'Apellido',
                    hintText: 'Pérez',
                    iconoPrefijo: Icons.person_outline,
                    mensajeError: vm.errorApellido,
                    alCambiar: (_) => vm.limpiarError('apellido'),
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    controller: dniController,
                    etiqueta: 'DNI',
                    hintText: '12345678',
                    iconoPrefijo: Icons.badge_outlined,
                    tipoTeclado: TextInputType.number,
                    mensajeError: vm.errorDni,
                    alCambiar: (_) => vm.limpiarError('dni'),
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    controller: emailController,
                    etiqueta: 'Correo electrónico',
                    hintText: 'ejemplo@correo.com',
                    iconoPrefijo: Icons.email_outlined,
                    tipoTeclado: TextInputType.emailAddress,
                    mensajeError: vm.errorEmail,
                    alCambiar: (_) => vm.limpiarError('email'),
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    controller: telefonoController,
                    etiqueta: 'Teléfono',
                    hintText: '1122334455',
                    iconoPrefijo: Icons.phone_outlined,
                    tipoTeclado: TextInputType.phone,
                    mensajeError: vm.errorTelefono,
                    alCambiar: (_) => vm.limpiarError('telefono'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Te vamos a mandar un código a tu correo para que crees tu contraseña y puedas ver tus turnos.',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),
                  if (conectado == false) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Necesitás conexión para crear tu cuenta y reservar.',
                      style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (vm.errorGeneral != null) ...[
                    const SizedBox(height: 16),
                    Text(vm.errorGeneral!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 24),
                  BotonPrincipal(
                    texto: 'Confirmar turno',
                    onPressed: (conectado == false || vm.cargando)
                        ? null
                        : () {
                            _confirmarReserva();
                          },
                    cargando: vm.cargando,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
