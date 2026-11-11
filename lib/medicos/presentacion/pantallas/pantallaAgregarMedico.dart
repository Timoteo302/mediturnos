// Aqui importamos los paquetes de Flutter necesarios para la pantalla.
import 'package:flutter/material.dart';

// Importamos los colores y estilos centralizados de la aplicacion.
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import '../../../componentes/comunes/campoTexto.dart';
import 'pantallaGestionHorarios.dart';

// Esta clase representa la pantalla principal. Es un StatefulWidget porque sus datos cambian.
class PantallaAgregarMedico extends StatefulWidget {
  
  // Recibimos opcionalmente un mapa con los datos del medico si venimos desde el boton "Editar".
  // Si viene nulo, significa que estamos creando un medico nuevo ("Agregar nuevo medico").
  final Map<String, dynamic>? medicoAEditar;

  const PantallaAgregarMedico({super.key, this.medicoAEditar});

  // Este metodo conecta la pantalla con su clase de estado (_PantallaAgregarMedicoState),
  // que es donde guardamos las variables, los controladores y construimos la interfaz visual.
  @override
  State<PantallaAgregarMedico> createState() => _PantallaAgregarMedicoState();
}

class _PantallaAgregarMedicoState extends State<PantallaAgregarMedico> {
  
  // Controladores para leer lo valores de los campos de texto
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController matriculaController;

  // Variables para los selectores (especialidad y  sede)
  String especialidadSeleccionada = 'Cardiologia';
  String sedeSeleccionada = 'Sede Central Palermo, Consultorio 4';

  // Variable para el switch de 'Medico activo'
  bool medicoActivo = true;

  @override
  void initState() {
    super.initState();

    // Verificamos si estamos editando un medico existente o creando uno nuevo
    if (widget.medicoAEditar != null) {
      // Si nos pasaron un medico, rellenamos los campos con sus datos actuales
      final nombreCompleto = widget.medicoAEditar!['nombre'].toString();
      // Separamos el nombre y apellido de forma basica para el ejemplo
      final partesNombre = nombreCompleto.replaceFirst(RegExp(r'^(Dr\.|Dra\.)\s*'), '').split(' ');
      
      nombreController = TextEditingController(text: partesNombre.isNotEmpty ? partesNombre[0] : '');
      apellidoController = TextEditingController(text: partesNombre.length > 1 ? partesNombre.sublist(1).join(' ') : '');
      matriculaController = TextEditingController(text: widget.medicoAEditar!['matricula'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
      
      especialidadSeleccionada = widget.medicoAEditar!['especialidad'].toString();
      if (!['Cardiologia', 'Traumatologia', 'Pediatria', 'Clinica Medica'].contains(especialidadSeleccionada)) {
        especialidadSeleccionada = 'Cardiologia';
      }

      medicoActivo = widget.medicoAEditar!['activo'] ?? true;
    } else {
      // Si es nuevo, ponemos valores por defecto para agregar
      nombreController = TextEditingController(text: '');
      apellidoController = TextEditingController(text: '');
      matriculaController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    // Liberamos memoria de los controladores cuando salimos de la pantalla
    nombreController.dispose();
    apellidoController.dispose();
    matriculaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos si estamos en modo edicion o modo creacion
    final bool esEdicion = widget.medicoAEditar != null;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      
      // Barra superior con titulo dinamico segun si estamos agregando o modificando
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              esEdicion ? 'Modificar medico' : 'Agregar nuevo medico',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'MediTurnos Gestion Profesional',
              style: TextStyle(
                fontSize: 11,
                color: ColoresApp.textoSecundario,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
        ],
      ),

      // Cuerpo con scroll para rellenar el formulario
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Tarjeta superior para la foto de perfil del medico
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: ColoresApp.primario, width: 2),
                        ),
                        child: const Icon(Icons.person_outline, size: 36, color: ColoresApp.primario),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: ColoresApp.primario,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Foto de perfil medico',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColoresApp.textoTitulo,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Opcional. Formatos JPG o PNG hasta 5MB.',
                          style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Aviso de campos obligatorios
            Row(
              children: const [
                Icon(Icons.info_outline, size: 14, color: ColoresApp.textoSecundario),
                SizedBox(width: 6),
                Text(
                  'Todos los campos marcados con (*) son obligatorios.',
                  style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. Campo Nombre reutilizando nuestro componente CampoTexto
            CampoTexto(
              controller: nombreController,
              etiqueta: 'Nombre *',
              hintText: 'Ej. Carolina',
              iconoPrefijo: Icons.badge_outlined,
              iconoSufijo: const Icon(Icons.check_circle, color: ColoresApp.primario, size: 18),
            ),

            const SizedBox(height: 16),

            // 3. Campo Apellido reutilizando CampoTexto
            CampoTexto(
              controller: apellidoController,
              etiqueta: 'Apellido *',
              hintText: 'Ej. Herrera',
              iconoPrefijo: Icons.person_outline,
              iconoSufijo: const Icon(Icons.check_circle, color: ColoresApp.primario, size: 18),
            ),

            const SizedBox(height: 16),

            // 4. Campo Matricula Nacional (MN) reutilizando CampoTexto con teclado numerico
            CampoTexto(
              controller: matriculaController,
              etiqueta: 'Matricula Nacional (MN) *',
              hintText: '142890',
              tipoTeclado: TextInputType.number,
              iconoPrefijo: Icons.assignment_ind_outlined,
              iconoSufijo: const Icon(Icons.verified, color: ColoresApp.primario, size: 18),
            ),
            const SizedBox(height: 4),
            const Text(
              'Habilitacion registrada ante el Ministerio de Salud de la Nacion.',
              style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
            ),

            const SizedBox(height: 16),

            // 5. Selector de Especialidad medica
            const Text(
              'Especialidad medica *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_outlined, color: ColoresApp.primario, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: especialidadSeleccionada,
                        items: ['Cardiologia', 'Traumatologia', 'Pediatria', 'Clinica Medica', 'Cardiologia / Electrofisiologia'].map((String valor) {
                          return DropdownMenuItem<String>(
                            value: valor,
                            child: Text(valor, style: const TextStyle(fontSize: 14, color: ColoresApp.textoTitulo)),
                          );
                        }).toList(),
                        onChanged: (nuevoValor) {
                          setState(() {
                            especialidadSeleccionada = nuevoValor!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 6. Selector de Sede de atencion
            const Text(
              'Sede de atencion',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: ColoresApp.primario, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sedeSeleccionada,
                        items: [
                          'Sede Central Palermo, Consultorio 4',
                          'Sede Belgrano, Consultorio 2',
                          'Sede Norte, Consultorio 1',
                        ].map((String valor) {
                          return DropdownMenuItem<String>(
                            value: valor,
                            child: Text(valor, style: const TextStyle(fontSize: 13, color: ColoresApp.textoTitulo), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (nuevoValor) {
                          setState(() {
                            sedeSeleccionada = nuevoValor!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 7. Switch de 'Medico activo'
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: ColoresApp.primario, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Medico activo',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Disponible para asignacion de turnos y agenda online',
                          style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: medicoActivo,
                    activeColor: ColoresApp.primario,
                    onChanged: (valor) {
                      setState(() {
                        medicoActivo = valor;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 8. Boton para configurar dias y horarios
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.bordeCampo),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_month_outlined, color: ColoresApp.primario, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Configuracion de dias y horarios',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navegamos a la pantalla de gestionar horarios al tocar "Definir agenda"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaGestionHorarios(),
                        ),
                      );
                    },
                    child: const Text(
                      'Definir agenda',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 9. Boton principal (Dice "Guardar cambios" si es edicion, o "Guardar medico" si es nuevo)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aca guardariamos los cambios en la base de datos y volveriamos atras
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioBoton,
                  foregroundColor: ColoresApp.textoBoton,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.check, size: 20),
                label: Text(
                  esEdicion ? 'Guardar cambios' : 'Guardar medico',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 10. Boton secundario "Cancelar"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.textoSecundario),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
