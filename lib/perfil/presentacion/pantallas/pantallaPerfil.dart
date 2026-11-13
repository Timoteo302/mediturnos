import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'package:mediturnos/componentes/perfil/tarjetaAvisosPerfil.dart';
import 'package:mediturnos/componentes/perfil/tarjetaDatosPersonales.dart';
import 'package:mediturnos/componentes/perfil/tarjetaEncabezadoPerfil.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaBuscarMedicos.dart';
import 'package:mediturnos/inicio/presentacion/pantallas/pantallaInicioPaciente.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaMisTurnos.dart';
import 'pantallaEditarPerfil.dart';

import 'package:mediturnos/componentes/comunes/notificacionCambiosGuardados.dart';

/// Pantalla de perfil de usuario del paciente (04. Mi perfil).
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  int _indiceNavegacion = 3;

  bool _notificacionesCorreo = true;
  bool _recordatoriosSms = true;

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AutenticacionViewModel>();
    final usuario = authVm.usuarioActual;
    final paciente = usuario?.paciente;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PantallaInicioPaciente()),
              );
            }
          },
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoTitulo,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            TarjetaEncabezadoPerfil(
              nombre: usuario != null ? '${usuario.nombre} ${usuario.apellido}' : 'Paciente',
              iniciales: usuario != null && usuario.nombre.isNotEmpty && usuario.apellido.isNotEmpty
                  ? '${usuario.nombre[0]}${usuario.apellido[0]}'.toUpperCase()
                  : 'PA',
              onEditar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaEditarPerfil()),
                );
              },
            ),
            const SizedBox(height: 16),
            _construirSeccionDatosPersonales(usuario, paciente),
            const SizedBox(height: 16),
            _construirSeccionAvisos(),
            const SizedBox(height: 24),
            _construirBotonCerrarSesion(context),
            const SizedBox(height: 12),
            const Text(
              'Versión 2.4.1 (Android M3)',
              style: TextStyle(fontSize: 12, color: ColoresApp.textoHint),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BarraNavegacionApp(
        indiceSeleccionado: _indiceNavegacion,
        alSeleccionar: (index) {
          setState(() => _indiceNavegacion = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaInicioPaciente()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaMisTurnos()),
            );
          }
        },
        destinos: const [
          ElementoNavegacion(etiqueta: 'Inicio', icono: Icons.home_outlined, iconoSeleccionado: Icons.home),
          ElementoNavegacion(etiqueta: 'Especialistas', icono: Icons.search, iconoSeleccionado: Icons.search),
          ElementoNavegacion(etiqueta: 'Mis Turnos', icono: Icons.calendar_today_outlined, iconoSeleccionado: Icons.calendar_today),
          ElementoNavegacion(etiqueta: 'Mi Perfil', icono: Icons.person_outline, iconoSeleccionado: Icons.person),
        ],
      ),
    );
  }

  Widget _construirBotonCerrarSesion(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AutenticacionViewModel>().cerrarSesion();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaLogin()),
          (route) => false,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.logout_rounded, color: ColoresApp.textoSecundario, size: 20),
          SizedBox(width: 8),
          Text(
            'Cerrar sesión',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionDatosPersonales(usuario, paciente) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Datos Personales y Cobertura', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
              Text('VERIFICADOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ColoresApp.primario, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          ItemDatoPerfil(icono: Icons.assignment_ind_outlined, etiqueta: 'Documento Nacional (DNI)', valor: paciente?.dni ?? 'No especificado'),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const ItemDatoPerfil(icono: Icons.medical_services_outlined, etiqueta: 'Cobertura médica', valor: 'Particular / General'),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ItemDatoPerfil(icono: Icons.email_outlined, etiqueta: 'Correo Electrónico', valor: usuario?.email ?? 'No especificado'),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ItemDatoPerfil(icono: Icons.phone_outlined, etiqueta: 'Teléfono de contacto', valor: paciente?.telefono ?? 'No especificado'),
        ],
      ),
    );
  }

  Widget _construirSeccionAvisos() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuración de Avisos de Turnos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
          const SizedBox(height: 10),
          ItemAvisoSwitch(
            icono: Icons.mail_outline,
            titulo: 'Notificaciones por correo',
            subtitulo: 'Confirmaciones y reprogramaciones',
            valor: _notificacionesCorreo,
            onChanged: (val) {
              setState(() {
                _notificacionesCorreo = val;
              });

              mostrarNotificacionCambiosGuardados(
                context,
                titulo: 'Cambios guardados',
                mensaje: 'Se actualizaron tus preferencias de notificación.',
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ItemAvisoSwitch(
            icono: Icons.chat_bubble_outline,
            titulo: 'Recordatorios por SMS',
            subtitulo: 'Avisos 24 hs antes de tu consulta',
            valor: _recordatoriosSms,
            onChanged: (val) => setState(() => _recordatoriosSms = val),
          ),
        ],
      ),
    );
  }
}
