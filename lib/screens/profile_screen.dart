import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const ProfileAvatar(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const ProfileInfo(),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.white70
                      : const Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(
            "https://avatars.githubusercontent.com/u/85801709?s=400&u=01cce0318ea853ce1a133699bc6b2af1919094d6&v=4",
          ),
        ),
      ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileItem(title: "Nome:", value: "Carlos Felipe Araújo"),
        ProfileItem(title: "E-mail:", value: "carlosxfelipe@gmail.com"),
        ProfileItem(title: "Telefone:", value: "(85) 99950-2195"),
        ProfileItem(title: "Localização:", value: "Fortaleza, CE"),
        ProfileItem(title: "Data de Nascimento:", value: "03/10/1987"),
        ListTile(
          leading: Icon(
            Icons.settings,
            color: Theme.of(context).iconTheme.color,
          ),
          title: const Text("Configurações"),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
          title: const Text("Compartilhar App"),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: () async {
            final Uri url = Uri.parse(
              "https://github.com/carlosxfelipe/academia-unifor",
            );
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Não foi possível abrir o link.")),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: "Sair da Conta",
            icon: Icons.logout,
            onPressed: () {
              // Adicione aqui a lógica para sair da conta
            },
          ),
        ),
      ],
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String title;
  final String value;
  const ProfileItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Divider(thickness: 1, color: Theme.of(context).dividerColor),
      ],
    );
  }
}
