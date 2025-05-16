import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get geminiApiUrl => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
}
