import 'dart:convert';
import 'package:academia_unifor/config/enviroment.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String baseUrl = Environment.geminiApiUrl;

  Future<String> getResponse(String question) async {
    final response = await http.post(
      Uri.parse("$baseUrl/gemini/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": question},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      return "Erro ao obter resposta da IA (${response.statusCode}): ${response.body}";
    }
  }
}
