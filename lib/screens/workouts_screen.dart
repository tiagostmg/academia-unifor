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
    return const YoutubeVideoPlayer();
  }
}
