import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:academia_unifor/services/users_service.dart';
import 'package:academia_unifor/models/users.dart';

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
    return FutureBuilder<List<Users>>(
      future: UsersService().loadUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Erro ao carregar o perfil"));
        }

        final usersList = snapshot.data!;
        final user = usersList.firstWhere(
          (u) => u.id == 1,
          orElse: () => usersList.first,
        );

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
      },
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  const ProfileAvatar({super.key, required this.avatarUrl});

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
        child: CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(avatarUrl),
        ),
      ),
    );
  }
}

class ProfileInfo extends StatefulWidget {
  final Users users;
  const ProfileInfo({super.key, required this.users});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    final u = widget.users;
    _nameController = TextEditingController(text: u.name);
    _emailController = TextEditingController(text: u.email);
    _phoneController = TextEditingController(text: u.phone);
    _addressController = TextEditingController(text: u.address);
    _birthDateController = TextEditingController(text: u.birthDate);
  }

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
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
          title: const Text("Compartilhar App"),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
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
          const SizedBox(height: 3),
          TextFormField(
            controller: widget.controller,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor:
                  isDarkMode
                      ? Colors.white.withAlpha(30)
                      : Colors.black.withAlpha(10),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon:
                  widget.isReadOnly
                      ? null
                      : _hasChanged
                      ? IconButton(
                        icon: Icon(
                          Icons.save,
                          color: isDarkMode ? Colors.white : Colors.grey[800],
                        ),
                        onPressed: _saveValue,
                      )
                      : Icon(
                        Icons.edit,
                        color: isDarkMode ? Colors.white : Colors.grey[800],
                      ),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
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
