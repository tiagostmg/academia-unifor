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
            body: HomeBodyAdmin(),
          ),
        ),
      ),
    );
  }
}
  class HomeBodyAdmin extends StatelessWidget {
    const HomeBodyAdmin({super.key});

    @override
    Widget build(BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          children: [
            CustomButton(
              text: "Mensagens",
              icon: Icons.message,
              onPressed: () {
                context.go('/');
              },
            ),
          ],
        ),
      );
    }
  }
