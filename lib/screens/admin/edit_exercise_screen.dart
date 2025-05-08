import 'package:academia_unifor/models.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';

class EditExerciseScreen extends StatefulWidget {
  final Workout workout;
  final Map<int, EquipmentItem> equipmentMap;
  final Map<String, int> categoryCounts;

  const EditExerciseScreen({
    super.key,
    required this.workout,
    required this.equipmentMap,
    required this.categoryCounts,
  });

  @override
  EditExerciseScreenState createState() => EditExerciseScreenState();
}

class EditExerciseScreenState extends State<EditExerciseScreen> {
  late List<int> exercisesToDelete = [];
  late Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  void _addExercise() {
    setState(() {
      workout.exercises.add(
        Exercise(
          id: 0,
          workoutId: workout.id,
          name: 'Novo Exercício',
          reps: '3x10',
          notes: '',
        ),
      );
    });
  }

  void _removeExercise(int index) {
    if (workout.exercises[index].id != 0) {
      exercisesToDelete.add(workout.exercises[index].id);
    }
    setState(() {
      workout.exercises.removeAt(index);
    });
  }

  Future<void> _saveExercises() async {
    try {
      // Primeiro salva os exercícios marcados para deleção
      for (int id in exercisesToDelete) {
        await UserService().deleteExercise(id);
      }

      // Depois salva/atualiza os exercícios existentes
      for (Exercise exercise in workout.exercises) {
        if (exercise.id == 0) {
          // Garante que o exercise tem o workoutId correto
          exercise.workoutId = workout.id;
          await UserService().postExercise(exercise);
        } else {
          await UserService().putExercise(exercise);
        }
      }

      // Atualiza a lista de exercícios com os dados salvos
      final updatedWorkout = await UserService().getWorkoutById(workout.id);
      Navigator.pop(context, updatedWorkout ?? workout);
    } catch (e) {
      print('Erro ao salvar exercícios: $e');
      // Se houver erro, retorna pelo menos o workout com as alterações locais
      Navigator.pop(context, workout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Exercícios - ${workout.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExercises,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercício ${exIndex + 1}',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeExercise(exIndex),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: exercise.name),
                      decoration: const InputDecoration(
                        labelText: 'Nome do Exercício',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => exercise.name = value),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: exercise.reps),
                      decoration: const InputDecoration(
                        labelText: 'Repetições',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => exercise.reps = value),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: exercise.notes ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'Notas / Observações',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) => setState(() => exercise.notes = value),
                    ),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Equipamento',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.equipmentId != null
                                  ? widget.equipmentMap[exercise.equipmentId]?.name ?? 'Carregando...'
                                  : 'Nenhum equipamento selecionado',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              displayCategories(
                                context,
                                'Categorias de Equipamento',
                                Colors.blue[100]!,
                                Colors.blue[800]!,
                                widget.categoryCounts,
                                (categoriaSelecionada) async {
                                  if (categoriaSelecionada != null) {
                                    final categorias = await EquipmentService().loadCategories();
                                    final categoria = categorias.firstWhere((c) => c.category == categoriaSelecionada);
                                    
                                    final equipamentoSelecionado = await Navigator.push<EquipmentItem>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseEquipmentScreen(
                                          categoria: categoria,
                                          fallbackImage: () => const Icon(Icons.fitness_center, size: 64),
                                        ),
                                      ),
                                    );

                                    if (equipamentoSelecionado != null) {
                                      setState(() {
                                        widget.equipmentMap[equipamentoSelecionado.id] = equipamentoSelecionado;
                                        exercise.equipmentId = equipamentoSelecionado.id;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      exercise.equipmentId = null;
                                    });
                                  }
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Selecionar'),
                          ),
                        ],
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
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}