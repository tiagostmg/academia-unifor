import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 2,
          child: Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Alunos",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StudentWidget(
                      nome: "João Silva",
                      matricula: "123456",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentDetailsPage(
                                  nome: "João Silva",
                                  matricula: "123456",
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    StudentWidget(
                      nome: "Tiago",
                      matricula: "123456",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentDetailsPage(
                                  nome: "Tiago",
                                  matricula: "123456",
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    StudentWidget(
                      nome: "Igor",
                      matricula: "123456",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentDetailsPage(
                                  nome: "Igor",
                                  matricula: "123456",
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentDetailsPage extends StatelessWidget {
  final String nome;
  final String matricula;

  const StudentDetailsPage({
    super.key,
    required this.nome,
    required this.matricula,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Aluno")),
      body: Center(
        child: Column(
          children: [
            Text(
              "Nome: $nome",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Matrícula: $matricula", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            WorkoutPlanWidget(),
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

class StudentWidget extends StatelessWidget {
  final String nome;
  final String matricula;
  final VoidCallback onPressed;

  const StudentWidget({
    super.key,
    required this.nome,
    required this.matricula,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Matrícula: $matricula",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
