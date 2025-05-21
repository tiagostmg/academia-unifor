import 'package:academia_unifor/config/enviroment.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:academia_unifor/theme/theme.dart';
import 'package:academia_unifor/routes/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.init();
  debugPrint("GEMINI_API_URL => ${Environment.geminiApiUrl}");
  debugPrint("API_BASE_URL => ${Environment.apiBaseUrl}");
  runApp(const ProviderScope(child: MainApp()));

  //test
  Users user = Users(
    id: 0,
    name: "novodetestedois tiago",
    email: "tiago@asdoismo.com",
    password: "senha123",
    phone: "",
    address: "",
    birthDate: "2000-01-01",
    avatarUrl: "",
    isAdmin: true,
    workouts: [],
  );
  UserService().postUser(user);
  //TODO testar
  // debugPrint("TESTE DE ADD");
  // try {
  //   Dio(
  //     BaseOptions(
  //       baseUrl: Environment.apiBaseUrl,
  //       connectTimeout: Duration(seconds: 5),
  //       receiveTimeout: Duration(seconds: 5),
  //     ),
  //   ).post(
  //     '/api/User',
  //     data:
  //         "id: 0,
  //         name: novodetestedois tiago,
  //         email: tiago@asdoismo.com,
  //         password: senaha,
  //         phone: ,
  //         address: ,
  //         birthDate: 13/05/2025,
  //         avatarUrl: https://avatars.githubusercontent.com/u/165815345?v=4,
  //         isAdmin: null,
  //         workouts: []",
  //   );
  // } catch (e) {
  //   debugPrint('Erro ao adicionar usuário: $e');
  //   rethrow;
  // }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = brightness == Brightness.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final systemUiStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.colorScheme.primary,
          systemNavigationBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        );

        SystemChrome.setSystemUIOverlayStyle(systemUiStyle);

        return child!;
      },
    );
  }
}
