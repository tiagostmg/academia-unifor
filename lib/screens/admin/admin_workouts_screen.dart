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
      // Sort users alphabetically
      users.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      setState(() {
        allUsers = users;
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading users: $e');
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

    return ExercisesScreenBody(users: filteredUsers, onUserEdited: _loadUsers);
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
    return RefreshIndicator(
      onRefresh: () async => onUserEdited(),
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
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
            subtitle: Row(
              children: [
                const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${user.workouts.length} treinos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            contentPadding: const EdgeInsets.only(
              right: 16,
              bottom: 10,
              top: 10,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminUsersWorkoutsScreen(user: user),
                ),
              );
              onUserEdited();
            },
          );
        },
      ),
    );
  }
}
