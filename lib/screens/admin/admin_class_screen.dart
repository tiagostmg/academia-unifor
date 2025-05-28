import 'package:flutter/material.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models.dart';
import 'package:go_router/go_router.dart';

class AdminClassScreen extends StatefulWidget {
  const AdminClassScreen({super.key});

  @override
  State<AdminClassScreen> createState() => _AdminClassScreenState();
}

class _AdminClassScreenState extends State<AdminClassScreen> {
  List<Classes> allClasses = [];
  List<Classes> filteredClasses = [];
  final ClassesService _classService = ClassesService();

  Future<void> _loadClasses() async {
    try {
      final classes = await _classService.loadClasses();

      setState(() {
        allClasses = classes;
        filteredClasses = classes;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar aulas: $e')));
    }
  }

  void _filterClasses(String query) {
    setState(() {
      filteredClasses =
          allClasses
              .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> _updateClass(Classes updated) async {
    try {
      if (updated.id == 0) {
        final created = await _classService.postClass(updated);
        setState(() {
          allClasses.add(created);
          filteredClasses = List.from(allClasses);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aula criada com sucesso!')),
        );
      } else {
        await _classService.putClass(updated);
        setState(() {
          final index = allClasses.indexWhere((c) => c.id == updated.id);
          if (index != -1) {
            allClasses[index] = updated;
            filteredClasses = List.from(allClasses);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aula atualizada com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar aula: $e')));
    }
  }

  Future<void> _deleteClass(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text('Deseja realmente excluir esta aula?'),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _classService.deleteClass(id);
        setState(() {
          allClasses.removeWhere((c) => c.id == id);
          filteredClasses = List.from(allClasses);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aula excluída com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir aula: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: SearchAppBar(
            onBack: () => context.go('/admin/'),
            onSearchChanged: _filterClasses,
            showChatIcon: false,
          ),
          body: ClassesScreenBody(
            classes: filteredClasses,
            onUpdate: _updateClass,
            onDelete: _deleteClass,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EditClassScreen(
                        classItem: Classes(
                          id: 0,
                          name: '',
                          type: '',
                          date: '',
                          time: '',
                          duration: '',
                          capacity: 0,
                          teacherId: 1,
                          studentIds: [],
                        ),
                        isEditing: false,
                      ),
                ),
              );
              if (result != null && result is Classes) {
                await _updateClass(result);
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class ClassesScreenBody extends StatelessWidget {
  final List<Classes> classes;
  final Future<void> Function(Classes) onUpdate;
  final Future<void> Function(int) onDelete;

  const ClassesScreenBody({
    super.key,
    required this.classes,
    required this.onUpdate,
    required this.onDelete,
  });

  String formatarHora(String valor) {
    List<String> partes = valor.split(":");
    String hora = partes[0].padLeft(2, '0');
    String minuto = partes[1].padLeft(2, '0');
    return "$hora:$minuto";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              classes.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
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

    int teacherId = classItem.teacherId;

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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditClassScreen(
                                        classItem: classItem,
                                        isEditing: true,
                                      ),
                                ),
                              ).then((result) {
                                if (result != null && result is Classes) {
                                  onUpdate(result);
                                }
                              });
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () async {
                              await onDelete(classItem.id);
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
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

  String _formatTimeSum(String time1, String time2) {
    final parts1 = time1.split(':');
    final parts2 = time2.split(':');

    if (parts1.length != 2 || parts2.length != 2) {
      return '00:00';
    }

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

class EditClassScreen extends StatefulWidget {
  final Classes classItem;
  final bool isEditing;
  final bool hasUnsavedChanges;

  const EditClassScreen({
    super.key,
    required this.classItem,
    required this.isEditing,
    this.hasUnsavedChanges = false,
  });

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _durationController;
  late TextEditingController _capacityController;
  late int _selectedTeacherId;
  late List<int> _selectedStudentIds;
  bool _isSaving = false;
  bool _hasChanges = false;
  final Map<String, String?> _fieldErrors = {
    'name': null,
    'type': null,
    'date': null,
    'time': null,
    'duration': null,
    'capacity': null,
    'teacher': null,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classItem.name);
    _typeController = TextEditingController(text: widget.classItem.type);
    _dateController = TextEditingController(text: widget.classItem.date);
    _timeController = TextEditingController(text: widget.classItem.time);
    _durationController = TextEditingController(
      text: widget.classItem.duration,
    );
    _capacityController = TextEditingController(
      text: widget.classItem.capacity.toString(),
    );
    _selectedTeacherId = widget.classItem.teacherId;
    _selectedStudentIds = List.from(widget.classItem.studentIds);
    _hasChanges = widget.hasUnsavedChanges;

    _nameController.addListener(_checkForChanges);
    _typeController.addListener(_checkForChanges);
    _dateController.addListener(_checkForChanges);
    _timeController.addListener(_checkForChanges);
    _durationController.addListener(_checkForChanges);
    _capacityController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges =
        _nameController.text != widget.classItem.name ||
        _typeController.text != widget.classItem.type ||
        _dateController.text != widget.classItem.date ||
        _timeController.text != widget.classItem.time ||
        _durationController.text != widget.classItem.duration ||
        _capacityController.text != widget.classItem.capacity.toString() ||
        _selectedTeacherId != widget.classItem.teacherId ||
        !_areListsEqual(_selectedStudentIds, widget.classItem.studentIds);

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  bool _areListsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  void _validateField(String fieldName, String value) {
    String? error;

    switch (fieldName) {
      case 'name':
        if (value.isEmpty) {
          error = 'O nome da aula é obrigatório';
        } else if (value.length > 50) {
          error = 'O nome deve ter no máximo 50 caracteres';
        }
        break;
      case 'type':
        if (value.isEmpty) {
          error = 'O tipo da aula é obrigatório';
        }
        break;
      case 'date':
        if (value.isEmpty) {
          error = 'A data é obrigatória';
        }
        break;
      case 'time':
        if (value.isEmpty) {
          error = 'O horário é obrigatório';
        }
        break;
      case 'duration':
        if (value.isEmpty) {
          error = 'A duração é obrigatória';
        }
        break;
      case 'capacity':
        if (value.isEmpty) {
          error = 'A capacidade é obrigatória';
        } else if (int.tryParse(value) == null) {
          error = 'Digite um número válido';
        }
        break;
      case 'teacher':
        if (_selectedTeacherId == 0) {
          error = 'Selecione um professor';
        }
        break;
    }

    setState(() {
      _fieldErrors[fieldName] = error;
    });
  }

  bool _validateAllFields() {
    _validateField('name', _nameController.text);
    _validateField('type', _typeController.text);
    _validateField('date', _dateController.text);
    _validateField('time', _timeController.text);
    _validateField('duration', _durationController.text);
    _validateField('capacity', _capacityController.text);
    _validateField('teacher', _selectedTeacherId.toString());

    return !_fieldErrors.values.any((error) => error != null);
  }

  Future<bool> _confirmExit() async {
    if (!_hasChanges) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Alterações não salvas'),
            content: const Text(
              'Você tem alterações não salvas. Deseja sair mesmo assim?',
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sair'),
              ),
            ],
          ),
    );

    return confirmed ?? false;
  }

  Future<void> _saveChanges() async {
    if (!_validateAllFields()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Salvar alterações'),
            content: const Text('Deseja salvar as alterações nesta aula?'),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salvar'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    final updated = Classes(
      id: widget.classItem.id,
      name: _nameController.text,
      type: _typeController.text,
      date: _dateController.text,
      time: _timeController.text,
      duration: _durationController.text,
      capacity: int.parse(_capacityController.text),
      teacherId: _selectedTeacherId,
      studentIds: _selectedStudentIds,
    );

    if (mounted) {
      Navigator.pop(context, updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text('Deseja realmente excluir esta aula?'),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onPrimary;
    final borderColor = textColor.withAlpha(178);
    final focusedBorderColor = textColor.withAlpha(76);
    final errorColor = theme.colorScheme.error;
    final cursorColor = textColor;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final canPop = await _confirmExit();
          if (canPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? "Editar Aula" : "Criar Aula"),
          actions: [
            IconButton(
              icon:
                  _isSaving
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveChanges,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        style: TextStyle(color: textColor),
                        cursorColor: cursorColor,
                        decoration: InputDecoration(
                          labelText: 'Nome da Aula*',
                          labelStyle: TextStyle(color: textColor),
                          errorText: _fieldErrors['name'],
                          errorStyle: TextStyle(color: errorColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['name'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['name'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['name'] != null
                                      ? errorColor
                                      : focusedBorderColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          _validateField('name', value);
                          _checkForChanges();
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _typeController,
                        style: TextStyle(color: textColor),
                        cursorColor: cursorColor,
                        decoration: InputDecoration(
                          labelText: 'Tipo da Aula*',
                          labelStyle: TextStyle(color: textColor),
                          errorText: _fieldErrors['type'],
                          errorStyle: TextStyle(color: errorColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['type'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['type'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['type'] != null
                                      ? errorColor
                                      : focusedBorderColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          _validateField('type', value);
                          _checkForChanges();
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _dateController,
                        style: TextStyle(color: textColor),
                        cursorColor: cursorColor,
                        decoration: InputDecoration(
                          labelText: 'Data* (DD/MM/AAAA)',
                          labelStyle: TextStyle(color: textColor),
                          errorText: _fieldErrors['date'],
                          errorStyle: TextStyle(color: errorColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['date'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['date'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['date'] != null
                                      ? errorColor
                                      : focusedBorderColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          _validateField('date', value);
                          _checkForChanges();
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _timeController,
                        style: TextStyle(color: textColor),
                        cursorColor: cursorColor,
                        decoration: InputDecoration(
                          labelText: 'Horário* (HH:MM)',
                          labelStyle: TextStyle(color: textColor),
                          errorText: _fieldErrors['time'],
                          errorStyle: TextStyle(color: errorColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['time'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['time'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['time'] != null
                                      ? errorColor
                                      : focusedBorderColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          _validateField('time', value);
                          _checkForChanges();
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _durationController,
                        style: TextStyle(color: textColor),
                        cursorColor: cursorColor,
                        decoration: InputDecoration(
                          labelText: 'Duração* (ex: 1 hora)',
                          labelStyle: TextStyle(color: textColor),
                          errorText: _fieldErrors['duration'],
                          errorStyle: TextStyle(color: errorColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['duration'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['duration'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['duration'] != null
                                      ? errorColor
                                      : focusedBorderColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          _validateField('duration', value);
                          _checkForChanges();
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _capacityController,
                        style: TextStyle(color: textColor),
                        cursorColor: cursorColor,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Capacidade*',
                          labelStyle: TextStyle(color: textColor),
                          errorText: _fieldErrors['capacity'],
                          errorStyle: TextStyle(color: errorColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['capacity'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['capacity'] != null
                                      ? errorColor
                                      : borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _fieldErrors['capacity'] != null
                                      ? errorColor
                                      : focusedBorderColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          _validateField('capacity', value);
                          _checkForChanges();
                        },
                      ),
                      const SizedBox(height: 8),

                      // DropdownButtonFormField<int>(
                      //   value: _selectedTeacherId,
                      //   dropdownColor: cardColor,
                      //   style: TextStyle(color: textColor),
                      //   decoration: InputDecoration(
                      //     labelText: 'Professor*',
                      //     labelStyle: TextStyle(color: textColor),
                      //     errorText: _fieldErrors['teacher'],
                      //     errorStyle: TextStyle(color: errorColor),
                      //     border: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //         color: _fieldErrors['teacher'] != null
                      //             ? errorColor
                      //             : borderColor,
                      //       ),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //         color: _fieldErrors['teacher'] != null
                      //             ? errorColor
                      //             : borderColor,
                      //       ),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //         color: _fieldErrors['teacher'] != null
                      //             ? errorColor
                      //             : focusedBorderColor,
                      //         width: 2,
                      //       ),
                      //     ),
                      //     errorBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: errorColor, width: 2),
                      //     ),
                      //     focusedErrorBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: errorColor, width: 2),
                      //     ),
                      //   ),
                      //   items: [
                      //     const DropdownMenuItem(
                      //       value: 0,
                      //       child: Text('Selecione um professor'),
                      //     ),
                      //     ...widget.teachers.map((teacher) {
                      //       return DropdownMenuItem(
                      //         value: teacher.id,
                      //         child: Text(teacher.name),
                      //       );
                      //     }),
                      //   ],
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _selectedTeacherId = value ?? 0;
                      //       _validateField('teacher', _selectedTeacherId.toString());
                      //       _checkForChanges();
                      //     });
                      //   },
                      // ),
                      // const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (widget.isEditing) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _confirmDelete,
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Excluir Aula',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
