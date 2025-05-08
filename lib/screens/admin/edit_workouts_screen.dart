import 'package:academia_unifor/models.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';

class EditWorkoutsScreen extends StatefulWidget {
  final Users user;

  const EditWorkoutsScreen({super.key, required this.user});

  @override
  EditWorkoutsScreenState createState() => EditWorkoutsScreenState();
}

class EditWorkoutsScreenState extends State<EditWorkoutsScreen> {
  late List<Workout> workouts;
  late List<int> workoutsToDelete = [];
  Map<int, EquipmentItem> equipmentMap = {};
  Map<String, int> categoryCounts = {};

  Future<void> _loadWorkouts() async {
    workouts = widget.user.workouts;
    final newWorkouts = await UserService().getWorkoutsByUserId(
      widget.user.id,
    );
    
    for (var workout in newWorkouts) {
      for (var exercise in workout.exercises) {
        if (exercise.equipmentId != null && !equipmentMap.containsKey(exercise.equipmentId)) {
          final equipment = await EquipmentService().getEquipmentById(exercise.equipmentId!);
          if (equipment != null) {
            equipmentMap[exercise.equipmentId!] = equipment;
          }
        }
      }
    }

    setState(() {
      workouts = newWorkouts;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _loadAllItems();
  }

  void _loadAllItems() async {
    final categories = await EquipmentService().loadCategories();
    final counts = {for (var c in categories) c.category: c.total};

    setState(() {
      categoryCounts = counts;
    });
  }

  Future<Workout> _addWorkout() async {
    try {
      Workout newWorkout = Workout(
        id: 0,
        userId: widget.user.id,
        name: 'Novo Treino',
        description: 'Descrição do Treino',
        exercises: [],
      );

      // Salva o workout imediatamente se for novo
      if (newWorkout.id == 0) {
        final savedWorkout = await UserService().postWorkout(newWorkout);
        setState(() {
          workouts.add(savedWorkout);
        });
        return savedWorkout;
      } else {
        setState(() {
          workouts.add(newWorkout);
        });
        return newWorkout;
      }
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      throw e;
    }
  }

  void _removeWorkout(int index) {
    if (workouts[index].id != 0) {
      workoutsToDelete.add(workouts[index].id);
    }
    setState(() {
      workouts.removeAt(index);
    });
  }

  Future<void> _saveAllWorkouts() async {
    // Primeiro deleta workouts marcados para remoção
    for (int id in workoutsToDelete) {
      await UserService().deleteWorkout(id);
    }

    // Salva/atualiza todos os workouts
    for (Workout workout in workouts) {
      if (workout.id == 0) {
        await UserService().postWorkout(workout);
      } else {
        await UserService().putWorkout(workout);
      }
    }

    // Atualiza a lista local
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
            onPressed: () async {
              await _saveAllWorkouts();
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
                    Text(
                      'Exercícios: ${workout.exercises.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Se for um workout novo, salva primeiro
                            Workout workoutToEdit = workout;
                            if (workout.id == 0) {
                              workoutToEdit = await UserService().postWorkout(workout);
                              workouts[index] = workoutToEdit;
                            }

                            final updatedWorkout = await Navigator.push<Workout>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditExerciseScreen(
                                  workout: workoutToEdit,
                                  equipmentMap: equipmentMap,
                                  categoryCounts: categoryCounts,
                                ),
                              ),
                            );
                            
                            if (updatedWorkout != null) {
                              setState(() {
                                workouts[index] = updatedWorkout;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Editar Exercícios'),
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