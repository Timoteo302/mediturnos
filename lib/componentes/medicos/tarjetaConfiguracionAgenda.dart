import 'package:flutter/material.dart';
import '../../configuracion/coloresApp.dart';

class TarjetaConfiguracionAgenda extends StatelessWidget {
  final VoidCallback? alDefinirAgenda;

  const TarjetaConfiguracionAgenda({
    super.key,
    this.alDefinirAgenda,
  });

  @override
  Widget build(BuildContext context) {
    final habilitado = alDefinirAgenda != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeCampo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_month_outlined, color: ColoresApp.primario, size: 20),
              SizedBox(width: 8),
              Text(
                'Agenda de atención',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoTitulo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Horarios y días semanales',
                style: TextStyle(fontSize: 14, color: ColoresApp.textoSecundario),
              ),
              GestureDetector(
                onTap: habilitado ? alDefinirAgenda : null,
                child: Text(
                  'Definir agenda',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: habilitado ? ColoresApp.primario : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          if (!habilitado) ...[
            const SizedBox(height: 6),
            const Text(
              'Guardá el médico para poder definir su agenda.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ],
      ),
    );
  }
}
