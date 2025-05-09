import 'package:academia_unifor/models.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';

class EditExerciseScreen extends StatefulWidget {
  final Workout workout;
  final Map<int, EquipmentItem> equipmentMap;
  final Map<String, int> categoryCounts;
  final bool hasUnsavedChanges;

  const EditExerciseScreen({
    super.key,
    required this.workout,
    required this.equipmentMap,
    required this.categoryCounts,
    this.hasUnsavedChanges = false,
  });

  @override
  EditExerciseScreenState createState() => EditExerciseScreenState();
}

class EditExerciseScreenState extends State<EditExerciseScreen> {
  late List<int> exercisesToDelete = [];
  late Workout workout;
  late List<Exercise>
  _originalExercises; // Guarda a lista original de exercícios
  late TextEditingController _workoutNameController;
  late TextEditingController _workoutDescController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
    // Guarda a lista original de exercícios
    _originalExercises = List<Exercise>.from(
      workout.exercises.map(
        (e) => Exercise(
          id: e.id,
          workoutId: e.workoutId,
          name: e.name,
          reps: e.reps,
          notes: e.notes,
          equipmentId: e.equipmentId,
        ),
      ),
    );

    _workoutNameController = TextEditingController(text: workout.name);
    _workoutDescController = TextEditingController(text: workout.description);
    _hasChanges = widget.hasUnsavedChanges;

    _workoutNameController.addListener(_checkForChanges);
    _workoutDescController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges =
        _workoutNameController.text != workout.name ||
        _workoutDescController.text != workout.description;
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    _workoutDescController.dispose();
    super.dispose();
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
      _hasChanges = true;
    });
  }

  Future<void> _removeExercise(int index) async {
    final confirmed = await confirmationDialog(
      context,
      title: 'Confirmar Exclusão',
      message: 'Deseja realmente remover este exercício?',
    );

    if (confirmed ?? false) {
      if (workout.exercises[index].id != 0) {
        exercisesToDelete.add(workout.exercises[index].id);
      }
      setState(() {
        workout.exercises.removeAt(index);
        _hasChanges = true;
      });
    }
  }

  Future<bool> _confirmExit() async {
    if (!_hasChanges && exercisesToDelete.isEmpty) return true;

    final confirmed = await confirmationDialog(
      context,
      title: 'Alterações não salvas',
      message: 'Você tem alterações não salvas. Deseja sair mesmo assim?',
    );

    if (confirmed ?? false) {
      // Restaura os exercícios originais se sair sem salvar
      setState(() {
        workout.exercises = List<Exercise>.from(
          _originalExercises.map(
            (e) => Exercise(
              id: e.id,
              workoutId: e.workoutId,
              name: e.name,
              reps: e.reps,
              notes: e.notes,
              equipmentId: e.equipmentId,
            ),
          ),
        );
        exercisesToDelete.clear();
        _hasChanges = false;
      });
      return true;
    }
    return false;
  }

  Future<void> _saveWorkoutAndExercises() async {
    final confirmed = await confirmationDialog(
      context,
      title: 'Salvar Alterações',
      message: 'Deseja salvar todas as alterações realizadas?',
    );

    if (confirmed ?? false) {
      try {
        // 1. Atualiza os dados do Workout
        workout.name = _workoutNameController.text;
        workout.description = _workoutDescController.text;

        // 2. Salva o Workout primeiro
        final savedWorkout =
            workout.id == 0
                ? await UserService().postWorkout(workout)
                : await UserService().putWorkout(workout);

        if (savedWorkout != null) {
          workout = savedWorkout;
          // Atualiza a lista original quando salva
          _originalExercises = List<Exercise>.from(workout.exercises);
        }

        // 3. Processa os exercícios marcados para deleção
        for (int id in exercisesToDelete) {
          await UserService().deleteExercise(id);
        }

        // 4. Salva/atualiza os exercícios existentes
        for (Exercise exercise in workout.exercises) {
          exercise.workoutId = workout.id;

          if (exercise.id == 0) {
            await UserService().postExercise(exercise);
          } else {
            await UserService().putExercise(exercise);
          }
        }

        // 5. Busca a versão atualizada do servidor
        final updatedWorkout = await UserService().getWorkoutById(workout.id);
        if (mounted) {
          Navigator.pop(context, updatedWorkout ?? workout);
        }
      } catch (e) {
        print('Erro ao salvar: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar ${workout.name}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveWorkoutAndExercises,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Seção de edição do Workout
              Card(
                elevation: 2,
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações do Treino',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _workoutNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Treino',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _workoutDescController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Seção de exercícios
              ...workout.exercises.asMap().entries.map((entry) {
                final exIndex = entry.key;
                final exercise = entry.value;
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
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeExercise(exIndex),
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
                          onChanged: (value) {
                            exercise.name = value;
                            _hasChanges = true;
                          },
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
                          onChanged: (value) {
                            exercise.reps = value;
                            _hasChanges = true;
                          },
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
                          onChanged: (value) {
                            exercise.notes = value;
                            _hasChanges = true;
                          },
                        ),
                        const SizedBox(height: 8),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Equipamento',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.equipmentId != null
                                      ? widget
                                              .equipmentMap[exercise
                                                  .equipmentId]
                                              ?.name ??
                                          'Carregando...'
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
                                        final categorias =
                                            await EquipmentService()
                                                .loadCategories();
                                        final categoria = categorias.firstWhere(
                                          (c) =>
                                              c.category ==
                                              categoriaSelecionada,
                                        );

                                        final equipamentoSelecionado =
                                            await Navigator.push<EquipmentItem>(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => ChooseEquipmentScreen(
                                                      categoria: categoria,
                                                      fallbackImage:
                                                          () => const Icon(
                                                            Icons
                                                                .fitness_center,
                                                            size: 64,
                                                          ),
                                                    ),
                                              ),
                                            );

                                        if (equipamentoSelecionado != null) {
                                          setState(() {
                                            widget.equipmentMap[equipamentoSelecionado
                                                    .id] =
                                                equipamentoSelecionado;
                                            exercise.equipmentId =
                                                equipamentoSelecionado.id;
                                            _hasChanges = true;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          exercise.equipmentId = null;
                                          _hasChanges = true;
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
              }).toList(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addExercise,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
