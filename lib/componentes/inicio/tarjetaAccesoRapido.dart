import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta de acceso rápido reutilizable.
class TarjetaAccesoRapido extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final String? badgeTexto;
  final VoidCallback onTap;

  const TarjetaAccesoRapido({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.onTap,
    this.badgeTexto,
  });

  @override
  Widget build(BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icono,
                      color: ColoresApp.primario,
                      size: 20,
                    ),
                  ),
                  if (badgeTexto != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF60B2FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeTexto!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2942),
                        ),
                      ),
                    ),
                ],
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
      ),
    );
  }
}