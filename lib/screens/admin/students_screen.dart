import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 0,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(showNotificationIcon: false),
            body: StudentsScreenBody(),
          ),
        ),
      ),
    );
  }
}

class StudentsScreenBody extends StatelessWidget {
  const StudentsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: const [
          SizedBox(height: 8), // adiciona espaço acima
          Text('Olá mundo', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
