import 'package:flutter/material.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models.dart';
import 'package:go_router/go_router.dart';

class ClassAdminScreen extends StatefulWidget {
  const ClassAdminScreen({super.key});

  @override
  State<ClassAdminScreen> createState() => _ClassAdminScreenState();
}

class _ClassAdminScreenState extends State<ClassAdminScreen> {
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
                          studentIds: [0],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ListView.separated(
        itemCount: classes.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final classItem = classes[index];
          return ListTile(
            leading: const Icon(Icons.class_),
            title: Text(
              '${classItem.name} [${classItem.studentIds.length}/${classItem.capacity}]',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data: ${classItem.date} - ${formatarHora(classItem.time)}',
                ),
                Text('Duração: ${formatarHora(classItem.duration)}'),
              ],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EditClassScreen(
                        classItem: classItem,
                        isEditing: true,
                      ),
                ),
              );
              if (result != null && result is Classes) {
                await onUpdate(result);
              }
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(classItem.id),
            ),
          );
        },
      ),
    );
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
