// Importamos los paquetes principales de Flutter
import 'package:flutter/material.dart';

// Importamos configuraciones y estilos de la app
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';
import 'pantallaModificarTurno.dart';
import 'package:mediturnos/componentes/turnos/dialogoCancelarTurno.dart';


/// Pantalla de detalle completo de un turno médico (08. Detalle del turno).
class PantallaDetalleTurno extends StatelessWidget {
  const PantallaDetalleTurno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textoTitulo),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text(
              'Detalle del turno',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoTitulo,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'ID #TR-884920',
              style: TextStyle(
                fontSize: 12,
                color: ColoresApp.textoSecundario,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: ColoresApp.textoTitulo),
            onPressed: () {},
          ),
        ],
      ),

      // Cuerpo desplazable
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Tarjeta superior de Estado, Fecha y Número de Reserva
            Container(
              padding: const EdgeInsets.all(16),
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
                  // Fila de Badges: Confirmado (Verde) y Faltan X días (Celeste)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'Confirmado',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ColoresApp.fondoIcono,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Faltan 4 días',
                          style: TextStyle(
                            color: ColoresApp.primario,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Caja fecha y hora detallada (Fondo celeste claro)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        // Cuadrito calendario "VIE 24"
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ColoresApp.bordeCampo),
                          ),
                          child: Column(
                            children: const [
                              Text(
                                'VIE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.primario,
                                ),
                              ),
                              Text(
                                '24',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.textoTitulo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Fecha y hora
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Viernes, 24 de Noviembre',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.textoTitulo,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '🕒 10:30 hs • Duración aprox. 30m',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColoresApp.textoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: ColoresApp.bordeCampo, height: 1),
                  const SizedBox(height: 14),

                  // Número de reserva y botón Copiar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Número de reserva',
                            style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '#MED-2023-9941',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColoresApp.primario,
                          side: const BorderSide(color: ColoresApp.primario),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        icon: const Icon(Icons.copy_outlined, size: 14),
                        label: const Text('Copiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Tarjeta del Médico y Sede
            Container(
              padding: const EdgeInsets.all(16),
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
                  // Datos del doctor
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: ColoresApp.fondoIcono,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'GP',
                            style: TextStyle(
                              color: ColoresApp.primario,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Dra. Gabriela Pellegrini',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColoresApp.textoTitulo,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.verified, size: 16, color: ColoresApp.primario),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Cardiología Clínica',
                              style: TextStyle(fontSize: 13, color: ColoresApp.textoSecundario),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'M.N. 142.890 • M.P. 44.512',
                                style: TextStyle(fontSize: 10, color: ColoresApp.textoSecundario, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: ColoresApp.bordeCampo, height: 1),
                  const SizedBox(height: 16),

                  // Sede y Consultorio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: ColoresApp.primario, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sede Central Palermo',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Av. Coronel Díaz 2450, Piso 3',
                              style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: ColoresApp.fondoIcono,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.door_sliding_outlined, size: 14, color: ColoresApp.primario),
                                  SizedBox(width: 6),
                                  Text(
                                    'Consultorio 304 (Ala B)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Tarjeta de Datos del Paciente
            Container(
              padding: const EdgeInsets.all(16),
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
                  // Título de la sección
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Datos del paciente',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo),
                      ),
                      Text(
                        'Titular',
                        style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Fila de Paciente y DNI (en cajitas)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColoresApp.fondoIcono.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Paciente', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
                              SizedBox(height: 2),
                              Text('Matías E. Romero', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColoresApp.fondoIcono.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('DNI', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
                              SizedBox(height: 2),
                              Text('36.782.904', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Cobertura médica
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Cobertura médica', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
                            SizedBox(height: 2),
                            Text('OSDE 310 • Plan Médico Personal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.textoTitulo)),
                            SizedBox(height: 2),
                            Text('Afiliado Nº: 48-992384-01', style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '✓ Activa',
                            style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Tarjeta Azul de Indicaciones para el Paciente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.fondoIcono,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: ColoresApp.primario, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Indicaciones para el paciente',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Llegar 10 minutos antes con DNI y credencial médica física o digital. En caso de no poder asistir, por favor cancelar con al menos 24 hs de anticipación.',
                    style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFBFDBFE), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.apartment_outlined, size: 16, color: ColoresApp.textoSecundario),
                          SizedBox(width: 6),
                          Text(
                            'Presentarse en Recepción Piso 3',
                            style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Text(
                        'Sin copago',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ColoresApp.primario),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón Modificar Turno
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaModificarTurno(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColoresApp.primario,
                  side: const BorderSide(color: ColoresApp.primario, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                label: const Text(
                  'Modificar turno',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón Cancelar Turno (Rojo)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton.icon(
                onPressed: () async {
                  // 👈 Abre el diálogo modal de confirmación
                  final bool? confirmoCancelacion = await mostrarDialogoCancelarTurno(
                    context: context,
                    doctor: 'Dra. Gabriela Pellegrini',
                    especialidad: 'Cardiología',
                    fechaHora: 'Jueves 24 Oct · 10:30 hs',
                    consultorio: 'Consultorio 4',
                  );

                  if (confirmoCancelacion == true && context.mounted) {
                    // Si confirmó cancelar, vuelve atrás
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: const Text(
                  'Cancelar turno',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nota al pie
            const Center(
              child: Text(
                'Modificaciones y cancelaciones permitidas hasta el Jueves 23 de Noviembre a las 10:30 hs.',
                style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
