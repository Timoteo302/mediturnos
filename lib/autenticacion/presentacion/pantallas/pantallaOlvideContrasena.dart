
import 'package:flutter/material.dart';

// Importamos nuestros componentes reutilizables y configuraciones
import '../../../componentes/botonPrincipal.dart';
import '../../../componentes/campoTexto.dart';
import '../../../componentes/iconoEncabezado.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Pantalla para recuperar la contraseña (olvidé mi contraseña).
class PantallaOlvideContrasena extends StatefulWidget {
  const PantallaOlvideContrasena({super.key});

  @override
  State<PantallaOlvideContrasena> createState() => _PantallaOlvideContrasenaState();
}

class _PantallaOlvideContrasenaState extends State<PantallaOlvideContrasena> {

  // Controlador para el campo de texto (correo o DNI según la pestaña seleccionada)
  final TextEditingController inputController = TextEditingController();

  // Variable para controlar si el metodo seleccionado es por Correo (true) o por DNI (false)
  bool esPorCorreo = true;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold es un widget que proporciona una estructura básica
    return Scaffold(
      // Barra superior con botón atrás, título y perfil
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),

      // Cuerpo desplazable
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta principal contenedora
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge superior "Recuperar contraseña"
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

                  // icono central de candado
                  const Center(
                    child: IconoEncabezado(
                      icono: Icons.lock_outline,
                      tamanio: 80,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Titulo principal
                  const Center(
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: EstilosTexto.tituloGrande,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitulo explicativo
                  const Text(
                    'Ingresá el correo electrónico asociado a tu cuenta o tu DNI. Te enviaremos un código de verificación de 6 dígitos para restablecerla.',
                    style: EstilosTexto.subtitulo,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Selector de metodo (Por Correo / Por DNI)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              esPorCorreo = true;
                              inputController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: esPorCorreo ? ColoresApp.fondoIcono : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: esPorCorreo ? ColoresApp.primario : ColoresApp.bordeCampo,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 18,
                                  color: esPorCorreo ? ColoresApp.primario : ColoresApp.textoSecundario,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Por Correo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: esPorCorreo ? ColoresApp.primario : ColoresApp.textoSecundario,
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
                          onTap: () {
                            setState(() {
                              esPorCorreo = false;
                              inputController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !esPorCorreo ? ColoresApp.fondoIcono : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !esPorCorreo ? ColoresApp.primario : ColoresApp.bordeCampo,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 18,
                                  color: !esPorCorreo ? ColoresApp.primario : ColoresApp.textoSecundario,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Por DNI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !esPorCorreo ? ColoresApp.primario : ColoresApp.textoSecundario,
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

                  // Campo dinamico segun la pestaña seleccionada
                  CampoTexto(
                    controller: inputController,
                    etiqueta: esPorCorreo ? 'Correo electrónico registrado' : 'DNI registrado',
                    hintText: esPorCorreo ? 'ejemplo@mediturnos.com.ar' : '38450123',
                    tipoTeclado: esPorCorreo ? TextInputType.emailAddress : TextInputType.number,
                    iconoPrefijo: esPorCorreo ? Icons.email_outlined : Icons.badge_outlined,
                  ),

                  const SizedBox(height: 6),

                  // Texto de ayuda inferior
                  Text(
                    esPorCorreo
                        ? 'ℹ Enviaremos el código temporal a esta casilla.'
                        : 'ℹ Enviaremos las instrucciones al correo vinculado a este DNI.',
                    style: const TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),

                  const SizedBox(height: 28),

                  // Botón principal con ícono de envío
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Lógica para enviar el código de recuperación
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primarioBoton,
                        foregroundColor: ColoresApp.textoBoton,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text(
                        'Enviar código de recuperación',
                        style: EstilosTexto.textoBotonPrincipal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta de ayuda inferior (No recibiste el correo)
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
                            text: '385-5742182',
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

            // Enlace para volver al login
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
