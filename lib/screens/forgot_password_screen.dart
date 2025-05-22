import 'dart:async';
import 'dart:ui';
import 'package:academia_unifor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/assets/unifor_logo.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/user_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordError;

  final List<String> imagePaths = [
    'assets/001.jpg',
    'assets/002.jpg',
    'assets/003.jpg',
    'assets/004.jpg',
    'assets/005.jpg',
    'assets/006.jpg',
  ];

  int _currentImageIndex = 0;
  double _opacity = 1.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startImageRotation();
  }

  void _startImageRotation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      setState(() => _opacity = 0.0);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % imagePaths.length;
          _opacity = 1.0;
        });
      });
    });
  }

  void _validatePasswords() {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = 'As senhas não coincidem';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  void _login() async {
    _validatePasswords();

    if (_passwordError != null) {
      return;
    }

    String email = _userController.text.trim();
    String password = _passwordController.text.trim();

    try {
      List<Users> usersList = await UserService().loadUsers();

      Users? foundUser = usersList.firstWhereOrNull(
        (user) => user.email == email,
      );

      if (!mounted) return;

      if (foundUser != null && password.isNotEmpty) {
        // Salva o E-mail autenticado no Provider
        foundUser.password = password;
        foundUser.isAdmin = false;

        UserService().putUser(foundUser);
        ref.read(userProvider.notifier).state = foundUser;

        if (foundUser.isAdmin) {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-mail incorreto'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar os dados: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _opacity,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePaths[_currentImageIndex]),
                  fit: BoxFit.cover,
                ),
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
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.black.withAlpha(90)
                                : Colors.white.withAlpha(180),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDarkMode
                                  ? Colors.white.withAlpha(50)
                                  : Colors.black.withAlpha(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDarkMode
                                    ? Colors.black.withAlpha(100)
                                    : Colors.grey.withAlpha(50),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ForgotPasswordHeader(
                            isKeyboardOpen: isKeyboardOpen,
                            isDarkMode: isDarkMode,
                            theme: theme,
                          ),
                          const SizedBox(height: 20),
                          ForgotPasswordFields(
                            userController: _userController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            isPasswordVisible: _isPasswordVisible,
                            isConfirmPasswordVisible: _isConfirmPasswordVisible,
                            passwordError: _passwordError,
                            togglePasswordVisibility: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            toggleConfirmPasswordVisibility: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                            isDarkMode: isDarkMode,
                            onLogin: _login,
                            onPasswordChanged: (_) => _validatePasswords(),
                            onConfirmPasswordChanged:
                                (_) => _validatePasswords(),
                          ),
                          const SizedBox(height: 10),
                        ],
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
}

class ForgotPasswordHeader extends StatelessWidget {
  final bool isKeyboardOpen;
  final bool isDarkMode;
  final ThemeData theme;

  const ForgotPasswordHeader({
    required this.isKeyboardOpen,
    required this.isDarkMode,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => {context.go('/')},
              icon: const Icon(Icons.arrow_back),
            ),
            Center(
              child: SvgPicture.string(
                uniforLogoSVG,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 48),
          ],
        ),
        SizedBox(height: isKeyboardOpen ? 20 : 30),
        if (!isKeyboardOpen)
          Text(
            //TODO
            "Recuperar senha",
            // "Trocar senha",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        if (!isKeyboardOpen) const SizedBox(height: 10),
        if (!isKeyboardOpen)
          Text(
            "Contate a recepção para recuperar sua senha",
            // "Insira seu e-mail e nova senha",
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
      ],
    );
  }
}

class ForgotPasswordFields extends StatelessWidget {
  final TextEditingController userController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? passwordError;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;
  final bool isDarkMode;
  final VoidCallback onLogin;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;

  const ForgotPasswordFields({
    required this.userController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.passwordError,
    required this.togglePasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
    required this.isDarkMode,
    required this.onLogin,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //TODO

        // TextField(
        //   controller: userController,
        //   decoration: InputDecoration(
        //     labelText: 'E-mail',
        //     labelStyle: TextStyle(
        //       color: isDarkMode ? Colors.white : Colors.black,
        //     ),
        //     prefixIcon: Icon(
        //       Icons.person,
        //       color: isDarkMode ? Colors.white : Colors.black,
        //     ),
        //     filled: true,
        //     fillColor:
        //         isDarkMode
        //             ? Colors.white.withAlpha(30)
        //             : Colors.black.withAlpha(20),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide.none,
        //     ),
        //   ),
        //   style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        // ),
        // const SizedBox(height: 15),
        // TextField(
        //   controller: passwordController,
        //   obscureText: !isPasswordVisible,
        //   onChanged: onPasswordChanged,
        //   decoration: InputDecoration(
        //     labelText: 'Nova senha',
        //     labelStyle: TextStyle(
        //       color: isDarkMode ? Colors.white : Colors.black,
        //     ),
        //     prefixIcon: Icon(
        //       Icons.lock,
        //       color: isDarkMode ? Colors.white : Colors.black,
        //     ),
        //     filled: true,
        //     fillColor:
        //         isDarkMode
        //             ? Colors.white.withAlpha(30)
        //             : Colors.black.withAlpha(20),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide.none,
        //     ),
        //     suffixIcon: IconButton(
        //       icon: Icon(
        //         isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        //         color: isDarkMode ? Colors.white : Colors.black,
        //       ),
        //       onPressed: togglePasswordVisibility,
        //     ),
        //   ),
        //   style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        // ),
        // const SizedBox(height: 15),
        // TextField(
        //   controller: confirmPasswordController,
        //   obscureText: !isConfirmPasswordVisible,
        //   onChanged: onConfirmPasswordChanged,
        //   decoration: InputDecoration(
        //     labelText: 'Confirmar senha',
        //     labelStyle: TextStyle(
        //       color: isDarkMode ? Colors.white : Colors.black,
        //     ),
        //     prefixIcon: Icon(
        //       Icons.lock,
        //       color: isDarkMode ? Colors.white : Colors.black,
        //     ),
        //     filled: true,
        //     fillColor:
        //         isDarkMode
        //             ? Colors.white.withAlpha(30)
        //             : Colors.black.withAlpha(20),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide.none,
        //     ),
        //     suffixIcon: IconButton(
        //       icon: Icon(
        //         isConfirmPasswordVisible
        //             ? Icons.visibility
        //             : Icons.visibility_off,
        //         color: isDarkMode ? Colors.white : Colors.black,
        //       ),
        //       onPressed: toggleConfirmPasswordVisibility,
        //     ),
        //     errorText: passwordError,
        //   ),
        //   style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        // ),
        // const SizedBox(height: 10),
        // ElasticIn(
        //   child: SizedBox(
        //     width: double.infinity,
        //     child: CustomButton(
        //       text: "Atualizar senha e entrar",
        //       icon: Icons.login,
        //       onPressed: onLogin,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
