import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 0, // Índice correspondente ao botão "Início"
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(),
            body: const HomeBody(),
          ),
        ),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const CarouselWidget(),
          const SizedBox(height: 15),
          const ScheduleWidget(),
          const SizedBox(height: 10),
          // const WorkoutPlanWidget(),
          // const SizedBox(height: 10),
          const ContactWidget(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
