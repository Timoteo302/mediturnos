// Importamos Flutter Material.
// Contiene los elementos visuales que usamos para construir la pantalla:
// botones, textos, iconos, columnas, campos, navegación, etc.
import 'package:flutter/material.dart';

// Importamos nuestros componentes reutilizables.
// Así evitamos tener que diseñar un botón o un campo de texto desde cero.
import '../../../componentes/comunes/botonPrincipal.dart';
import '../../../componentes/comunes/campoTexto.dart';
import '../../../componentes/comunes/iconoEncabezado.dart';

// Importamos los archivos de configuración visual.
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

// Importamos la pantalla a la que iremos después de iniciar sesión
import '../../../turnos/presentacion/pantallas/pantallaInicio.dart';

// Importamos la pantalla a la que iremos después de iniciar sesión. (ADMIN)
import '../../../turnos/presentacion/pantallas/pantallaInicioAdmin.dart';

// Importamos la pantalla de inicio del paciente.
import '../../../turnos/presentacion/pantallas/pantallaInicio.dart';

// Importamos la pantalla para crear una cuenta.
import 'pantallaCrearCuenta.dart';

// Importamos la pantalla para recuperar contraseña.
import 'pantallaOlvideContrasena.dart';

// StatefulWidget indica que esta pantalla puede cambiar durante su uso.
// Por ejemplo, cuando mostramos u ocultamos la contraseña.
class PantallaLogin extends StatefulWidget {

  // Constructor de la pantalla
  // super.key permite identificar este widget dentro de Flutter
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

// Acá escribimos el comportamiento y los datos de la pantalla.
class _PantallaLoginState extends State<PantallaLogin> {

  // Controlador del campo de correo electrónico.
  // Permite leer lo que escribe el usuario.
  final TextEditingController emailController = TextEditingController();

  //Controlador del campo contraseña
  final TextEditingController contrasenaController = TextEditingController();

  // Variable que indica si la contraseña está visible.
  bool mostrarContrasena = false;


  // la funcion: dispose() se ejecuta cuando la pantalla deja de utilizarse
  // definitivamente.
  // Liberamos los controladores para evitar consumir memoria innecesariamente.
  @override
  void dispose() {
    emailController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  // Métod que se ejecuta cuando el usuario toca "Iniciar sesión".
  void _iniciarSesion() {

      // SOLO POR AHORA PARA INICIAR EN ADMIN O PACIENTE
    final textoEmail = emailController.text.toLowerCase().trim();

    // Si el correo contiene la palabra "admin", navega a la pantalla del administrador
    if (textoEmail.contains('admin')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PantallaInicioAdmin(),
        ),
      );
    } else {
      // Para cualquier otro correo, navega al inicio del paciente
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PantallaInicio(),
        ),
      );
    }


    // CODIGO VERDADERO:

    // pushReplacement permite navegar a otra pantalla
    // reemplazando la actual.
    // Por eso, el usuario no podrá volver al login con el botón atrás.
    //Navigator.pushReplacement(
    //  context,
    //  MaterialPageRoute(
        // Indicamos cuál será la nueva pantalla.
    //    builder: (context) => const PantallaInicio(),
    //  ),
    //);
  }

  // Métod que permite ir a la pantalla de registro.
  void _irACrearCuenta() {

    // push agrega una nueva pantalla encima de la actual.
    // A diferencia de pushReplacement, permite volver al login.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaCrearCuenta(),
      ),
    );
  }

  // Método para ir a la pantalla de recuperación de contraseña.
  void _irAOlvideContrasena() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaOlvideContrasena(),
      ),
    );
  }

  // build construye toda la interfaz visual de la pantalla.
  // Flutter lo vuelve a ejecutar cuando necesita actualizar la interfaz.
  @override
  Widget build(BuildContext context) {

    // Scaffold es un widget que proporciona una estructura básica
    return Scaffold(

      // SafeArea evita que el contenido quede debajo de elementos
      // del teléfono, como la cámara o la barra de estado.
      body: SafeArea(

        // Center centra el contenido
        child: Center(

          // Permite desplazar la pantalla si el contenido no entra
          // en el espacio disponible.
          child: SingleChildScrollView(

            // Establecemos los márgenes internos.
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

            // Column organiza los elementos uno debajo del otro.
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Mostramos nuestro componente de encabezado.
                // Ícono del encabezado
                const IconoEncabezado(),

                const SizedBox(height: 24),

                // Título principal de la aplicación.
                // El estilo viene de nuestro archivo estilosTexto.dart.
                // Título y subtítulo
                const Text('MediTurnos', style: EstilosTexto.tituloGrande),
                const SizedBox(height: 8),
                const Text(
                  'Accedé a tu gestión de turnos médicos',
                  style: EstilosTexto.subtitulo,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // Campo de Correo Electrónico
                CampoTexto(
                  controller: emailController,
                  etiqueta: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  iconoPrefijo: Icons.email_outlined,

                  // Hace que el teclado muestre opciones
                  // apropiadas para escribir un correo.
                  tipoTeclado: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Campo de Contraseña
                CampoTexto(
                  controller: contrasenaController,
                  etiqueta: 'Contraseña',
                  hintText: '••••••••••••',
                  iconoPrefijo: Icons.lock_outline,

                  // Si mostrarContrasena es false, ocultamos el texto.
                  ocultarTexto: !mostrarContrasena,

                  // Botón ubicado dentro del campo de contraseña.
                  // Permite mostrar u ocultar lo que escribimos.
                  iconoSufijo: IconButton(
                    icon: Icon(

                      // Operador ternario:
                      // si la contraseña está visible, mostramos el ojo.
                      // si está oculta, mostramos el ojo tachado.
                      mostrarContrasena
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: ColoresApp.textoSecundario,
                    ),

                    // Se ejecuta cuando tocamos el icono.
                    onPressed: () {

                      // setState avisa a Flutter que debe actualizar
                      // la interfaz porque cambió una variable.
                      setState(() {

                        // Cambiamos el valor de true a false
                        // o de false a true.
                        mostrarContrasena = !mostrarContrasena;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Olvidaste tu contraseña
                // Alineamos el enlace hacia la derecha.
                Align(
                  alignment: Alignment.centerRight,

                  // GestureDetector permite detectar cuando
                  // el usuario toca un elemento.
                  child: GestureDetector(
                    onTap: _irAOlvideContrasena,

                    // Texto del enlace.
                    // Actualmente no tiene ninguna funcionalidad
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: EstilosTexto.enlace,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Botón Iniciar Sesión
                BotonPrincipal(
                  texto: 'Iniciar sesión',

                  // Cuando se presiona, ejecutamos nuestro método.
                  onPressed: _iniciarSesion,
                ),

                const SizedBox(height: 36),

                // Enlace Crear Cuenta
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