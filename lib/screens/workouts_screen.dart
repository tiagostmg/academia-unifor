import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 1,
          child: const WorkoutsBody(),
        ),
      ),
    );
  }
}

class WorkoutsBody extends StatelessWidget {
  const WorkoutsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SearchAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Aqui eu preciso colocar a ficha e tudo que for relativo ao treino',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
