import 'package:academia_unifor/screens/edit_user_screen.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 3,
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
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text("Nenhum usuário logado."));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [NotificationButton()],
                  // ),
                  const SizedBox(height: 24),
                  Center(
                    child: Stack(
                      children: [ProfileAvatar(avatarUrl: user.avatarUrl)],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    user.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            user.email,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          _buildInfoItem(
            context,
            "Data de Nascimento",
            user.birthDate != null && user.birthDate!.isNotEmpty
                ? user.birthDate!
                : 'Não informada',
          ),
          const SizedBox(height: 16),
          _buildInfoItem(context, "Endereço", user.address),
          const SizedBox(height: 16),
          _buildInfoItem(context, "Telefone", formatPhoneNumber(user.phone)),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text("Configurações"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(
                    Icons.share,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text("Compartilhar App"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () async {
                    final Uri url = Uri.parse(
                      "https://github.com/carlosxfelipe/academia-unifor",
                    );
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Não foi possível abrir o link."),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
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
                SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withAlpha(180),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.isNotEmpty ? value : 'Não informado',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

String formatPhoneNumber(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'\D'), '');
  if (cleaned.length == 11) {
    return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
  } else if (cleaned.length == 10) {
    return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
  }
  return phone;
}
