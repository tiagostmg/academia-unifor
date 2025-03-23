import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 0, // Altere para 1 ou 2 conforme a aba
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(showNotificationIcon: false),
            body: const Center(child: Text('Bem-vindo, Admin!')),
          ),
        ),
      ),
    );
  }
}
