import 'package:academia_unifor/services/exercise_service.dart';
import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models/exercise.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 2,
          child: const ExercisesBody(),
        ),
      ),
    );
  }
}

class ExercisesBody extends StatefulWidget {
  const ExercisesBody({super.key});

  @override
  State<ExercisesBody> createState() => _ExercisesBodyState();
}

class _ExercisesBodyState extends State<ExercisesBody> {
  String? selectedCategory;
  List<Exercise> allExercises = [];
  List<Exercise> selectedExercises = [];
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _loadAllExercises();
  }

  void _loadAllExercises() async {
    final exercises = await loadExercises();

    final Map<String, List<Exercise>> grouped = {};
    for (var ex in exercises) {
      grouped.putIfAbsent(ex.type, () => []).add(ex);
    }

    final counts = {
      for (var entry in grouped.entries) entry.key: entry.value.length,
    };

    setState(() {
      allExercises = exercises;
      categoryCounts = counts;
    });
  }

  void _loadCategory(String category) {
    final filtered = allExercises.where((e) => e.type == category).toList();

    setState(() {
      selectedCategory = category;
      selectedExercises = filtered;
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        selectedCategory = null;
        selectedExercises = [];
      });
      return;
    }

    final filtered =
        allExercises.where((exercise) {
          final lower = query.toLowerCase();
          return exercise.name.toLowerCase().contains(lower);
        }).toList();

    setState(() {
      selectedCategory = 'Resultados da busca';
      selectedExercises = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: SearchAppBar(
        onSearchChanged: _onSearchChanged,
        showChatIcon: false,
        onBack:
            selectedCategory != null
                ? () {
                  setState(() {
                    selectedCategory = null;
                    selectedExercises = [];
                  });
                }
                : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              selectedCategory == null
                  ? _EmptySearchSection(
                    categoryCounts: categoryCounts,
                    chipColor: chipColor,
                    textColor: textColor,
                    onChipTap: _loadCategory,
                  )
                  : _SelectedCategoryList(
                    selectedCategory: selectedCategory!,
                    items: selectedExercises,
                    onBack: () {
                      setState(() {
                        selectedCategory = null;
                        selectedExercises = [];
                      });
                    },
                  ),
        ),
      ),
    );
  }
}

class _EmptySearchSection extends StatelessWidget {
  final Map<String, int> categoryCounts;
  final Color chipColor;
  final Color textColor;
  final void Function(String) onChipTap;

  const _EmptySearchSection({
    required this.categoryCounts,
    required this.chipColor,
    required this.textColor,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Pesquise por um treino...",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children:
                  categoryCounts.entries.map((entry) {
                    final name = entry.key;
                    final total = entry.value;
                    return ActionChip(
                      label: Text('$name ($total)'),
                      backgroundColor: chipColor,
                      labelStyle: TextStyle(color: textColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.transparent),
                      ),
                      onPressed: () => onChipTap(name),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCategoryList extends StatelessWidget {
  final String selectedCategory;
  final List<Exercise> items;
  final VoidCallback onBack;

  const _SelectedCategoryList({
    required this.selectedCategory,
    required this.items,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text('Tipo: ${item.type}, Nível: ${item.level}'),
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}
