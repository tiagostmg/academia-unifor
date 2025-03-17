import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';

Map<String, int> suggestions = {
  "Máquinas para treinamento de força": 40,
  "Aparelhos ergométricos (cárdio)": 24,
  "Esteiras": 12,
  "Bikes para atividades de spinning": 11,
};

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 1, // Índice correspondente ao botão "Treinos"
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(),
            body: const WorkoutsBody(),
          ),
        ),
      ),
    );
  }
}

class WorkoutsBody extends StatelessWidget {
  const WorkoutsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Pesquise por um treino...",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children:
                suggestions.keys
                    .map(
                      (equipamento) => Chip(
                        label: Text(equipamento),
                        backgroundColor: chipColor,
                        labelStyle: TextStyle(color: textColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
