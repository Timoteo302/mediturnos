import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';
import '../../medicos/datos/modelos/medico.dart';

class TarjetaMedicoGestion extends StatelessWidget {
  final Medico medico;
  final VoidCallback alEditar;
  final VoidCallback alAlternarEstado;
  final bool procesando;

  const TarjetaMedicoGestion({
    super.key,
    required this.medico,
    required this.alEditar,
    required this.alAlternarEstado,
    this.procesando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: ColoresApp.fondoIcono,
            child: Text(
              medico.iniciales,
              style: const TextStyle(
                color: ColoresApp.primario,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        medico.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoTitulo,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: medico.activo ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        medico.activo ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: medico.activo ? Colors.green[700] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  medico.especialidad.nombre,
                  style: const TextStyle(color: ColoresApp.primario, fontWeight: FontWeight.w500, fontSize: 13),
                ),
                if (medico.matricula != null && medico.matricula!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Matrícula: ${medico.matricula}',
                    style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: alEditar,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Editar'),
                    ),
                    const SizedBox(width: 8),
                    procesando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: alAlternarEstado,
                            style: TextButton.styleFrom(
                              foregroundColor: medico.activo ? Colors.red : Colors.green,
                            ),
                            child: Text(medico.activo ? 'Desactivar' : 'Activar'),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
