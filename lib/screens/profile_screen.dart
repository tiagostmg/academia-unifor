import 'package:academia_unifor/screens/edit_user_screen.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Linha com foto à esquerda e nome/email à direita
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto
                ProfileAvatar(avatarUrl: user.avatarUrl),
                const SizedBox(width: 20),
                // Nome e Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProfileInfo(user: user),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class ProfileInfo extends ConsumerWidget {
  final Users user;
  const ProfileInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleInfoField(context, "Data de Nascimento", 
          user.birthDate != null
            ? "${user.birthDate!.day.toString().padLeft(2, '0')}/${user.birthDate!.month.toString().padLeft(2, '0')}/${user.birthDate!.year}"
            : 'Não informada'
        ),
        
        const SizedBox(height: 16),
        
        // Logradouro
        _buildSimpleInfoField(context, "Logradouro", user.address),
        
        const SizedBox(height: 16),
        
        // Telefone
        _buildSimpleInfoField(context, "Telefone", user.phone),
                        
        const SizedBox(height: 16),
        
        // Configurações
        ListTile(
          leading: Icon(
            Icons.settings,
            color: Theme.of(context).iconTheme.color,
          ),
          title: const Text("Configurações"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {},
        ),
        
        ListTile(
          leading: Icon(
            Icons.share,
            color: Theme.of(context).iconTheme.color,
          ),
          title: const Text("Compartilhar App"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () async {
            final Uri url = Uri.parse("https://github.com/carlosxfelipe/academia-unifor");
            try {
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Não foi possível abrir o link.")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erro: ${e.toString()}")),
              );
            }
          },
        ),
        
        const SizedBox(height: 20),
        
        // Botão Editar Perfil
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: "Editar Perfil",
            icon: Icons.edit,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: user),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botão Sair da Conta
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: "Sair da Conta",
            icon: Icons.logout,
            onPressed: () {
              ref.read(userProvider.notifier).state = null;
              context.go('/');
            },
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSimpleInfoField(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}