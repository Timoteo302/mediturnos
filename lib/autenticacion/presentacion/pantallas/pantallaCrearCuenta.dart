// Importamos los paquetes principales de Flutter
import 'package:flutter/material.dart';

// Importamos nuestros componentes reutilizables y configuraciones
import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/campoTexto.dart';
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

class PantallaCrearCuenta extends StatefulWidget {
  const PantallaCrearCuenta({super.key});

  @override
  State<PantallaCrearCuenta> createState() => _PantallaCrearCuentaState();
}

class _PantallaCrearCuentaState extends State<PantallaCrearCuenta> {

  // Controladores para capturar lo que el usuario escribe en cada campo
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController = TextEditingController();

  // Variables booleanas para controlar la visibilidad de las contraseñas (mostrar/ocultar ojito)
  bool mostrarContrasena = false;
  bool mostrarConfirmacion = false;

  @override
  void dispose() {
    // Liberamos memoria de los controladores cuando la pantalla se destruye
    nombreController.dispose();
    apellidoController.dispose();
    dniController.dispose();
    emailController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold es un widget que proporciona una estructura básica
    return Scaffold(
      // Barra superior con botón de retroceso, título e ícono de perfil
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Vuelve a la pantalla anterior (Login)
        ),
        title: const Text('Crear cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),

      // Cuerpo desplazable para evitar desbordamientos en pantallas chicas
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge superior "Nuevo paciente"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person_add_outlined, size: 16, color: ColoresApp.primario),
                  SizedBox(width: 6),
                  Text(
                    'Nuevo paciente',
                    style: TextStyle(
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Título principal destacado
            const Text(
              'Completá tus datos para registrarte como paciente',
              style: EstilosTexto.tituloGrande,
            ),

            const SizedBox(height: 8),

            // Subtítulo explicativo
            const Text(
              'Vas a poder agendar consultas, recibir recordatorios y consultar tus órdenes médicas en cualquier momento.',
              style: EstilosTexto.subtitulo,
            ),

            const SizedBox(height: 24),

            // Tarjeta  para "1. Datos personales"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera de la sección
                  Row(
                    children: const [
                      Icon(Icons.person_outline, color: ColoresApp.primario, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '1. Datos personales',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Campo Nombre
                  CampoTexto(
                    controller: nombreController,
                    etiqueta: 'Nombre *',
                    hintText: 'Ej. Lucas',
                    iconoPrefijo: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  // Campo Apellido
                  CampoTexto(
                    controller: apellidoController,
                    etiqueta: 'Apellido *',
                    hintText: 'Ej. González',
                    iconoPrefijo: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  // Campo DNI con teclado numérico
                  CampoTexto(
                    controller: dniController,
                    etiqueta: 'DNI (Documento Nacional de Identidad) *',
                    hintText: '38450123',
                    tipoTeclado: TextInputType.number,
                    iconoPrefijo: Icons.badge_outlined,
                  ),

                  const SizedBox(height: 6),

                  // Texto de ayuda bajo el DNI
                  const Text(
                    'ℹ Ingresá tu DNI sin puntos ni espacios.',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta  para "2. Datos de acceso"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera de la sección
                  Row(
                    children: const [
                      Icon(Icons.lock_outline, color: ColoresApp.primario, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '2. Datos de acceso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Campo Correo electrónico
                  CampoTexto(
                    controller: emailController,
                    etiqueta: 'Correo electrónico *',
                    hintText: 'ejemplo@correo.com',
                    tipoTeclado: TextInputType.emailAddress,
                    iconoPrefijo: Icons.email_outlined,
                  ),

                  const SizedBox(height: 4),
                  const Text(
                    '✔ Te enviaremos las confirmaciones y comprobantes a esta casilla.',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),

                  const SizedBox(height: 16),

                  // Campo Contraseña con botón para mostrar/ocultar
                  CampoTexto(
                    controller: contrasenaController,
                    etiqueta: 'Contraseña *',
                    hintText: '••••••••',
                    ocultarTexto: !mostrarContrasena,
                    iconoPrefijo: Icons.lock_outline,
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

                  const SizedBox(height: 4),
                  const Text(
                    '🔒 Mínimo 8 caracteres (recomendado incluir letras y números).',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                  ),

                  const SizedBox(height: 16),

                  // Campo Confirmar Contraseña
                  CampoTexto(
                    controller: confirmarContrasenaController,
                    etiqueta: 'Confirmar contraseña *',
                    hintText: '••••••••',
                    ocultarTexto: !mostrarConfirmacion,
                    iconoPrefijo: Icons.lock_outline,
                    iconoSufijo: IconButton(
                      icon: Icon(
                        mostrarConfirmacion ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: ColoresApp.textoSecundario,
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarConfirmacion = !mostrarConfirmacion;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cuadro informativo de Ley de Protección de Datos
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: ColoresApp.primario),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Al registrarte aceptás la protección de datos médicos confidenciales regulada por la Ley de Salud de la República Argentina.',
                      style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón principal de registro
            BotonPrincipal(
              texto: 'Crear cuenta',
              onPressed: () {
                // Lógica de registro pendiente de integración con la API
              },
            ),

            const SizedBox(height: 24),

            // Enlace "¿Ya tenés cuenta? Iniciar sesión"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Ya tenés cuenta? ',
                  style: EstilosTexto.subtitulo,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Vuelve al Login
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: EstilosTexto.enlaceDestacado,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
