import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/assets/unifor_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _isPasswordVisible = false;

  void _register() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final phone = toNumericString(_phoneController.text.trim());
    final location = _locationController.text.trim();
    final birthDate = _birthDateController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        location.isEmpty ||
        birthDate.isEmpty) {
      _showMessage("Preencha todos os campos");
    } else if (password != confirmPassword) {
      _showMessage("As senhas não coincidem");
    } else {
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                        constraints: const BoxConstraints(maxHeight: 600),
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
                        padding: const EdgeInsets.all(24),
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
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            const SizedBox(height: 20),
                            TabBar(
                              labelColor:
                                  isDarkMode ? Colors.white : Colors.black,
                              tabs: const [
                                Tab(text: 'Pessoal'),
                                Tab(text: 'Endereço'),
                                Tab(text: 'Senha'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: TabBarView(
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  _buildTabPessoal(isDarkMode),
                                  _buildTabEndereco(isDarkMode),
                                  _buildTabSenha(isDarkMode),
                                ],
                              ),
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
                              style: _linkButtonStyle(isDarkMode),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTabPessoal(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField("Nome", _nameController, isDark, Icons.person),
          const SizedBox(height: 15),
          _buildTextField("E-mail", _emailController, isDark, Icons.email),
          const SizedBox(height: 15),
          _buildPhoneField(isDark),
        ],
      ),
    );
  }

  Widget _buildTabEndereco(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField(
            "Localização",
            _locationController,
            isDark,
            Icons.location_on,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            "Data de Nascimento (dd/mm/aaaa)",
            _birthDateController,
            isDark,
            Icons.cake,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSenha(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPasswordField("Senha", _passwordController),
          const SizedBox(height: 15),
          _buildPasswordField("Confirmar Senha", _confirmPasswordController),
        ],
      ),
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneInputFormatter()],
      decoration: InputDecoration(
        labelText: "Telefone",
        prefixIcon: Icon(
          Icons.phone,
          color: isDark ? Colors.white : Colors.black,
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

  Widget _buildPasswordField(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
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
