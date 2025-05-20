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
  late List<Exercise> _originalExercises;
  late TextEditingController _workoutNameController;
  late TextEditingController _workoutDescController;
  bool _hasChanges = false;
  final ExerciseValidator _validator = ExerciseValidator();
  final Map<int, String?> _exerciseErrors = {};
  late List<TextEditingController> _nameControllers = [];
  late List<TextEditingController> _repsControllers = [];
  late List<TextEditingController> _notesControllers = [];

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
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

    _initializeControllers();

    _workoutNameController.addListener(_checkForChanges);
    _workoutDescController.addListener(_checkForChanges);
  }

  void _initializeControllers() {
    _nameControllers =
        workout.exercises
            .map((e) => TextEditingController(text: e.name))
            .toList();
    _repsControllers =
        workout.exercises
            .map((e) => TextEditingController(text: e.reps))
            .toList();
    _notesControllers =
        workout.exercises
            .map((e) => TextEditingController(text: e.notes ?? ''))
            .toList();
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
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _notesControllers) {
      controller.dispose();
    }
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
      _nameControllers.add(TextEditingController(text: 'Novo Exercício'));
      _repsControllers.add(TextEditingController(text: '3x10'));
      _notesControllers.add(TextEditingController());
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
        _nameControllers[index].dispose();
        _repsControllers[index].dispose();
        _notesControllers[index].dispose();

        _nameControllers.removeAt(index);
        _repsControllers.removeAt(index);
        _notesControllers.removeAt(index);

        workout.exercises.removeAt(index);
        _exerciseErrors.remove(index);
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
        _exerciseErrors.clear();
        _hasChanges = false;
        _initializeControllers();
      });
      return true;
    }
    return false;
  }

  bool _validateAllExercises() {
    bool isValid = true;
    final errors = <int, String?>{};

    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      final error = _validator.validateExercise(exercise);

      if (error != null) {
        errors[i] = error;
        isValid = false;
      } else {
        errors[i] = null;
      }
    }

    setState(() {
      _exerciseErrors.clear();
      _exerciseErrors.addAll(errors);
    });

    return isValid;
  }

  Future<void> _saveWorkoutAndExercises() async {
    if (!_validateAllExercises()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrija os erros nos exercícios antes de salvar'),
        ),
      );
      return;
    }

    final confirmed = await confirmationDialog(
      context,
      title: 'Salvar Alterações',
      message: 'Deseja salvar todas as alterações realizadas?',
    );

    if (confirmed ?? false) {
      try {
        workout.name = _workoutNameController.text;
        workout.description = _workoutDescController.text;

        final savedWorkout =
            workout.id == 0
                ? await UserService().postWorkout(workout)
                : await UserService().putWorkout(workout);

        workout = savedWorkout;
        _originalExercises = List<Exercise>.from(workout.exercises);

        for (int id in exercisesToDelete) {
          await UserService().deleteExercise(id);
        }

        for (Exercise exercise in workout.exercises) {
          exercise.workoutId = workout.id;

          if (exercise.id == 0) {
            await UserService().postExercise(exercise);
          } else {
            await UserService().putExercise(exercise);
          }
        }

        final updatedWorkout = await UserService().getWorkoutById(workout.id);
        if (mounted) {
          Navigator.pop(context, updatedWorkout);
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final canPop = await _confirmExit();
          if (canPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
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
                      //TODO
                      TextField(
                        controller: _workoutNameController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Treino',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(77),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(77),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onPrimary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withAlpha(200),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _workoutDescController,
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(77),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(77),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onPrimary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withAlpha(200),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                          controller: _nameControllers[exIndex],
                          cursorColor: Theme.of(context).colorScheme.onPrimary,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Nome do Exercício',
                            errorText:
                                _exerciseErrors[exIndex]?.contains('nome') ??
                                        false
                                    ? _exerciseErrors[exIndex]
                                    : null,
                            errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(200),
                            ),
                          ),
                          onChanged: (value) {
                            exercise.name = value;
                            _hasChanges = true;
                            final error =
                                _validator.validateName(value)
                                    ? null
                                    : value.isEmpty
                                    ? 'O nome do exercício é obrigatório'
                                    : 'O nome deve ter entre 2 e 50 caracteres';
                            setState(() {
                              _exerciseErrors[exIndex] = error;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _repsControllers[exIndex],
                          cursorColor: Theme.of(context).colorScheme.onPrimary,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Repetições',
                            errorText:
                                _exerciseErrors[exIndex]?.contains(
                                          'repetições',
                                        ) ??
                                        false
                                    ? _exerciseErrors[exIndex]
                                    : null,
                            errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(200),
                            ),
                          ),
                          onChanged: (value) {
                            exercise.reps = value;
                            _hasChanges = true;
                            final error =
                                _validator.validateReps(value)
                                    ? null
                                    : value.isEmpty
                                    ? 'As repetições são obrigatórias'
                                    : 'As repetições devem ter no máximo 20 caracteres';
                            setState(() {
                              _exerciseErrors[exIndex] = error;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesControllers[exIndex],
                          cursorColor: Theme.of(context).colorScheme.onPrimary,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Notas / Observações',
                            errorText:
                                _exerciseErrors[exIndex]?.contains(
                                          'observações',
                                        ) ??
                                        false
                                    ? _exerciseErrors[exIndex]
                                    : null,
                            errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(200),
                            ),
                          ),
                          onChanged: (value) {
                            exercise.notes = value;
                            _hasChanges = true;
                            final error =
                                _validator.validateNotes(value)
                                    ? null
                                    : 'As observações devem ter no máximo 200 caracteres';
                            setState(() {
                              _exerciseErrors[exIndex] = error;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Equipamento',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withAlpha(77),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
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
                                      : 'Nenhum equipamento',
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
