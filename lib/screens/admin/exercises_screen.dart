import 'package:academia_unifor/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/users_service.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models/workout.dart';

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

class EditWorkoutsScreen extends StatefulWidget {
  final Users user;

  const EditWorkoutsScreen({super.key, required this.user});

  @override
  EditWorkoutsScreenState createState() => EditWorkoutsScreenState();
}

class EditWorkoutsScreenState extends State<EditWorkoutsScreen> {
  late List<Workout> workouts;

  @override
  void initState() {
    super.initState();
    workouts = List<Workout>.from(widget.user.workouts);
  }

  void _addWorkout() {
    setState(() {
      workouts.add(
        Workout(
          name: 'Novo Treino',
          description: 'Descrição do Treino',
          exercises: [],
        ),
      );
    });
  }

  void _removeWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
    });
  }

  void _addExercise(Workout workout) {
    setState(() {
      workout.exercises.add(
        Exercise(name: 'Novo Exercício', reps: '3x10', notes: ''),
      );
    });
  }

  String getFirstName(String fullName) {
    return fullName.split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Treinos - ${getFirstName(widget.user.name)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.user.workouts = workouts;
              Navigator.pop(context, widget.user);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: workout.name),
                      decoration: const InputDecoration(
                        labelText: 'Nome do Treino',
                      ),
                      onChanged: (value) => workout.name = value,
                    ),
                    TextField(
                      controller: TextEditingController(
                        text: workout.description,
                      ),
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      onChanged: (value) => workout.description = value,
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workout.exercises.length,
                      itemBuilder: (context, exIndex) {
                        final exercise = workout.exercises[exIndex];
                        return ListTile(
                          title: Text(exercise.name),
                          subtitle: Text('Repetições: ${exercise.reps}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                workout.exercises.removeAt(exIndex);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () => _addExercise(workout),
                      child: Text(
                        'Adicionar Exercício',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _removeWorkout(index),
                      child: const Text(
                        'Remover Treino',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }
}
