import 'package:academia_unifor/screens/edit_user_screen.dart';
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
      final users =
          await _userService.loadUsers()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
      setState(() {
        allUsers = users;
        filteredUsers = List.from(users); // Cria uma nova lista
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar alunos: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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

  Future<void> _updateUser(Users updatedUser) async {
    try {
      setState(() => _isLoading = true);
      final result = await _userService.putUser(updatedUser);
      setState(() {
        final index = allUsers.indexWhere((u) => u.id == result.id);
        if (index != -1) {
          allUsers[index] = result;
          filteredUsers = List.from(allUsers); // Nova instância da lista
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar usuário: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await confirmationDialog(
      context,
      title: 'Confirmar Exclusão',
      message: 'Tem certeza que deseja excluir este aluno?',
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _userService.deleteUser(userId);
        setState(() {
          allUsers.removeWhere((user) => user.id == userId);
          filteredUsers = List.from(allUsers); // Nova instância
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno excluído com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir aluno: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addNewUser() async {
    final newUser = await Navigator.push<Users>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditUserScreen(
              user: Users(
                id: 0,
                name: '',
                email: '',
                phone: '',
                address: '',
                birthDate: null,
                avatarUrl: '',
                isAdmin: false,
                password: '',
                workouts: [],
              ),
            ),
      ),
    );

    if (newUser != null) {
      setState(() => _isLoading = true);
      setState(() {
        allUsers.add(newUser);
        allUsers.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        filteredUsers = List.from(allUsers); // Nova instância
      });
      setState(() => _isLoading = false);
    }
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
            body:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : StudentsScreenBody(
                      users: filteredUsers,
                      onUpdateUser: _updateUser,
                      onDeleteUser: _deleteUser,
                    ),
            floatingActionButton: FloatingActionButton(
              onPressed: _addNewUser,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.add),
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
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.separated(
        itemCount: users.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return const SizedBox(height: 80);
          }
          final user = users[index];
          return ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      user.avatarUrl.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(user.avatarUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    user.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 28)
                        : null,
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
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
              onPressed: () async => await onDeleteUser(user.id),
            ),
            contentPadding: const EdgeInsets.only(
              right: 16,
              bottom: 10,
              top: 10,
            ),
            onTap: () async {
              final updatedUser = await Navigator.push<Users>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: user),
                ),
              );

              if (updatedUser != null) {
                await onUpdateUser(updatedUser);
              }
            },
          );
        },
      ),
    );
  }
}
