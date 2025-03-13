import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horários',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.access_time, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text('Seg-Sex: 5h30 - 22h30'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.access_time, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Text('Sábado: 8h - 12h'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Contato',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.phone, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Text('(85) 3477-3616'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(FontAwesomeIcons.whatsapp, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text('(85) 99162-5291'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.email, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('dad@unifor.br'),
            ],
          ),
        ],
      ),
    );
  }
}
