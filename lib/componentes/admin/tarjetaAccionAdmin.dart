import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta para las acciones rápidas del panel de administración.
class TarjetaAccionAdmin extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final String? infoPie;
  final String? textoEnlace;
  final bool esBannerAncho;
  final VoidCallback onTap;

  const TarjetaAccionAdmin({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.onTap,
    this.infoPie,
    this.textoEnlace,
    this.esBannerAncho = false,
  });

  @override
  Widget build(BuildContext context) {
    if (esBannerAncho) {
      return Material(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icono, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoTitulo,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitulo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ColoresApp.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: ColoresApp.primario,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      infoPie ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                    Text(
                      textoEnlace ?? 'Abrir grilla >',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    infoPie ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ColoresApp.primario,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: ColoresApp.primario,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
