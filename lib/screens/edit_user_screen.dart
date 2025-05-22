import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:academia_unifor/services/user_service.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

class EditUserFormState {
  final bool isValid;
  final bool isAdminEditing;
  final Map<String, String?> fieldErrors;

  EditUserFormState({
    required this.isValid,
    required this.isAdminEditing,
    this.fieldErrors = const {},
  });

  EditUserFormState copyWith({
    bool? isValid,
    bool? isAdminEditing,
    Map<String, String?>? fieldErrors,
  }) {
    return EditUserFormState(
      isValid: isValid ?? this.isValid,
      isAdminEditing: isAdminEditing ?? this.isAdminEditing,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class EditUserFormNotifier extends StateNotifier<EditUserFormState> {
  EditUserFormNotifier({required bool isAdminEditing})
    : super(EditUserFormState(isValid: false, isAdminEditing: isAdminEditing));

  void setValid(bool isValid) {
    if (state.isValid != isValid) {
      state = state.copyWith(isValid: isValid);
    }
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
    final _formKey = GlobalKey<_EditUserFormState>();

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
              ref.watch(editUserFormProvider);
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _formKey.currentState?._saveChanges(),
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
  late TextEditingController _passwordController;
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
    _passwordController = TextEditingController(text: u.password);
    _phoneController = TextEditingController(text: u.phone);
    _addressController = TextEditingController(text: u.address);
    _birthDateController = TextEditingController(text: u.birthDate ?? '');
    _avatarUrl = u.avatarUrl;
    _isAdmin = u.isAdmin;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormValidity();
    });
  }

  bool _hasUnsavedChanges() {
    return _nameController.text != widget.user.name ||
        _emailController.text != widget.user.email ||
        _passwordController.text != widget.user.password ||
        _phoneController.text != widget.user.phone ||
        _addressController.text != widget.user.address ||
        _birthDateController.text != (widget.user.birthDate ?? '') ||
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
        debugPrint('Erro: $error');
        break;
      case 'email':
        if (!ValidatorUser.validateEmail(value)) {
          error =
              value.isEmpty
                  ? 'O email é obrigatório'
                  : 'Email inválido. Use o formato exemplo@dominio.com';
        }
        debugPrint('Erro: $error');
        break;
      case 'password':
        if (!ValidatorUser.validatePassword(value)) {
          error =
              value.isEmpty
                  ? 'A senha é obrigatória'
                  : 'A senha deve ter entre 4 e 20 caracteres';
        }
        debugPrint('Erro: $error');
        break;
      case 'phone':
        if (!ValidatorUser.validatePhone(value)) {
          error =
              value.isEmpty
                  ? 'O telefone é obrigatório'
                  : 'Telefone inválido. Use (DDD) 9XXXX-XXXX ou (DDD) XXXX-XXXX';
        }
        debugPrint('Erro: $error');
        break;
      case 'address':
        if (!ValidatorUser.validateAddress(value)) {
          error =
              value.isEmpty
                  ? 'O endereço é obrigatório'
                  : 'O endereço deve ter pelo menos 5 caracteres';
        }
        debugPrint('Erro: $error');
        break;
      case 'birthDate':
        if (!ValidatorUser.validateBirthDate(value)) {
          error =
              'Data de nascimento inválida. Você deve ter entre 12 e 120 anos';
        }
        debugPrint('Erro: $error');
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
        ValidatorUser.validatePassword(_passwordController.text) &&
        ValidatorUser.validateBirthDate(_birthDateController.text);

    debugPrint('isValid: $isValid');
    ref.read(editUserFormProvider.notifier).setValid(isValid);
  }

  bool _validateAllFields() {
    ref.read(editUserFormProvider.notifier).clearFieldErrors();

    _validateField('name', _nameController.text);
    _validateField('email', _emailController.text);
    _validateField('password', _passwordController.text);
    _validateField('phone', _phoneController.text);
    _validateField('address', _addressController.text);
    _validateField('birthDate', _birthDateController.text);
    // _validateField('avatarUrl', _avatarUrl);

    final formState = ref.read(editUserFormProvider);

    // Debug: imprima todos os erros
    formState.fieldErrors.forEach((key, value) {
      if (value != null) debugPrint('Campo com erro: $key - $value');
    });

    return !formState.fieldErrors.values.any((error) => error != null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    debugPrint(
      "_validateAllFields().toString() ${_validateAllFields().toString()}",
    );
    if (!_validateAllFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corrija os erros antes de salvar')),
      );
      return;
    }

    final confirmSave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar alterações'),
            content: const Text(
              'Tem certeza que deseja salvar as alterações deste usuário?',
            ),
            actions: [
              //TODO ajeitar as cores
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salvar'),
              ),
            ],
          ),
    );

    if (confirmSave != true) return;

    if (_isAdmin != widget.user.isAdmin) {
      final adminConfirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                _isAdmin
                    ? 'Conceder privilégios de admin'
                    : 'Remover privilégios de admin',
              ),
              content: Text(
                _isAdmin
                    ? 'Tem certeza que deseja tornar este usuário um administrador?'
                    : 'Tem certeza que deseja remover os privilégios de administrador?',
              ),
              actions: [
                //TODO ajeitar as cores
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
      );

      if (adminConfirm != true) return;
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
                ? _birthDateController.text
                : null,
        avatarUrl: _avatarUrl.trim().isEmpty ? '' : _avatarUrl.trim(),
        isAdmin: _isAdmin,
        password: _passwordController.text.trim(),
        workouts: widget.user.workouts,
      );
      debugPrint("updatedUser: ${updatedUser.toJson()}");

      debugPrint("widget.user: ${widget.user.toJson()}");

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
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Determinar a data inicial para o seletor
    DateTime initialDate;
    if (widget.user.birthDate != null && widget.user.birthDate!.isNotEmpty) {
      try {
        // Tenta converter a string para DateTime
        if (widget.user.birthDate!.contains('/')) {
          final parts = widget.user.birthDate!.split('/');
          initialDate = DateTime(
            int.parse(parts[2]), // ano
            int.parse(parts[1]), // mês
            int.parse(parts[0]), // dia
          );
        } else if (widget.user.birthDate!.contains('-')) {
          initialDate = DateTime.parse(widget.user.birthDate!);
        } else {
          initialDate = DateTime.now();
        }
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: Colors.blue, // Cabeçalho e botão ativo
              onPrimary: colorScheme.onPrimary, // Texto sobre o cabeçalho
              surface: colorScheme.surface, // Fundo do calendário
              onSurface: colorScheme.onSurface, // Texto das datas
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    colorScheme.onPrimary, // Botões "OK" e "Cancelar"
              ),
            ),
            dialogTheme: DialogThemeData(backgroundColor: colorScheme.surface),
          ),
          child: child!,
        );
      },
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

        _buildPasswordField(
          context,
          title: "Senha*",
          controller: _passwordController,
          fieldName: 'password',
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
          _buildAdminSwitch(),
          const SizedBox(height: 16),
        ],
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

    // Definindo variáveis de cor dentro da função
    final borderColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.primary.withAlpha(128);
    final enabledBorderColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.primary.withAlpha(77);
    final focusedBorderColor =
        errorText != null ? theme.colorScheme.error : theme.colorScheme.primary;
    final fillColor =
        errorText != null
            ? theme.colorScheme.errorContainer.withAlpha(26)
            : theme.colorScheme.primary;
    final labelColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.onPrimary;
    final textColor = theme.colorScheme.onPrimary;
    final cursorColor = theme.colorScheme.onPrimary;
    final errorTextColor = theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        onChanged: (value) => _validateField(fieldName, value),
        keyboardType: keyboardType,
        cursorColor: cursorColor,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: title,
          errorText: errorText,
          errorStyle: TextStyle(color: errorTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusedBorderColor, width: 2),
          ),
          filled: true,
          fillColor: fillColor,
          labelStyle: TextStyle(color: labelColor),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String fieldName,
  }) {
    final theme = Theme.of(context);
    final errorText = ref.watch(editUserFormProvider).fieldErrors[fieldName];
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    // Cores e estilos
    final borderColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.primary.withAlpha(128);
    final enabledBorderColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.primary.withAlpha(77);
    final focusedBorderColor =
        errorText != null ? theme.colorScheme.error : theme.colorScheme.primary;
    final fillColor =
        errorText != null
            ? theme.colorScheme.errorContainer.withAlpha(26)
            : theme.colorScheme.primary;
    final labelColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.onPrimary;
    final textColor = theme.colorScheme.onPrimary;
    final cursorColor = theme.colorScheme.onPrimary;
    final errorTextColor = theme.colorScheme.error;
    final iconColor = theme.colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        onChanged: (value) => _validateField(fieldName, value),
        cursorColor: cursorColor,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: title,
          errorText: errorText,
          errorStyle: TextStyle(color: errorTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusedBorderColor, width: 2),
          ),
          filled: true,
          fillColor: fillColor,
          labelStyle: TextStyle(color: labelColor),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: iconColor,
            ),
            onPressed: () {
              ref.read(passwordVisibilityProvider.notifier).state =
                  !isPasswordVisible;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = ref.watch(editUserFormProvider).fieldErrors['birthDate'];

    // Definindo variáveis de cor dentro da função
    final borderColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.primary.withAlpha(128);
    final enabledBorderColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.primary.withAlpha(77);
    final focusedBorderColor =
        errorText != null ? theme.colorScheme.error : theme.colorScheme.primary;
    final fillColor =
        errorText != null
            ? theme.colorScheme.errorContainer.withAlpha(26)
            : theme.colorScheme.primary;
    final labelColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.onPrimary;
    final textColor = theme.colorScheme.onPrimary;
    final errorTextColor = theme.colorScheme.error;
    final iconColor =
        errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: "Data de Nascimento*",
          errorText: errorText,
          errorStyle: TextStyle(color: errorTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusedBorderColor, width: 2),
          ),
          filled: true,
          fillColor: fillColor,
          labelStyle: TextStyle(color: labelColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: iconColor),
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
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 24,
              color: theme.colorScheme.onPrimary,
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
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isAdmin
                        ? 'Este usuário tem acesso total ao sistema'
                        : 'Este usuário tem acesso limitado',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 14,
                    ),
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
              activeColor: theme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
