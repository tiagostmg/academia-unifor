import 'package:flutter/material.dart';

class StudentWidget extends StatefulWidget {
  final String nome;
  final String matricula;
  final VoidCallback onPressed; // Função chamada ao pressionar o card

  const StudentWidget({
    super.key,
    required this.nome,
    required this.matricula,
    required this.onPressed, // Parâmetro obrigatório
  });

  @override
  State<StudentWidget> createState() => _StudentWidgetState();
}

class _StudentWidgetState extends State<StudentWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: widget.onPressed, // Agora o Card pode navegar para outra tela
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.nome,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Matrícula: ${widget.matricula}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
