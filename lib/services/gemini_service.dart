import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String baseUrl = 'https://gemini-chat-7d5w.onrender.com';

  Future<String> getResponse(String question) async {
    final url = Uri.parse('$baseUrl/gemini/chat/fitness-instructor');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
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
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      return "Erro ao obter resposta da IA.";
    }
  }
}
