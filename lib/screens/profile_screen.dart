import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
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

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final _nameController = TextEditingController(text: "Carlos Felipe Araújo");
  final _emailController = TextEditingController(
    text: "carlosxfelipe@gmail.com",
  );
  final _phoneController = TextEditingController(text: "(85) 99950-2195");
  final _addressController = TextEditingController(text: "Fortaleza, CE");
  final _birthDateController = TextEditingController(text: "03/10/1987");

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditableProfileItem(title: "Nome:", controller: _nameController),
        EditableProfileItem(
          title: "E-mail:",
          controller: _emailController,
          isReadOnly: true,
        ),
        EditableProfileItem(title: "Telefone:", controller: _phoneController),
        EditableProfileItem(
          title: "Logradouro:",
          controller: _addressController,
        ),
        EditableProfileItem(
          title: "Data de Nascimento:",
          controller: _birthDateController,
        ),
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
              context.go('/');
            },
          ),
        ),
      ],
    );
  }
}

class EditableProfileItem extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isReadOnly;

  const EditableProfileItem({
    super.key,
    required this.title,
    required this.controller,
    this.isReadOnly = false,
  });

  @override
  State<EditableProfileItem> createState() => _EditableProfileItemState();
}

class _EditableProfileItemState extends State<EditableProfileItem> {
  late String _initialValue;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _initialValue = widget.controller.text;

    widget.controller.addListener(() {
      final changed = widget.controller.text != _initialValue;
      if (changed != _hasChanged) {
        setState(() {
          _hasChanged = changed;
        });
      }
    });
  }

  void _saveValue() {
    debugPrint("${widget.title} ${widget.controller.text}");
    setState(() {
      _initialValue = widget.controller.text;
      _hasChanged = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Campo salvo!")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                readOnly: widget.isReadOnly,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_hasChanged && !widget.isReadOnly)
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _saveValue,
              ),
          ],
        ),
        Divider(thickness: 1, color: theme.dividerColor),
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
