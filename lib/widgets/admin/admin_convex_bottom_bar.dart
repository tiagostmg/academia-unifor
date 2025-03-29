import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class AdminConvexBottomBar extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const AdminConvexBottomBar({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: ConvexAppBar(
        height: 60,
        style: TabStyle.react,
        backgroundColor: theme.colorScheme.primary,
        activeColor: theme.colorScheme.onPrimary,
        color: theme.colorScheme.onPrimary.withAlpha(100),
        elevation: 0,
        initialActiveIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;

          switch (index) {
            case 0:
              context.go('/admin');
              break;
            case 1:
              context.go('/admin/equipments');
              break;
            case 2:
              context.go('/admin/exercises');
              break;
            case 3:
              context.go('/admin/students');
              break;
          }
        },
        items: const [
          TabItem(icon: Icons.admin_panel_settings, title: 'Admin'),
          TabItem(icon: Icons.fitness_center, title: 'Aparelhos'),
          TabItem(icon: Icons.description, title: 'Exercícios'),
          TabItem(icon: Icons.school, title: 'Alunos'),
        ],
      ),
    );
  }
}
