import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../datos/fuentes/almacenToken.dart';
import '../../datos/fuentes/almacenSesionLocal.dart';
import '../viewmodels/autenticacionViewModel.dart';
import '../../../componentes/comunes/notificacionApp.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../inicio/presentacion/pantallas/pantallaInicioPaciente.dart';
import '../../../inicio/presentacion/pantallas/pantallaInicioAdmin.dart';
import 'pantallaLogin.dart';

// Pantalla inicial de carga que verifica el token y restaura la sesión del usuario o navega al login.
class PantallaArranque extends StatefulWidget {
  const PantallaArranque({super.key});

  @override
  State<PantallaArranque> createState() => _PantallaArranqueState();
}

class _PantallaArranqueState extends State<PantallaArranque> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decidirNavegacionInicial();
    });
  }

  Future<void> _decidirNavegacionInicial() async {
    final authVm = context.read<AutenticacionViewModel>();
    final almacenToken = context.read<AlmacenToken>();
    final local = context.read<AlmacenSesionLocal>();

    final huboSesionExpirada = await almacenToken.sesionExpirada();
    final sesionRestaurada = await authVm.restaurarSesion(local, almacenToken);

    if (!mounted) return;

    if (sesionRestaurada && authVm.estaAutenticado) {
      final destino = authVm.esAdmin ? const PantallaInicioAdmin() : const PantallaInicioPaciente();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destino),
      );
    } else {
      await almacenToken.borrar();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
      );

      if (huboSesionExpirada) {
        mostrarNotificacionAppGlobal(
          tipo: TipoNotificacionApp.advertencia,
          titulo: 'Tu sesión venció',
          mensaje: 'Iniciá sesión de nuevo. Tus turnos pendientes se van a enviar después.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
        ),
      ),
    );
  }
}
