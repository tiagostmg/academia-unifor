import 'package:flutter/material.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models.dart';


class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Users> allUsers = [];
  List<Users> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await UserService().loadStudents();
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
          currentIndex: 2,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(
              onSearchChanged: _filterUsers,
              showChatIcon: false,
            ),
            body: ExercisesScreenBody(
              users: filteredUsers,
              onUpdateUser: _updateUser,
            ),
          ),
        ),
      ),
    );
  }
}

class ExercisesScreenBody extends StatelessWidget {
  final List<Users> users;
  final Function(Users) onUpdateUser;

  const ExercisesScreenBody({
    super.key,
    required this.users,
    required this.onUpdateUser,
  });

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
            subtitle: Text('${user.workouts.length} Treinos'),
            onTap: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWorkoutsScreen(user: user),
                ),
              );

              if (updatedUser != null && updatedUser is Users) {
                onUpdateUser(updatedUser);
              }
            },
          );
        },
      ),
    );
  }
}