import 'package:academia_unifor/models/classes.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/classes_service.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:academia_unifor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final currentUser = ref.watch(userProvider);

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
                  return _buildClassCard(context, classItem, currentUser);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    Classes classItem,
    Users? currentUser,
  ) {
    final theme = Theme.of(context);

    int teacherId = classItem.teacherId;
    bool isSubscribed =
        currentUser != null && classItem.studentIds.contains(currentUser.id);

    return FutureBuilder<Users>(
      future: UserService().getUserById(teacherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            color: theme.colorScheme.surface,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            color: theme.colorScheme.surface,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Erro ao carregar instrutor'),
            ),
          );
        }
        final instructor = snapshot.data!;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 2,
          color: theme.colorScheme.primary,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navegar para detalhes da aula
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        classItem.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      Chip(
                        backgroundColor: theme.colorScheme.primary,
                        avatar: Icon(
                          Icons.person,
                          color: theme.colorScheme.onPrimary,
                          size: 18,
                        ),
                        label: Text(
                          "${classItem.studentIds.length}/${classItem.capacity}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Info e botão centralizado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildClassInfoRow(
                              context,
                              Icons.person,
                              instructor.name,
                            ),
                            const SizedBox(height: 4),
                            _buildClassInfoRow(
                              context,
                              Icons.access_time,
                              "${classItem.time} - ${classItem.time + classItem.duration}",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () async {
                          if (currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Faça login para se inscrever'),
                              ),
                            );
                            return;
                          }

                          try {
                            if (isSubscribed) {
                              // Lógica para cancelar inscrição
                              await ClassesService().unsubscribeUser(classItem.id, currentUser.id);
                            } else {
                              // Lógica para inscrever-se
                              await ClassesService().subscribeUser(classItem.id, currentUser.id);
                            }

                            // Atualiza a UI
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isSubscribed
                                      ? 'Inscrição cancelada'
                                      : 'Inscrição realizada',
                                ),
                              ),
                            );
                            
                            // Força a reconstrução do widget para atualizar a lista
                            (context as Element).markNeedsBuild();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: ${e.toString()}')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isSubscribed ? Colors.red : Colors.green,
                          backgroundColor:
                              isSubscribed
                                  ? Colors.red.withAlpha(20)
                                  : Colors.green.withAlpha(20),
                          side: BorderSide(
                            color: isSubscribed ? Colors.red : Colors.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(isSubscribed ? "Cancelar" : "Inscrever-se"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
