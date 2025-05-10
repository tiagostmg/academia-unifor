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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 2,
          child: Stack(
            children: [
              // Blue background that covers top half
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 286,
                // MediaQuery.of(context).size.height * 0.3 + 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: theme.colorScheme.primary),
                ),
              ),
              // The actual profile content
              const ProfileBody(),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Notification bar with blue background
          Container(
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [NotificationButton()],
              ),
            ),
          ),

          const SizedBox(height: 28),
          Center(
            child: Stack(children: [ProfileAvatar(avatarUrl: user.avatarUrl)]),
          ),
          const SizedBox(height: 20),

          Text(
            user.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     SizedBox(width: 56),
          //     Text(
          //       user.name,
          //       style: theme.textTheme.headlineMedium?.copyWith(
          //         fontWeight: FontWeight.bold,
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         IconButton(
          //           onPressed:
          //               () => Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => EditUserScreen(user: user),
          //                 ),
          //               ),
          //           icon: Icon(Icons.edit, color: theme.colorScheme.onPrimary),
          //         ),
          //         SizedBox(width: 8),
          //       ],
          //     ),
          //   ],
          // ),
          const SizedBox(height: 20),

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
            user.birthDate != null
                ? "${user.birthDate!.day.toString().padLeft(2, '0')}/${user.birthDate!.month.toString().padLeft(2, '0')}/${user.birthDate!.year}"
                : 'Não informada',
          ),
          const SizedBox(height: 16),
          _buildInfoItem(context, "Endereço", user.address),
          const SizedBox(height: 16),
          _buildInfoItem(context, "Telefone", user.phone),
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
