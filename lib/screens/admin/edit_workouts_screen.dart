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
  late List<int> exercisesToDelete = [];
  EquipmentItem? equipament;
  Map<String, int> categoryCounts = {};

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
    _loadAllItems();
  }

  void _loadAllItems() async {
    final categories = await EquipmentService().loadCategories();
    final counts = {for (var c in categories) c.category: c.total};

    setState(() {
      categoryCounts = counts;
    });
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
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    display_categories(
                                      context,
                                      'Categorias de Equipamento',
                                      Colors.blue[100]!,
                                      Colors.blue[800]!,
                                      categoryCounts,
                                      (categoriaSelecionada) async {
                                        final categorias = await EquipmentService().loadCategories();
                                        if (categoriaSelecionada != null) {
                                          final categoria = categorias.firstWhere((c) => c.category == categoriaSelecionada);

                                          final equipamentoSelecionado  = await Navigator.push<EquipmentItem>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChooseEquipmentScreen(categoria: categoria,fallbackImage: () => const Icon(Icons.fitness_center, size: 64),),
                                            ),
                                          );

                                          if (equipamentoSelecionado  != null) {
                                            setState(() {
                                              equipament = equipamentoSelecionado;
                                              exercise.equipmentId = equipament!.id;
                                            });
                                          }
                                        }else {
                                          setState(() {
                                            equipament = null;
                                            exercise.equipmentId = null;
                                          });
                                        }
                                        
                                      
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: Text(
                                    equipament?.name.isNotEmpty == true
                                      ? equipament!.name
                                      : "Selecionar Equipamento"
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