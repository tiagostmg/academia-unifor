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
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onPrimary.withAlpha(50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BounceInDown(
                        child: Icon(
                          Icons.lock,
                          size: 60,
                          color: colorScheme.onPrimary.withAlpha(50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _userController,
                        decoration: InputDecoration(
                          labelText: 'Usuário',
                          labelStyle: TextStyle(
                            color: colorScheme.onPrimary.withAlpha(100),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onPrimary.withAlpha(100),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(
                            color: colorScheme.onPrimary.withAlpha(100),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onPrimary.withAlpha(100),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onPrimary,
                            ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
