import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';
import 'package:mediturnos/turnos/presentacion/pantallas/pantallaDetalleTurno.dart';

// TODO(MVVM): reemplazar por datos reales del servidor.
class TurnoEjemploAdmin {
  final String horaConsultorio;
  final String estadoTexto;
  final Color estadoColor;
  final Color estadoFondo;
  final IconData estadoIcono;
  final String nombrePaciente;
  final String dniObraSocial;
  final String nombreMedico;
  final String especialidadMedico;
  final String inicialesMedico;
  final String tipoAtencion;
  final String? etiquetaExtra;
  final String textoBotonSecundario;
  final String? textoBotonPrimario;
  final IconData? iconoBotonPrimario;
  final bool esLlamada;
  final bool soloUnBoton;

  const TurnoEjemploAdmin({
    required this.horaConsultorio,
    required this.estadoTexto,
    required this.estadoColor,
    required this.estadoFondo,
    required this.estadoIcono,
    required this.nombrePaciente,
    required this.dniObraSocial,
    required this.nombreMedico,
    required this.especialidadMedico,
    required this.inicialesMedico,
    required this.tipoAtencion,
    this.etiquetaExtra,
    required this.textoBotonSecundario,
    this.textoBotonPrimario,
    this.iconoBotonPrimario,
    this.esLlamada = false,
    this.soloUnBoton = false,
  });
}

/// Tarjeta de turno reutilizable para la grilla de administración.
class TarjetaTurnoAdmin extends StatelessWidget {
  final TurnoEjemploAdmin turno;

  const TarjetaTurnoAdmin({
    super.key,
    required this.turno,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Fila superior: Hora y consultorio + Badge de estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: ColoresApp.primario),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        turno.horaConsultorio,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (turno.etiquetaExtra != null) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            turno.etiquetaExtra!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: turno.estadoFondo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(turno.estadoIcono,
                              size: 12, color: turno.estadoColor),
                          const SizedBox(width: 3),
                          Text(
                            turno.estadoTexto,
                            style: TextStyle(
                              color: turno.estadoColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: ColoresApp.bordeCampo, height: 1),
          const SizedBox(height: 12),

          // Información del paciente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 18, color: ColoresApp.textoSecundario),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            turno.nombrePaciente,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            turno.dniObraSocial,
                            style: const TextStyle(
                              fontSize: 11,
                              color: ColoresApp.textoSecundario,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.receipt_long_outlined,
                  size: 18, color: ColoresApp.textoSecundario),
            ],
          ),

          const SizedBox(height: 12),

          // Subtarjeta interna con los datos del médico y tipo de atención
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColoresApp.fondoIcono.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeCampo.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      turno.inicialesMedico,
                      style: const TextStyle(
                        color: ColoresApp.primario,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turno.nombreMedico,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        turno.especialidadMedico,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColoresApp.textoSecundario,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    turno.tipoAtencion,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ColoresApp.textoSecundario,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Botones inferiores de la tarjeta
          if (turno.soloUnBoton) ...[
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PantallaDetalleTurno(soloLectura: true),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColoresApp.textoTitulo,
                  side: const BorderSide(color: ColoresApp.bordeCampo),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  turno.textoBotonSecundario,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (!turno.esLlamada) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PantallaDetalleTurno(soloLectura: true),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: turno.esLlamada
                          ? ColoresApp.primario
                          : ColoresApp.textoTitulo,
                      side: BorderSide(
                        color: turno.esLlamada
                            ? ColoresApp.primario
                            : ColoresApp.bordeCampo,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: Icon(
                      turno.esLlamada
                          ? Icons.phone_outlined
                          : Icons.visibility_outlined,
                      size: 16,
                    ),
                    label: Text(
                      turno.textoBotonSecundario,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primarioBoton,
                      foregroundColor: ColoresApp.textoBoton,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: Icon(turno.iconoBotonPrimario ?? Icons.check,
                        size: 16),
                    label: Text(
                      turno.textoBotonPrimario ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
