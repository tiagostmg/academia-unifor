import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/assets/unifor_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  void _register() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Preencha todos os campos");
    } else if (password != confirmPassword) {
      _showMessage("As senhas não coincidem");
    } else {
      // TODO : Implementar a lógica de registro
      context.go('/home');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
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
                              "E-mail",
                              _emailController,
                              isDark,
                              Icons.email,
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              "Senha",
                              _passwordController,
                              isDark,
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              "Confirmar Senha",
                              _confirmPasswordController,
                              isDark,
                            ),
                            const SizedBox(height: 20),
                            ElasticIn(
                              child: SizedBox(
                                width: double.infinity,
                                child: CustomButton(
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
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
        floatingLabelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        prefixIcon: Icon(icon, color: isDark ? Colors.white : Colors.black),
        filled: true,
        fillColor:
            isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isDark,
  ) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
        floatingLabelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: isDark ? Colors.white : Colors.black,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed:
              () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
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
