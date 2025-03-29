import 'package:flutter/material.dart';
import 'dart:convert';
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
    final users = await UsersService().loadUsers();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 2,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(
              onSearchChanged: _filterUsers,
              showChatIcon: false,
            ),
            body: StudentsScreenBody(users: filteredUsers),
          ),
        ),
      ),
    );
  }
}

class StudentsScreenBody extends StatelessWidget {
  final List<Users> users;

  const StudentsScreenBody({super.key, required this.users});

  String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 11) {
      // celular com DDD: 85999502195 → (85) 99950-2195
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      // fixo com DDD: 8534567890 → (85) 3456-7890
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    } else {
      // formato desconhecido, retorna como está
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
            onTap: () {
              final userMap = user.toJson()..remove('password');

              showDialog(
                context: context,
                builder: (_) {
                  bool isEditing = false;
                  TextEditingController nameController = TextEditingController(
                    text: user.name,
                  );
                  TextEditingController emailController = TextEditingController(
                    text: user.email,
                  );
                  TextEditingController phoneController = TextEditingController(
                    text: user.phone,
                  );
                  TextEditingController addressController =
                      TextEditingController(text: user.address);
                  TextEditingController birthDateController =
                      TextEditingController(text: user.birthDate);
                  TextEditingController avatarUrlController =
                      TextEditingController(text: user.avatarUrl);
                  bool isAdmin = user.isAdmin;

                  return StatefulBuilder(
                    builder:
                        (context, setState) => Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isEditing ? Icons.save : Icons.edit,
                                      ),
                                      onPressed: () {
                                        if (isEditing) {
                                          user.name = nameController.text;
                                          user.email = emailController.text;
                                          user.phone = phoneController.text;
                                          user.address = addressController.text;
                                          user.birthDate =
                                              birthDateController.text;
                                          user.avatarUrl =
                                              avatarUrlController.text;
                                          user.isAdmin = isAdmin;
                                        }
                                        setState(() => isEditing = !isEditing);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                if (isEditing) ...[
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome',
                                    ),
                                  ),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'E-mail',
                                    ),
                                  ),
                                  TextField(
                                    controller: phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Telefone',
                                    ),
                                  ),
                                  TextField(
                                    controller: addressController,
                                    decoration: const InputDecoration(
                                      labelText: 'Endereço',
                                    ),
                                  ),
                                  TextField(
                                    controller: birthDateController,
                                    decoration: const InputDecoration(
                                      labelText: 'Data de Nascimento',
                                    ),
                                  ),
                                  TextField(
                                    controller: avatarUrlController,
                                    decoration: const InputDecoration(
                                      labelText: 'URL da Imagem',
                                    ),
                                  ),
                                  CheckboxListTile(
                                    value: isAdmin,
                                    onChanged:
                                        (value) => setState(
                                          () => isAdmin = value ?? false,
                                        ),
                                    title: const Text('Administrador'),
                                  ),
                                ] else
                                  SingleChildScrollView(
                                    child: Text(
                                      JsonEncoder.withIndent(
                                        '  ',
                                      ).convert(userMap),
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
