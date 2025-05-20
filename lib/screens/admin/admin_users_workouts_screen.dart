import 'package:academia_unifor/models.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';

class AdminUsersWorkoutsScreen extends StatefulWidget {
  final Users user;

  const AdminUsersWorkoutsScreen({super.key, required this.user});

  @override
  AdminUsersWorkoutsScreenState createState() =>
      AdminUsersWorkoutsScreenState();
}

class AdminUsersWorkoutsScreenState extends State<AdminUsersWorkoutsScreen> {
  late List<Workout> workouts;
  Map<int, EquipmentItem> equipmentMap = {};
  Map<String, int> categoryCounts = {};
  bool _isLoading = true;

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final newWorkouts = await UserService().getWorkoutsByUserId(
        widget.user.id,
      );

      for (var workout in newWorkouts) {
        for (var exercise in workout.exercises) {
          if (exercise.equipmentId != null &&
              !equipmentMap.containsKey(exercise.equipmentId)) {
            final equipment = await EquipmentService().getEquipmentById(
              exercise.equipmentId!,
            );
            equipmentMap[exercise.equipmentId!] = equipment;
          }
        }
      }

      setState(() {
        workouts = newWorkouts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar treinos: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    workouts = widget.user.workouts;
    _loadWorkouts();
    _loadAllItems();
  }

  void _loadAllItems() async {
    try {
      final categories = await EquipmentService().loadCategories();
      final counts = {for (var c in categories) c.category: c.total};

      setState(() {
        categoryCounts = counts;
      });
    } catch (e) {
      print('Erro ao carregar categorias: $e');
    }
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

      final savedWorkout = await UserService().postWorkout(newWorkout);
      setState(() {
        workouts.add(savedWorkout);
      });
      return savedWorkout;
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao adicionar treino: $e')));
      rethrow;
    }
  }

  Future<void> _removeWorkout(int index) async {
    final confirmed = await confirmationDialog(
      context,
      title: 'Confirmar Exclusão',
      message:
          'Deseja realmente remover este treino? Todos os exercícios serão perdidos.',
    );

    if (confirmed ?? false) {
      try {
        if (workouts[index].id != 0) {
          await UserService().deleteWorkout(workouts[index].id);
        }

        setState(() {
          workouts.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino removido com sucesso')),
        );
      } catch (e) {
        print('Erro ao remover treino: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao remover treino: $e')));
      }
    }
  }

  String getFirstName(String fullName) {
    return fullName.split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treinos - ${getFirstName(widget.user.name)}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadWorkouts,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      workouts.isEmpty
                          ? const Center(
                            child: Text('Nenhum treino cadastrado'),
                          )
                          : ListView.builder(
                            itemCount: workouts.length,
                            itemBuilder: (context, index) {
                              final workout = workouts[index];
                              return workoutCard(context, workout, index);
                            },
                          ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }

  Card workoutCard(BuildContext context, Workout workout, int index) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${workout.exercises.length} exercícios',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updatedWorkout = await Navigator.push<Workout>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditExerciseScreen(
                              workout: workout,
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
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeWorkout(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
