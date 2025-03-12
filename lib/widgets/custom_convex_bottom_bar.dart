import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class CustomConvexBottomBar extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const CustomConvexBottomBar({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: ConvexAppBar(
        height: 60,
        style: TabStyle.react,
        backgroundColor: Colors.lime,
        activeColor: Colors.black,
        color: Colors.black45,
        elevation: 0,
        initialActiveIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;

          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/workouts');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        items: const [
          TabItem(icon: Icons.home, title: 'Início'),
          TabItem(icon: Icons.fitness_center, title: 'Treinos'),
          TabItem(icon: Icons.person, title: 'Perfil'),
        ],
      ),
    );
  }
}
