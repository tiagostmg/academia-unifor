import 'dart:async';
import 'package:academia_unifor/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          Center(
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bem-vindo!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Faça login para continuar"),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _userController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor:
                                isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor:
                                isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
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
                        const SizedBox(height: 15),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Não tem uma conta? Dirija-se à recepção.",
                              style: TextStyle(color: Colors.blue),
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
        ],
      ),
    );
  }
}
