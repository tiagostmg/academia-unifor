import 'package:flutter/material.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/users_service.dart';
import 'package:academia_unifor/widgets.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Users> allUsers = [];
  List<Users> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await UsersService().loadStudents();
    setState(() {
      allUsers = users;
      filteredUsers = users;
    });
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers =
          allUsers
              .where(
                (user) => user.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _updateUser(Users updatedUser) {
    setState(() {
      final index = allUsers.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        allUsers[index] = updatedUser;
        filteredUsers[index] = updatedUser;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 3,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(
              onSearchChanged: _filterUsers,
              showChatIcon: false,
            ),
            body: StudentsScreenBody(
              users: filteredUsers,
              onUpdateUser: _updateUser,
            ),
          ),
        ),
      ),
    );
  }
}

class StudentsScreenBody extends StatelessWidget {
  final List<Users> users;
  final Function(Users) onUpdateUser;

  const StudentsScreenBody({
    super.key,
    required this.users,
    required this.onUpdateUser,
  });

  String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    } else {
      return phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
              child: user.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                if (user.phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        formatPhoneNumber(user.phone),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
            onTap: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: user),
                ),
              );

              if (updatedUser != null && updatedUser is Users) {
                onUpdateUser(
                  updatedUser,
                ); // Usa o callback para atualizar o usuário
              }
            },
          );
        },
      ),
    );
  }
}

class EditUserScreen extends StatefulWidget {
  final Users user;

  const EditUserScreen({
    super.key,
    required this.user,
  }); // Uso do super parâmetro

  @override
  EditUserScreenState createState() => EditUserScreenState(); // Nome público da classe
}

class EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController birthDateController;
  late TextEditingController avatarUrlController;
  late bool isAdmin;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    addressController = TextEditingController(text: widget.user.address);
    birthDateController = TextEditingController(text: widget.user.birthDate);
    avatarUrlController = TextEditingController(text: widget.user.avatarUrl);
    isAdmin = widget.user.isAdmin;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              setState(() {
                widget.user.name = nameController.text;
                widget.user.email = emailController.text;
                widget.user.phone = phoneController.text;
                widget.user.address = addressController.text;
                widget.user.birthDate = birthDateController.text;
                widget.user.avatarUrl = avatarUrlController.text;
                widget.user.isAdmin = isAdmin;
              });
              Navigator.pop(
                context,
                widget.user,
              ); // Retorna o usuário atualizado
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            TextField(
              controller: birthDateController,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
              ),
            ),
            TextField(
              controller: avatarUrlController,
              decoration: const InputDecoration(labelText: 'URL da Imagem'),
            ),
            CheckboxListTile(
              value: isAdmin,
              onChanged: (value) => setState(() => isAdmin = value ?? false),
              title: const Text('Administrador'),
            ),
          ],
        ),
      ),
    );
  }
}
