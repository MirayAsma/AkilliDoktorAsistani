import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIAnalysisService {
  final String apiKey;
  final String apiUrl;

  OpenAIAnalysisService({required this.apiKey, this.apiUrl = 'https://api.openai.com/v1/chat/completions'});

  Future<String> analyze(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content']?.toString().trim() ?? '';
    } else {
      throw Exception('OpenAI API hatası: ${response.body}');
    }
  }
}
