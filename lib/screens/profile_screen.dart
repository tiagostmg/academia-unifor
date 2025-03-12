import 'package:academia_unifor/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.primary,
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 2, // Índice correspondente ao botão "Perfil"
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(),
            body: const ProfileBody(),
          ),
        ),
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16, top: 16),
      child: Align(alignment: Alignment.topLeft, child: Text('Perfil')),
    );
  }
}
