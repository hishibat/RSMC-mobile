import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  final String apiKey;
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';

  ClaudeService({required this.apiKey});

  Future<String> getExplanation({
    required String transcription,
    required String latestSegment,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content': '''以下はリアルタイム音声文字起こしの内容です。最新のセグメントについて、文脈を踏まえた簡潔な解説を日本語で提供してください。

【これまでの文字起こし全体】
$transcription

【最新セグメント】
$latestSegment

専門用語の説明や、話の要点の整理を簡潔にお願いします。''',
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final content = json['content'] as List<dynamic>;
      if (content.isNotEmpty) {
        return content[0]['text'] as String;
      }
      return '';
    } else {
      throw Exception(
        'Claude API error: ${response.statusCode} ${response.body}',
      );
    }
  }
}
