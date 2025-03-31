import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final String nome;
  final String matricula;

  const StudentDetailsPage({super.key, required this.nome, required this.matricula});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Aluno")),
      body: Center(
        child: Column(
          children: [
            Text("Nome: $nome", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Matrícula: $matricula", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            // WorkoutPlanWidget(),
            const SizedBox(height: 10),
            CustomButton(
              text: "Editar",
              icon: Icons.edit,
              onPressed: () {
                // Exemplo de ação ao pressionar o botão
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
