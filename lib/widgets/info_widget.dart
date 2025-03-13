import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key});

  String getAcademiaStatus() {
    final now = DateTime.now();
    final day = now.weekday;
    final time = now.hour * 60 + now.minute;

    final int openingWeek = 5 * 60 + 30; // 5:30 AM
    final int closingWeek = 22 * 60 + 30; // 10:30 PM
    final int openingSat = 8 * 60; // 8:00 AM
    final int closingSat = 12 * 60; // 12:00 PM

    if (day >= 1 && day <= 5) {
      // Segunda a sexta
      if (time < openingWeek) {
        return 'Fechada - Abre às 5h30';
      } else if (time < closingWeek) {
        final int minutesLeft = closingWeek - time;
        return 'Aberta - Fecha em ${minutesLeft ~/ 60}h${minutesLeft % 60}min';
      } else {
        return 'Fechada - Abre amanhã às 5h30';
      }
    } else if (day == 6) {
      // Sábado
      if (time < openingSat) {
        return 'Fechada - Abre às 8h';
      } else if (time < closingSat) {
        final int minutesLeft = closingSat - time;
        return 'Aberta - Fecha em ${minutesLeft ~/ 60}h${minutesLeft % 60}min';
      } else {
        return 'Fechada - Abre segunda às 5h30';
      }
    } else {
      // Domingo
      return 'Fechada - Abre segunda às 5h30';
    }
  }

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
          const SizedBox(height: 4),
          Text(
            getAcademiaStatus(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
