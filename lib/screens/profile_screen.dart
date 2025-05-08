import 'package:academia_unifor/screens/admin/students_screen.dart';
import 'package:academia_unifor/screens/edit_user_screen.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:academia_unifor/widgets/profile_avatar_widget.dart';
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
          ProfileAvatar(avatarUrl: user.avatarUrl),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProfileInfo(users: user),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}


class ProfileInfo extends ConsumerWidget {
  final Users users;
  const ProfileInfo({super.key, required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 20),
        
        // Campos de visualização
        _buildInfoField(context,"Nome:", users.name),
        _buildInfoField(context,"E-mail:", users.email),
        _buildInfoField(context,"Telefone:", users.phone),
        _buildInfoField(context,"Logradouro:", users.address),
        _buildInfoField(context,
          "Data de Nascimento:", 
          users.birthDate != null
              ? "${users.birthDate!.day.toString().padLeft(2, '0')}/${users.birthDate!.month.toString().padLeft(2, '0')}/${users.birthDate!.year}"
              : 'Não informada'
        ),
        const SizedBox(height: 20),
        
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
                const SizedBox(height: 10),

        SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "Editar Perfil",
              icon: Icons.save,
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: users),
                ),
              );
            },
            ),
          ),
        // Sair da conta
        const SizedBox(height: 10),
        SizedBox(
           width: double.infinity,
            child: CustomButton(
              text: "Sair da Conta",
              icon: Icons.logout,
              onPressed: () {
                ref.read(userProvider.notifier).state = null;
                context.go('/');
              },
            )
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoField(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withAlpha(30)
                  : Colors.black.withAlpha(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

