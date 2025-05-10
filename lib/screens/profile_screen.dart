import 'package:academia_unifor/screens/edit_user_screen.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 2,
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

class ProfileBody extends ConsumerWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Center(child: Text("Nenhum usuário logado."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Foto centralizada
          Center(child: ProfileAvatar(avatarUrl: user.avatarUrl)),
          const SizedBox(height: 20),

          // Nome
          Text(
            user.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Informações básicas
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                context,
                "Data de Nascimento",
                user.birthDate != null
                    ? "${user.birthDate!.day.toString().padLeft(2, '0')}/${user.birthDate!.month.toString().padLeft(2, '0')}/${user.birthDate!.year}"
                    : 'Não informada',
              ),
              const SizedBox(height: 16),
              _buildInfoItem(context, "Endereço", user.address),
              const SizedBox(height: 16),
              _buildInfoItem(context, "Telefone", user.phone),
            ],
          ),
          const SizedBox(height: 30),

          // Botões de ação
          Column(
            children: [
              CustomButton(
                text: "Editar Perfil",
                icon: Icons.edit,
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(user: user),
                      ),
                    ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Sair da Conta",
                icon: Icons.logout,
                color1: const Color(0xFFB00020),
                color2: const Color(0xFFEF5350),
                onPressed: () {
                  ref.read(userProvider.notifier).state = null;
                  context.go('/');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(80),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'Não informado',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
