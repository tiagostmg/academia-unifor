import 'package:flutter/material.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models.dart';

class AdminWorkoutsScreen extends StatefulWidget {
  const AdminWorkoutsScreen({super.key});

  @override
  State<AdminWorkoutsScreen> createState() => _AdminWorkoutsScreenState();
}

class _AdminWorkoutsScreenState extends State<AdminWorkoutsScreen> {
  List<Users> allUsers = [];
  List<Users> filteredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final users = await UserService().loadStudents();
      // Ordena os usuários por nome (ordem alfabética)
      users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      setState(() {
        allUsers = users;
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Erro ao carregar usuários: $e');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = allUsers
          .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
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
          currentIndex: 4,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(
              onSearchChanged: _filterUsers,
              showChatIcon: false,
            ),
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ExercisesScreenBody(
      users: filteredUsers,
      onUserEdited: _loadUsers, // Passa a função para recarregar
    );
  }
}

class ExercisesScreenBody extends StatelessWidget {
  final List<Users> users;
  final Function onUserEdited;

  const ExercisesScreenBody({
    super.key,
    required this.users,
    required this.onUserEdited,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RefreshIndicator(
        onRefresh: () async => onUserEdited(),
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
              subtitle: Text('${user.workouts.length} Treinos'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditWorkoutsScreen(user: user),
                  ),
                );

                // Recarrega os dados independentemente de ter atualização
                onUserEdited();
              },
            );
          },
        ),
      ),
    );
  }
}