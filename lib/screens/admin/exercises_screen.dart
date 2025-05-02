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
  late List<int> workoutsToDelete = [];
  late List<int> exercisesToDelete = [];

  Future<void> _loadWorkouts() async {
    workouts = widget.user.workouts;
    final newWorkouts = await UsersService().getWorkoutsByUserId(
      widget.user.id,
    );
    setState(() {
      workouts = newWorkouts;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _addWorkout() {
    try {
      Workout newWorkout = Workout(
        id: 0, // id será atribuído pelo banco
        userId: widget.user.id,
        name: 'Novo Treino',
        description: 'Descrição do Treino',
        exercises: [],
      );

      setState(() {
        workouts.add(newWorkout);
      });
    } catch (e) {
      print('Erro ao adicionar treino: $e');
    }
  }

  // TODO: REMOCAO DE TREINOS
  void _removeWorkout(int index) {
    if (workouts[index].id != 0) {
      workoutsToDelete.add(workouts[index].id);
    }
    setState(() {
      workouts.removeAt(index);
    });
  }

  //TODO ADICIONAR NOVO EXERCICIO
  void _addExercise(Workout workout) {
    setState(() {
      workout.exercises.add(
        Exercise(
          id: 0, // significa que o exercicio ainda nao foi salvo no banco
          workoutId: workout.id,
          name: 'Novo Exercício',
          reps: '3x10',
          notes: '',
        ),
      );
    });
  }

  void _removeExercise(Workout workout, int index) {
    if (workout.exercises[index].id != 0) {
      exercisesToDelete.add(workout.exercises[index].id);
    }
    setState(() {
      workout.exercises.removeAt(index);
    });
  }

  void postOrPutExercise(Workout workout) {
    for (Exercise exercise in workout.exercises) {
      if (exercise.id == 0) {
        UsersService().postExercise(exercise);
      } else {
        UsersService().putExercise(exercise);
      }
    }
  }

  void postOrPutWorkout() {
    for (Workout workout in workouts) {
      //post
      if (workout.id == 0) {
        UsersService().postWorkout(workout);
        postOrPutExercise(workout);
      }
      //put
      else {
        UsersService().putWorkout(workout);
        postOrPutExercise(workout);
      }
    }
  }

  void _saveAllWorkouts() async {
    //delete
    for (int id in workoutsToDelete) {
      UsersService().deleteWorkout(id);
    }
    for (int id in exercisesToDelete) {
      UsersService().deleteExercise(id);
    }
    postOrPutWorkout();
    widget.user.workouts = workouts;
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
              _saveAllWorkouts();
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
              color: Theme.of(context).colorScheme.primary,
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
                    // TODO ADICIONAR LOGICA PARA EXERCICIOS
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workout.exercises.length,
                      itemBuilder: (context, exIndex) {
                        final exercise = workout.exercises[exIndex];

                        return Card(
                          color: Theme.of(context).colorScheme.primary,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Exercício ${exIndex + 1}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      //TODO ADICIONAR FUNCAO DE REMOVER EXERCICIO
                                      onPressed: () {
                                        _removeExercise(workout, exIndex);
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),
                                TextField(
                                  controller: TextEditingController(
                                    text: exercise.name,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Nome do Exercício',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged:
                                      (value) =>
                                          setState(() => exercise.name = value),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: TextEditingController(
                                    text: exercise.reps,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Repetições',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged:
                                      (value) =>
                                          setState(() => exercise.reps = value),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: TextEditingController(
                                    text: exercise.notes ?? '',
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Notas / Observações',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  onChanged:
                                      (value) => setState(
                                        () => exercise.notes = value,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _addExercise(workout),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Adicionar Exercício'),
                        ),
                        ElevatedButton(
                          onPressed: () => _removeWorkout(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Remover Treino'),
                        ),
                      ],
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
