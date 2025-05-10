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
  final Map<String, String?> fieldErrors;

  EditUserFormState({
    required this.isValid,
    required this.isSaving,
    required this.isAdminEditing,
    this.fieldErrors = const {},
  });

  EditUserFormState copyWith({
    bool? isValid,
    bool? isSaving,
    bool? isAdminEditing,
    Map<String, String?>? fieldErrors,
  }) {
    return EditUserFormState(
      isValid: isValid ?? this.isValid,
      isSaving: isSaving ?? this.isSaving,
      isAdminEditing: isAdminEditing ?? this.isAdminEditing,
      fieldErrors: fieldErrors ?? this.fieldErrors,
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

  void setFieldError(String fieldName, String? error) {
    final newErrors = Map<String, String?>.from(state.fieldErrors);
    newErrors[fieldName] = error;
    state = state.copyWith(fieldErrors: newErrors);
  }

  void clearFieldErrors() {
    state = state.copyWith(fieldErrors: {});
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
          onPressed: () async {
            if (_formKey.currentState?._hasUnsavedChanges() ?? false) {
              final shouldExit = await confirmationDialog(
                context,
                title: 'Alterações não salvas',
                message:
                    'Você tem alterações não salvas. Deseja realmente sair?',
              );

              if (shouldExit == true && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            } else {
              Navigator.pop(context);
            }
          },
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
  // late ValidatorUser _validator;

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
    // _validator = ValidatorUser();
  }

  bool _hasUnsavedChanges() {
    return _nameController.text != widget.user.name ||
        _emailController.text != widget.user.email ||
        _phoneController.text != widget.user.phone ||
        _addressController.text != widget.user.address ||
        _birthDateController.text !=
            (widget.user.birthDate != null
                ? "${widget.user.birthDate!.day.toString().padLeft(2, '0')}/${widget.user.birthDate!.month.toString().padLeft(2, '0')}/${widget.user.birthDate!.year}"
                : '') ||
        _avatarUrl != widget.user.avatarUrl ||
        _isAdmin != widget.user.isAdmin;
  }

  void _validateField(String fieldName, String value) {
    String? error;

    switch (fieldName) {
      case 'name':
        if (!ValidatorUser.validateName(value)) {
          error =
              value.isEmpty
                  ? 'O nome é obrigatório'
                  : 'O nome deve ter entre 3 e 50 caracteres e apenas letras';
        }
        break;
      case 'email':
        if (!ValidatorUser.validateEmail(value)) {
          error =
              value.isEmpty
                  ? 'O email é obrigatório'
                  : 'Email inválido. Use o formato exemplo@dominio.com';
        }
        break;
      case 'phone':
        if (!ValidatorUser.validatePhone(value)) {
          error =
              value.isEmpty
                  ? 'O telefone é obrigatório'
                  : 'Telefone inválido. Use (DDD) 9XXXX-XXXX ou (DDD) XXXX-XXXX';
        }
        break;
      case 'address':
        if (!ValidatorUser.validateAddress(value)) {
          error =
              value.isEmpty
                  ? 'O endereço é obrigatório'
                  : 'O endereço deve ter pelo menos 5 caracteres';
        }
        break;
      case 'birthDate':
        if (!ValidatorUser.validateBirthDate(
          _birthDateController.text.isNotEmpty
              ? DateTime.tryParse(
                _birthDateController.text.split('/').reversed.join('-'),
              )
              : null,
        )) {
          error =
              'Data de nascimento inválida. Você deve ter entre 12 e 120 anos';
        }
        break;
      case 'avatarUrl':
        if (!ValidatorUser.validateImageUrl(value)) {
          error = 'URL da imagem inválida (use .jpg, .jpeg, .png ou .gif)';
        }
        break;
    }

    ref.read(editUserFormProvider.notifier).setFieldError(fieldName, error);
    _checkFormValidity();
  }

  void _checkFormValidity() {
    final isValid =
        ValidatorUser.validateName(_nameController.text) &&
        ValidatorUser.validateEmail(_emailController.text) &&
        ValidatorUser.validateBirthDate(
          _birthDateController.text.isNotEmpty
              ? DateTime.tryParse(
                _birthDateController.text.split('/').reversed.join('-'),
              )
              : null,
        );

    ref.read(editUserFormProvider.notifier).setValid(isValid);
  }

  bool _validateAllFields() {
    ref.read(editUserFormProvider.notifier).clearFieldErrors();

    _validateField('name', _nameController.text);
    _validateField('email', _emailController.text);
    _validateField('phone', _phoneController.text);
    _validateField('address', _addressController.text);
    _validateField('birthDate', _birthDateController.text);
    _validateField('avatarUrl', _avatarUrl);

    final formState = ref.read(editUserFormProvider);
    return !formState.fieldErrors.values.any((error) => error != null);
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

    // Validate all fields
    if (!_validateAllFields()) {
      ref.read(editUserFormProvider.notifier).setSaving(false);
      return;
    }

    // Confirmation dialog
    final confirmSave = await confirmationDialog(
      context,
      title: 'Confirmar alterações',
      message: 'Tem certeza que deseja salvar as alterações deste usuário?',
    );

    if (confirmSave != true) {
      ref.read(editUserFormProvider.notifier).setSaving(false);
      return;
    }

    // Admin privileges confirmation
    if (_isAdmin != widget.user.isAdmin) {
      final adminConfirm = await confirmationDialog(
        context,
        title:
            _isAdmin
                ? 'Conceder privilégios de admin'
                : 'Remover privilégios de admin',
        message:
            _isAdmin
                ? 'Tem certeza que deseja tornar este usuário um administrador?'
                : 'Tem certeza que deseja remover os privilégios de administrador?',
      );

      if (adminConfirm != true) {
        ref.read(editUserFormProvider.notifier).setSaving(false);
        return;
      }
    }

    try {
      final updatedUser = Users(
        id: widget.user.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        birthDate:
            _birthDateController.text.isNotEmpty
                ? DateTime.tryParse(
                  _birthDateController.text.split('/').reversed.join('-'),
                )
                : null,
        avatarUrl: _avatarUrl.trim(),
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
        Navigator.pop(context, savedUser);
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
      _validateField('birthDate', _birthDateController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(editUserFormProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        ProfileAvatar(
          avatarUrl: _avatarUrl,
          onAvatarChanged: (newUrl) {
            setState(() {
              _avatarUrl = newUrl;
            });
            _validateField('avatarUrl', newUrl);
          },
          isEditing: true,
        ),
        const SizedBox(height: 30),
        _buildEditableField(
          context,
          title: "Nome*",
          controller: _nameController,
          fieldName: 'name',
        ),
        _buildEditableField(
          context,
          title: "Email*",
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          fieldName: 'email',
        ),
        _buildEditableField(
          context,
          title: "Telefone",
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          fieldName: 'phone',
        ),
        _buildEditableField(
          context,
          title: "Logradouro",
          controller: _addressController,
          fieldName: 'address',
        ),
        _buildDateField(context),
        if (formState.isAdminEditing) ...[
          const SizedBox(height: 16),
          _buildAdminSwitch(),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '* Campos obrigatórios',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String fieldName,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final errorText = ref.watch(editUserFormProvider).fieldErrors[fieldName];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        onChanged: (value) => _validateField(fieldName, value),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: title,
          errorText: errorText,
          errorStyle: TextStyle(color: theme.colorScheme.error),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor:
              errorText != null
                  ? theme.colorScheme.errorContainer.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.05),
          labelStyle: TextStyle(
            color:
                errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = ref.watch(editUserFormProvider).fieldErrors['birthDate'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Data de Nascimento*",
          errorText: errorText,
          errorStyle: TextStyle(color: theme.colorScheme.error),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor:
              errorText != null
                  ? theme.colorScheme.errorContainer.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.05),
          labelStyle: TextStyle(
            color:
                errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary.withOpacity(0.8),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.calendar_today,
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
            ),
            onPressed: () => _selectDate(context),
          ),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildAdminSwitch() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privilégios de Administrador',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
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
              onChanged: (value) async {
                if (value && !_isAdmin) {
                  final confirm = await confirmationDialog(
                    context,
                    title: 'Conceder privilégios de admin',
                    message:
                        'Tem certeza que deseja tornar este usuário um administrador?',
                  );
                  if (confirm != true) return;
                } else if (!value && _isAdmin) {
                  final confirm = await confirmationDialog(
                    context,
                    title: 'Remover privilégios de admin',
                    message:
                        'Tem certeza que deseja remover os privilégios de administrador?',
                  );
                  if (confirm != true) return;
                }
                setState(() => _isAdmin = value);
              },
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
