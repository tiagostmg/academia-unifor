import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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
            body: AdminScreenBody(),
          ),
        ),
      ),
    );
  }
}

class AdminScreenBody extends StatelessWidget {
  const AdminScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "Sair para tela de login",
              icon: Icons.logout,
              onPressed: () {
                context.go('/');
              },
            ),
          ),
        ],
      ),
    );
  }
}
