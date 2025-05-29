import 'package:academia_unifor/models/classes.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/classes_service.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:academia_unifor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academia_unifor/widgets.dart';

// ...existing code...

class ClassScreen extends StatelessWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: SearchAppBar(
        showChatIcon: false,
        onSearchChanged: (query) {
          // Passa o termo de busca para o ClassBody via chave global
          _classBodyKey.currentState?.filterClasses(query);
        },
      ),
      body: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 2,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: ClassBody(key: _classBodyKey),
          ),
        ),
      ),
    );
  }
}

// Adicione uma GlobalKey para acessar o estado do ClassBody
final GlobalKey<_ClassBodyState> _classBodyKey = GlobalKey<_ClassBodyState>();

class ClassBody extends ConsumerStatefulWidget {
  const ClassBody({super.key});

  @override
  ConsumerState<ClassBody> createState() => _ClassBodyState();
}

class _ClassBodyState extends ConsumerState<ClassBody> {
  late Future<List<Classes>> _classesFuture;
  List<Classes> _allClasses = [];
  List<Classes> _filteredClasses = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _classesFuture = _loadAndSetClasses();
  }

  Future<List<Classes>> _loadAndSetClasses() async {
    final classes = await ClassesService().loadClasses();
    setState(() {
      _allClasses = classes;
      _filteredClasses = classes;
    });
    return classes;
  }

  void _refreshClasses() {
    setState(() {
      _classesFuture = _loadAndSetClasses();
    });
  }

  void filterClasses(String query) {
    setState(() {
      _searchQuery = query;
      _filteredClasses =
          _allClasses
              .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);

    return Column(
      children: [
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
              final classes =
                  _searchQuery.isEmpty ? _allClasses : _filteredClasses;
              if (classes.isEmpty) {
                return const Center(child: Text('Nenhuma aula encontrada'));
              }
              classes.sort((a, b) {
                DateTime parseDate(String date) {
                  final parts = date.split('/');
                  if (parts.length != 3) return DateTime(1900);
                  return DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                }

                final dateA = parseDate(a.date);
                final dateB = parseDate(b.date);
                return dateA.compareTo(dateB);
              });
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

  // ...existing code...

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
                          if (mounted) {
                            _showSnack(context, 'Faça login para se inscrever');
                          }
                          return;
                        }

                        try {
                          if (classItem.studentIds.length >=
                                  classItem.capacity &&
                              !isSubscribed) {
                            if (mounted) {
                              _showSnack(
                                context,
                                'Aula cheia, não é possível se inscrever',
                              );
                            }
                            return;
                          }
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

                          if (mounted) {
                            _refreshClasses();

                            _showSnack(
                              context,
                              isSubscribed
                                  ? 'Inscrição cancelada'
                                  : 'Inscrição realizada',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            _showSnack(context, 'Erro: ${e.toString()}');
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            classItem.studentIds.length >= classItem.capacity &&
                                    !isSubscribed
                                ? Colors.grey
                                : isSubscribed
                                ? Colors.red
                                : Colors.green,
                        backgroundColor: (classItem.studentIds.length >=
                                        classItem.capacity &&
                                    !isSubscribed
                                ? Colors.grey
                                : isSubscribed
                                ? Colors.red
                                : Colors.green)
                            .withAlpha(20),
                        side: BorderSide(
                          color:
                              classItem.studentIds.length >=
                                          classItem.capacity &&
                                      !isSubscribed
                                  ? Colors.grey
                                  : isSubscribed
                                  ? Colors.red
                                  : Colors.green,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        classItem.studentIds.length >= classItem.capacity &&
                                !isSubscribed
                            ? "Aula cheia"
                            : isSubscribed
                            ? "Cancelar"
                            : "Inscrever-se",
                      ),
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
