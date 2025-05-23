import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/assets/unifor_logo.dart';
import 'package:academia_unifor/services/user_service.dart';
import 'package:academia_unifor/services/user_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Estados de erro para cada campo
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validações síncronas primeiro
    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'O nome é obrigatório');
      hasError = true;
    } else if (!ValidatorUser.validateName(name)) {
      setState(() => _nameError = 'O nome deve ter entre 3 e 50 letras');
      hasError = true;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'O email é obrigatório');
      hasError = true;
    } else if (!ValidatorUser.validateEmail(email)) {
      setState(
        () => _emailError = 'Email inválido. Use o formato exemplo@dominio.com',
      );
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'A senha é obrigatória');
      hasError = true;
    } else if (!ValidatorUser.validatePassword(password)) {
      setState(
        () => _passwordError = 'A senha deve ter entre 4 e 20 caracteres',
      );
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Confirme sua senha');
      hasError = true;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'As senhas não coincidem');
      hasError = true;
    }

    if (hasError) {
      return;
    }

    // Validação assíncrona do email
    setState(() {
      _isLoading = true;
    });

    try {
      // Verifica se o email já está cadastrado
      final isEmailRegistered = await UserService().isEmailRegistered(email);
      if (isEmailRegistered) {
        setState(() {
          _emailError = 'Email já cadastrado';
          _isLoading = false;
        });
        return;
      }

      // Se todas as validações passarem, prossegue com o cadastro
      final newUser = Users(
        id: 0,
        workouts: [],
        name: name,
        phone: '',
        address: '',
        birthDate: null,
        avatarUrl: '',
        isAdmin: false,
        email: email,
        password: password,
      );

      final createdUser = await UserService().postUser(newUser);
      ref.read(userProvider.notifier).state = createdUser;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Cadastro realizado com sucesso!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao cadastrar: ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/001.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withAlpha(100),
                  Colors.purple.withAlpha(100),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.black.withAlpha(90)
                                : Colors.white.withAlpha(180),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.white.withAlpha(50)
                                  : Colors.black.withAlpha(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withAlpha(100)
                                    : Colors.grey.withAlpha(50),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.string(
                              uniforLogoSVG,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.onPrimary,
                                BlendMode.srcIn,
                              ),
                              height: 60,
                            ),
                            const SizedBox(height: 20),
                            if (!isKeyboardOpen)
                              Text(
                                "Criar nova conta",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              "Nome Completo",
                              _nameController,
                              isDark,
                              Icons.person,
                              errorText: _nameError,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "E-mail",
                              _emailController,
                              isDark,
                              Icons.email,
                              errorText: _emailError,
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              "Senha",
                              _passwordController,
                              isDark,
                              errorText: _passwordError,
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              "Confirmar Senha",
                              _confirmPasswordController,
                              isDark,
                              errorText: _confirmPasswordError,
                            ),
                            const SizedBox(height: 20),
                            ElasticIn(
                              child: SizedBox(
                                width: double.infinity,
                                child:
                                    _isLoading
                                        ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : CustomButton(
                                          text: "Cadastrar",
                                          icon: Icons.app_registration,
                                          onPressed: _register,
                                        ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => context.go('/'),
                              style: _linkButtonStyle(isDark),
                              child: const Text(
                                "Já tem uma conta? Entrar",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isDark,
    IconData icon, {
    String? errorText,
  }) {
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              hasError
                  ? Theme.of(context).colorScheme.error
                  : (isDark ? Colors.white : Colors.black),
        ),
        floatingLabelStyle: TextStyle(
          color:
              hasError
                  ? Theme.of(context).colorScheme.error
                  : (isDark ? Colors.white : Colors.black),
        ),
        prefixIcon: Icon(
          icon,
          color:
              hasError
                  ? Theme.of(context).colorScheme.error
                  : (isDark ? Colors.white : Colors.black),
        ),
        filled: true,
        fillColor:
            hasError
                ? Theme.of(context).colorScheme.errorContainer.withAlpha(26)
                : (isDark
                    ? Colors.white.withAlpha(30)
                    : Colors.black.withAlpha(20)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                hasError
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                hasError
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                hasError
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
            width: 2,
          ),
        ),
        errorText: errorText,
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isDark, {
    String? errorText,
  }) {
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              hasError
                  ? Theme.of(context).colorScheme.error
                  : (isDark ? Colors.white : Colors.black),
        ),
        floatingLabelStyle: TextStyle(
          color:
              hasError
                  ? Theme.of(context).colorScheme.error
                  : (isDark ? Colors.white : Colors.black),
        ),
        prefixIcon: Icon(
          Icons.lock,
          color:
              hasError
                  ? Theme.of(context).colorScheme.error
                  : (isDark ? Colors.white : Colors.black),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color:
                hasError
                    ? Theme.of(context).colorScheme.error
                    : (isDark ? Colors.white : Colors.black),
          ),
          onPressed:
              () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor:
            hasError
                ? Theme.of(context).colorScheme.errorContainer.withAlpha(26)
                : (isDark
                    ? Colors.white.withAlpha(30)
                    : Colors.black.withAlpha(20)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                hasError
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                hasError
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                hasError
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
            width: 2,
          ),
        ),
        errorText: errorText,
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    );
  }
}

ButtonStyle _linkButtonStyle(bool isDarkMode) {
  return ButtonStyle(
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.blue;
      }
      return isDarkMode ? Colors.white : Colors.black;
    }),
    padding: WidgetStateProperty.all(EdgeInsets.zero),
    minimumSize: WidgetStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
