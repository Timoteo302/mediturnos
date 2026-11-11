import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../servicios/servicioMonitoreoSincronizacion.dart';

import '../../../autenticacion/presentacion/viewmodels/autenticacionViewModel.dart';

// Importamos los paquetes principales de Flutter
import 'package:flutter/material.dart';

// Importamos nuestros componentes reutilizables y configuraciones
import '../../../configuracion/coloresApp.dart';
import '../../../configuracion/estilosTexto.dart';

import '../../datos/modelos/turno.dart';
import '../../datos/repositorios/repositorioTurnosImpl.dart';
import '../../logica/casosDeUsoTurnos.dart';

/// Pantalla de confirmación y revisión final del turno (Paso 4).
class PantallaConfirmarSolicitud extends StatelessWidget {
  final DateTime fecha;
  final String hora;
  final int medicoId;

  const PantallaConfirmarSolicitud({
    super.key,
    required this.fecha,
    required this.hora,
    required this.medicoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con botón de retroceso, título y perfil
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Confirmar solicitud'),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),

      // Cuerpo desplazable para que el contenido no se desborde
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Título descriptivo y temporizador de reserva temporal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título descriptivo
                const Expanded(
                  child: Text(
                    'Paso final: Revisión',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoTitulo,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 6),

                // Badge de reserva temporal con cuenta regresiva
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoIcono,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '• Reserva (09:42)',
                    style: TextStyle(
                      color: ColoresApp.primario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tarjeta principal que contiene todos los detalles del turno y paciente
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
                  // Sección del Médico y Especialidad
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar o contenedor con ícono médico
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ColoresApp.fondoIcono,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: ColoresApp.primario,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge de especialidad
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ColoresApp.fondoIcono,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '• Cardiología',
                                style: TextStyle(
                                  color: ColoresApp.primario,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Nombre del doctor
                            const Text(
                              'Dr. Juan Manuel Gómez',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.textoTitulo,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Matrícula
                            const Text(
                              'Matrícula Nacional: MN 114.820',
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

                  const SizedBox(height: 16),
                  const Divider(color: ColoresApp.bordeCampo, height: 1),
                  const SizedBox(height: 16),

                  // Sección de Fecha y Hora (Tarjeta interna)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoIcono.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ColoresApp.bordeCampo.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icono de calendario
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: ColoresApp.primario,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Fecha y hora detalladas
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Jueves 24 de Octubre de 2024',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ColoresApp.textoSecundario,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '10:30 hs',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.textoTitulo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge de tipo de atención (Presencial)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ColoresApp.bordeCampo),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.location_city_outlined,
                                size: 14,
                                color: ColoresApp.textoSecundario,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Presencial',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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

                  // Sección de Ubicación / Sede
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: ColoresApp.primario,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Sede Central - Consultorio 4',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.textoTitulo,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Av. Corrientes 3450, Ciudad Autónoma de Buenos Aires',
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

                  const SizedBox(height: 20),
                  const Divider(color: ColoresApp.bordeCampo, height: 1),
                  const SizedBox(height: 16),

                  // Título de la sección Datos del Paciente
                  const Text(
                    'DATOS DEL PACIENTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoSecundario,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Fila Paciente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Paciente:',
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Sofía Martínez',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Fila DNI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'DNI:',
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '36.120.455',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Fila Cobertura médica
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cobertura médica:',
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'OSDE 210',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Credencial Nº 4410293',
                            style: TextStyle(
                              color: ColoresApp.textoSecundario,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cuadro de Aviso Importante (Fondo amarillo claro / ámbar)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFEF3C7,
                ), // Ámbar muy suave / amarillo institucional
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFD97706), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aviso importante sobre tu solicitud',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Al presionar confirmar, tu solicitud ingresará en revisión de agenda. El turno quedará pendiente hasta que el sistema y el centro médico verifiquen la disponibilidad definitiva.',
                          style: TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón Principal: Confirmar solicitud
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                // Acción para confirmar el turno y enviarlo al backend/API
                onPressed: () async {
                  final usuario = context
                      .read<AutenticacionViewModel>()
                      .usuarioActual;

                  final pacienteId = usuario?.paciente?.id;

                  if (pacienteId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se encontró el paciente autenticado.',
                        ),
                      ),
                    );
                    return;
                  }

                  final turno = Turno(
                    id: DateTime.now().microsecondsSinceEpoch,
                    paciente: 'Sofía Martínez',
                    medico: 'Dr. Juan Manuel Gómez',
                    especialidad: 'Cardiología',
                    fecha: fecha.toIso8601String().split('T').first,
                    hora: hora,
                    estado: 'PENDIENTE',
                    sincronizado: false,
                    pacienteId: pacienteId,
                    medicoId: medicoId,
                    claveSolicitud: const Uuid().v4(),
                  );

                  try {
                    final casosDeUso = CasosDeUsoTurnos(
                      RepositorioTurnosImpl(),
                    );

                    await casosDeUso.registrarTurno(turno);
                    context.read<ServicioMonitoreoSincronizacion>().sincronizarAhora();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Solicitud guardada localmente. Pendiente de sincronización.',
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar la solicitud: $e'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioBoton,
                  foregroundColor: ColoresApp.textoBoton,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'Confirmar solicitud',
                  style: EstilosTexto.textoBotonPrincipal,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón Secundario: Volver a editar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColoresApp.primario,
                  side: const BorderSide(
                    color: ColoresApp.primario,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                label: const Text(
                  'Volver a editar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primario,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nota de seguridad inferior
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: ColoresApp.textoSecundario,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tus datos médicos se procesan de forma confidencial y segura.',
                    style: TextStyle(
                      fontSize: 11,
                      color: ColoresApp.textoSecundario,
                    ),
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
