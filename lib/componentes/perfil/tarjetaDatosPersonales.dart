import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Item individual de información personal de perfil (DNI, Obra Social, Correo, Teléfono).
class ItemDatoPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final String? subvalor;

  const ItemDatoPerfil({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.subvalor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: ColoresApp.primario, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresApp.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoTitulo,
                  ),
                ),
                if (subvalor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subvalor!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ColoresApp.textoSecundario,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}