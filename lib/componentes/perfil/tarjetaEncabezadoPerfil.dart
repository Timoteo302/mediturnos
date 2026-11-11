import 'package:flutter/material.dart';
import 'package:mediturnos/configuracion/coloresApp.dart';

/// Tarjeta de cabecera con avatar, nombre, prepaga y botón de editar perfil.
class TarjetaEncabezadoPerfil extends StatelessWidget {
  final String iniciales;
  final String nombre;
  final String estadoPaciente;
  final String obraSocial;
  final VoidCallback onEditar;

  const TarjetaEncabezadoPerfil({
    super.key,
    this.iniciales = 'SM',
    this.nombre = 'Sofía Martínez',
    this.estadoPaciente = 'Paciente Activa',
    this.obraSocial = 'OSDE 210 - Titular',
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    iniciales,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primario,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: ColoresApp.primario,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoTitulo,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onEditar,
              icon: const Icon(Icons.edit_outlined, size: 18, color: ColoresApp.primario),
              label: const Text(
                'Editar perfil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primario,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}