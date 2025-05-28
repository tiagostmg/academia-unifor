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

class ClassBody extends ConsumerStatefulWidget {
  const ClassBody({super.key});

  @override
  ConsumerState<ClassBody> createState() => _ClassBodyState();
}

class _ClassBodyState extends ConsumerState<ClassBody> {
  late Future<List<Classes>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _classesFuture = ClassesService().loadClasses();
  }

  void _refreshClasses() {
    setState(() {
      _classesFuture = ClassesService().loadClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);

    return Column(
      children: [
        const SearchAppBar(showChatIcon: false),
        Expanded(
          child: FutureBuilder<List<Classes>>(
            future: _classesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar aulas'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma aula encontrada'));
              }
              final classes = snapshot.data!;
              classes.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
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
                            "${classItem.time} - ${_formatTimeSum(classItem.time, classItem.duration)}",
                          ),
                          const SizedBox(height: 4),
                          _buildClassInfoRow(
                            context,
                            Icons.calendar_month_outlined,
                            classItem.date,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () async {
                        if (currentUser == null) {
                          _showSnack(context, 'Faça login para se inscrever');
                          return;
                        }

                        try {
                          if (isSubscribed) {
                            await ClassesService().unsubscribeUser(
                              classItem.id,
                              currentUser.id,
                            );
                          } else {
                            await ClassesService().subscribeUser(
                              classItem.id,
                              currentUser.id,
                            );
                          }

                          _refreshClasses();

                          _showSnack(
                            context,
                            isSubscribed
                                ? 'Inscrição cancelada'
                                : 'Inscrição realizada',
                          );
                        } catch (e) {
                          _showSnack(context, 'Erro: ${e.toString()}');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isSubscribed ? Colors.red : Colors.green,
                        backgroundColor: (isSubscribed
                                ? Colors.red
                                : Colors.green)
                            .withAlpha(20),
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
        );
      },
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
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

  String _formatTimeSum(String time1, String time2) {
    final parts1 = time1.split(':');
    final parts2 = time2.split(':');

    if (parts1.length != 2 || parts2.length != 2) return '00:00';

    final hours1 = int.tryParse(parts1[0]) ?? 0;
    final minutes1 = int.tryParse(parts1[1]) ?? 0;
    final hours2 = int.tryParse(parts2[0]) ?? 0;
    final minutes2 = int.tryParse(parts2[1]) ?? 0;

    final totalMinutes = (hours1 * 60 + minutes1) + (hours2 * 60 + minutes2);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
