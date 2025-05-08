import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:academia_unifor/services/user_service.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditUserFormState {
  final bool isValid;
  final bool isSaving;
  final bool isAdminEditing;

  EditUserFormState({
    required this.isValid,
    required this.isSaving,
    required this.isAdminEditing,
  });

  EditUserFormState copyWith({
    bool? isValid,
    bool? isSaving,
    bool? isAdminEditing,
  }) {
    return EditUserFormState(
      isValid: isValid ?? this.isValid,
      isSaving: isSaving ?? this.isSaving,
      isAdminEditing: isAdminEditing ?? this.isAdminEditing,
    );
  }
}

class EditUserFormNotifier extends StateNotifier<EditUserFormState> {
  EditUserFormNotifier({required bool isAdminEditing})
    : super(
        EditUserFormState(
          isValid: false,
          isSaving: false,
          isAdminEditing: isAdminEditing,
        ),
      );

  void setValid(bool isValid) {
    if (state.isValid != isValid) {
      state = state.copyWith(isValid: isValid);
    }
  }

  void setSaving(bool isSaving) {
    state = state.copyWith(isSaving: isSaving);
  }
}

final editUserFormProvider = StateNotifierProvider.autoDispose<
  EditUserFormNotifier,
  EditUserFormState
>((ref) {
  final currentUser = ref.watch(userProvider);
  return EditUserFormNotifier(isAdminEditing: currentUser?.isAdmin ?? false);
});

class EditUserScreen extends StatelessWidget {
  final Users user;
  const EditUserScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final GlobalKey<_EditUserFormState> _formKey =
        GlobalKey<_EditUserFormState>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(user.id == 0 ? 'Novo Aluno' : 'Editar Aluno'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final formState = ref.watch(editUserFormProvider);
              return IconButton(
                icon:
                    formState.isSaving
                        ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                onPressed:
                    formState.isValid && !formState.isSaving
                        ? () {
                          ref
                              .read(editUserFormProvider.notifier)
                              .setSaving(true);
                          _formKey.currentState?._saveChanges();
                        }
                        : null,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: EditUserForm(key: _formKey, user: user),
        ),
      ),
    );
  }
}

class EditUserForm extends ConsumerStatefulWidget {
  final Users user;
  const EditUserForm({super.key, required this.user});

  @override
  ConsumerState<EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends ConsumerState<EditUserForm> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthDateController;
  late String _avatarUrl;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _emailController = TextEditingController(text: u.email);
    _phoneController = TextEditingController(text: u.phone);
    _addressController = TextEditingController(text: u.address);
    _birthDateController = TextEditingController(
      text:
          u.birthDate != null
              ? "${u.birthDate!.day.toString().padLeft(2, '0')}/${u.birthDate!.month.toString().padLeft(2, '0')}/${u.birthDate!.year}"
              : '',
    );
    _avatarUrl = u.avatarUrl;
    _isAdmin = u.isAdmin;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormValidity();
    });
  }

  void _checkFormValidity() {
    final isValid =
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty;

    ref.read(editUserFormProvider.notifier).setValid(isValid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final formState = ref.read(editUserFormProvider);
    if (!formState.isValid) return;

    ref.read(editUserFormProvider.notifier).setSaving(true);

    try {
      final updatedUser = Users(
        id: widget.user.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        birthDate:
            _birthDateController.text.isNotEmpty
                ? DateTime.tryParse(
                  _birthDateController.text.split('/').reversed.join('-'),
                )
                : null,
        avatarUrl: _avatarUrl,
        isAdmin: _isAdmin,
        password: widget.user.password,
        workouts: widget.user.workouts,
      );

      final savedUser =
          widget.user.id == 0
              ? await UserService().postUser(updatedUser)
              : await UserService().putUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aluno salvo com sucesso!")),
        );
        Navigator.pop(context, savedUser); // Retorna o usuário salvo
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar aluno: ${e.toString()}")),
        );
        ref.read(editUserFormProvider.notifier).setSaving(false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.user.birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      _checkFormValidity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(editUserFormProvider);

    return Column(
      children: [
        const SizedBox(height: 20),
        ProfileAvatar(
          avatarUrl: _avatarUrl,
          onAvatarChanged: (newUrl) {
            setState(() {
              _avatarUrl = newUrl;
            });
            _checkFormValidity();
          },
          isEditing: true,
        ),
        const SizedBox(height: 30),
        _buildEditableField(
          context,
          title: "Nome",
          controller: _nameController,
          onChanged: (_) => _checkFormValidity(),
        ),
        _buildEditableField(
          context,
          title: "Email",
          controller: _emailController,
          onChanged: (_) => _checkFormValidity(),
        ),
        _buildEditableField(
          context,
          title: "Telefone",
          controller: _phoneController,
          onChanged: (_) => _checkFormValidity(),
        ),
        _buildEditableField(
          context,
          title: "Logradouro",
          controller: _addressController,
          onChanged: (_) => _checkFormValidity(),
        ),
        _buildDateField(context),
        if (formState.isAdminEditing) ...[
          const SizedBox(height: 16),
          _buildAdminSwitch(),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildEditableField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    void Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: theme.colorScheme.primary.withOpacity(0.05),
          labelStyle: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Data de Nascimento",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: theme.colorScheme.primary.withOpacity(0.05),
          labelStyle: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
            onPressed: () => _selectDate(context),
          ),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildAdminSwitch() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privilégios de Administrador',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isAdmin
                        ? 'Este usuário tem acesso total ao sistema'
                        : 'Este usuário tem acesso limitado',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isAdmin,
              onChanged: (value) {
                setState(() {
                  _isAdmin = value;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
