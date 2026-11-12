import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediturnos/autenticacion/presentacion/pantallas/pantallaLogin.dart';
import 'package:mediturnos/autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';
import 'package:mediturnos/componentes/perfil/tarjetaDatosPersonales.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/configuracion/datosInstitucion.dart';
import 'package:mediturnos/navegacion/barraNavegacionAdmin.dart';

/// Pantalla de perfil para el usuario con rol Administrador.
class PantallaPerfilAdmin extends StatelessWidget {
  const PantallaPerfilAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AutenticacionViewModel>();
    final usuario = authViewModel.usuarioActual;

    final String iniciales = usuario?.iniciales ?? '—';
    final String nombreCompleto = usuario?.nombreCompleto ?? '—';
    final String email = usuario?.email ?? '—';

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            _construirTarjetaEncabezado(iniciales, nombreCompleto, email),
            const SizedBox(height: 16),
            _construirSeccionInstitucion(),
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
      bottomNavigationBar: const BarraNavegacionAdmin(indiceActual: 3),
    );
  }

  Widget _construirTarjetaEncabezado(String iniciales, String nombre, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                iniciales,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primario,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoTitulo,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Administrador',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColoresApp.primario,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(
              fontSize: 13,
              color: ColoresApp.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionInstitucion() {
    final List<Widget> items = [];

    items.add(
      ItemDatoPerfil(
        icono: Icons.local_hospital_outlined,
        etiqueta: 'Nombre',
        valor: DatosInstitucion.nombre,
      ),
    );

    if (DatosInstitucion.telefono.isNotEmpty) {
      items.add(const Divider(height: 1, color: Color(0xFFE2E8F0)));
      items.add(
        const ItemDatoPerfil(
          icono: Icons.phone_outlined,
          etiqueta: 'Teléfono',
          valor: DatosInstitucion.telefono,
        ),
      );
    }

    final String? direccion = DatosInstitucion.direccion;
    if (direccion != null) {
      items.add(const Divider(height: 1, color: Color(0xFFE2E8F0)));
      items.add(
        ItemDatoPerfil(
          icono: Icons.location_on_outlined,
          etiqueta: 'Dirección',
          valor: direccion,
        ),
      );
    }

    final String? email = DatosInstitucion.email;
    if (email != null) {
      items.add(const Divider(height: 1, color: Color(0xFFE2E8F0)));
      items.add(
        ItemDatoPerfil(
          icono: Icons.email_outlined,
          etiqueta: 'Correo electrónico',
          valor: email,
        ),
      );
    }

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
          const Text(
            'Institución',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoTitulo,
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _construirBotonCerrarSesion(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final vm = context.read<AutenticacionViewModel>();
        await vm.cerrarSesion();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PantallaLogin()),
            (route) => false,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.logout_rounded, color: ColoresApp.textoSecundario, size: 20),
          SizedBox(width: 8),
          Text(
            'Cerrar sesión',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
