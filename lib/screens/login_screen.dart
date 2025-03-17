import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
// botão
import 'package:academia_unifor/widgets.dart';
// logo
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/assets/unifor_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
      setState(() => _opacity = 0.0);

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % imagePaths.length;
          _opacity = 1.0;
        });
      });
    });
  }

  void _login() {
    String username = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (username == 'user' && password == 'user') {
      context.go('/home');
    } else if (username == 'admin' && password == 'admin') {
      context.go('/admin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuário ou senha incorretos'),
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
          // Camada de filtro gradiente por cima das imagens
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
          // Conteúdo do login
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
                          SizedBox(height: isKeyboardOpen ? 20 : 30),
                          Visibility(
                            visible: !isKeyboardOpen,
                            child: Text(
                              "Bem-vindo!",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: isKeyboardOpen ? 0 : 10),
                          Visibility(
                            visible: !isKeyboardOpen,
                            child: Text(
                              "Faça login para continuar",
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: isKeyboardOpen ? 0 : 20),
                          TextField(
                            controller: _userController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Usuário',
                              labelStyle: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode
                                      ? Colors.white.withAlpha(30)
                                      : Colors.black.withAlpha(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode
                                      ? Colors.white.withAlpha(30)
                                      : Colors.black.withAlpha(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElasticIn(
                            child: SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: "Entrar",
                                icon: Icons.login,
                                onPressed: _login,
                              ),
                            ),
                          ),
                          SizedBox(height: isKeyboardOpen ? 0 : 15),
                          Visibility(
                            visible: !isKeyboardOpen,
                            child: Center(
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Não tem uma conta? Dirija-se à recepção.",
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
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
    );
  }
}
