import 'package:flutter/material.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/componentes/comunes/barraNavegacion.dart';
import 'package:mediturnos/componentes/perfil/tarjetaAvisosPerfil.dart';
import 'package:mediturnos/componentes/perfil/tarjetaDatosPersonales.dart';
import 'package:mediturnos/componentes/perfil/tarjetaEncabezadoPerfil.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaBuscarMedicos.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaInicio.dart';

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
                MaterialPageRoute(builder: (context) => const PantallaInicio()),
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
            TarjetaEncabezadoPerfil(onEditar: () {}),
            const SizedBox(height: 16),
            _construirSeccionDatosPersonales(),
            const SizedBox(height: 16),
            _construirSeccionAvisos(),
            const SizedBox(height: 24),
            _construirBotonCerrarSesion(),
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
              MaterialPageRoute(builder: (context) => const PantallaInicio()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaBuscarMedicos()),
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

  Widget _construirBotonCerrarSesion() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaLogin()),
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

  Widget _construirSeccionDatosPersonales() {
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
          const ItemDatoPerfil(icono: Icons.assignment_ind_outlined, etiqueta: 'Documento Nacional (DNI)', valor: '36.120.455'),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const ItemDatoPerfil(icono: Icons.medical_services_outlined, etiqueta: 'Obra Social / Prepaga', valor: 'OSDE 210', subvalor: 'Credencial N° 2309-8472910-01'),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const ItemDatoPerfil(icono: Icons.email_outlined, etiqueta: 'Correo Electrónico', valor: 'sofia.martinez@email.com'),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const ItemDatoPerfil(icono: Icons.phone_outlined, etiqueta: 'Teléfono de contacto', valor: '+54 11 4589-2311'),
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
            onChanged: (val) => setState(() => _notificacionesCorreo = val),
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