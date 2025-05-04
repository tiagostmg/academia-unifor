import 'package:flutter/material.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/services.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Users> allUsers = [];
  List<Users> filteredUsers = [];
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.loadStudents()..sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        allUsers = users;
        filteredUsers = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar alunos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = allUsers
          .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _updateUser(Users updatedUser) async {
    try {
      setState(() => _isLoading = true);
      final result = await _userService.putUser(updatedUser);
      setState(() {
        final index = allUsers.indexWhere((u) => u.id == result.id);
        if (index != -1) {
          allUsers[index] = result;
          filteredUsers = List.from(allUsers);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar usuário: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este aluno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _userService.deleteUser(userId);
        setState(() {
          allUsers.removeWhere((user) => user.id == userId);
          filteredUsers.removeWhere((user) => user.id == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno excluído com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir aluno: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 4,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(
              onSearchChanged: _filterUsers,
              showChatIcon: false,
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StudentsScreenBody(
                    users: filteredUsers,
                    onUpdateUser: _updateUser,
                    onDeleteUser: _deleteUser,
                  ),
          ),
        ),
      ),
    );
  }
}

class StudentsScreenBody extends StatelessWidget {
  final List<Users> users;
  final Future<void> Function(Users) onUpdateUser;
  final Future<void> Function(int) onDeleteUser;

  const StudentsScreenBody({
    super.key,
    required this.users,
    required this.onUpdateUser,
    required this.onDeleteUser,
  });

  String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    }
    return phone;
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
              backgroundImage: user.avatarUrl.isNotEmpty
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
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await onDeleteUser(user.id);
              },
            ),
            onTap: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: user),
                ),
              );
              if (updatedUser != null && updatedUser is Users) {
                await onUpdateUser(updatedUser);
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

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthDateController;
  late TextEditingController _avatarUrlController;
  late bool _isAdmin;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);
    _birthDateController = TextEditingController(text: widget.user.birthDate);
    _avatarUrlController = TextEditingController(text: widget.user.avatarUrl);
    _isAdmin = widget.user.isAdmin;
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este usuário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        // Retorna null para indicar que o usuário foi deletado
        Navigator.pop(context, null);
      } finally {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e e-mail são obrigatórios')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updatedUser = Users(
      id: widget.user.id,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      birthDate: _birthDateController.text,
      avatarUrl: _avatarUrlController.text,
      isAdmin: _isAdmin,
      password: widget.user.password,
      workouts: widget.user.workouts,
    );

    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuário'),
        actions: [
          IconButton(
            icon: _isDeleting
                ? const CircularProgressIndicator()
                : const Icon(Icons.delete, color: Colors.red),
            onPressed: _isDeleting ? null : _deleteUser,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            TextField(
              controller: _birthDateController,
              decoration: const InputDecoration(labelText: 'Data de Nascimento'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(labelText: 'URL da Imagem'),
              keyboardType: TextInputType.url,
            ),
            CheckboxListTile(
              value: _isAdmin,
              onChanged: (value) => setState(() => _isAdmin = value ?? false),
              title: const Text('Administrador'),
            ),
          ],
        ),
      ),
    );
  }
}