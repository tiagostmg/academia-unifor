import 'package:academia_unifor/models/classes.dart';
import 'package:academia_unifor/services/classes_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:academia_unifor/widgets.dart';

class ClassScreen extends StatelessWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 2,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const ClassBody(),
          ),
        ),
      ),
    );
  }
}

class ClassBody extends ConsumerWidget {
  const ClassBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SearchAppBar(showChatIcon: false),
        Expanded(
          child: FutureBuilder<List<Classes>>(
            future: ClassesService().loadClasses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar aulas'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Nenhuma aula encontrada'));
              }
              final classes = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classItem = classes[index];
                  return _buildClassCard(context, classItem);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(BuildContext context, Classes classItem) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navegar para detalhes da aula
          context.push('/class-details', extra: classItem);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    classItem.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    backgroundColor: theme.colorScheme.primary.withAlpha(50),
                    label: Text(
                      "${classItem.studentIds.length}/${classItem.capacity}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // _buildClassInfoRow(context, Icons.person, classItem.instructor),
              // const SizedBox(height: 4),
              _buildClassInfoRow(
                context,
                Icons.access_time,
                "${classItem.time} - ${classItem.time}",
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Cancelar inscrição
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 8),
                  // CustomButton(
                  //   text: "Detalhes",
                  //   onPressed: () {
                  //     context.push('/class-details', extra: classItem);
                  //   },
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
