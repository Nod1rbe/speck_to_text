import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class AiService {
  final String openAiApiKey;
  final String elevenLabsApiKey;

  static const String _openAiBase = 'https://api.openai.com/v1';
  static const String _elevenLabsBase = 'https://api.elevenlabs.io/v1';

  AiService({required this.openAiApiKey, required this.elevenLabsApiKey});

  // ─── Matn ichidan kalit so'z qidirish (GPT-4o) ───────────────────────────
  Future<String?> searchInText(String text, String keyword) async {
    final response = await http.post(
      Uri.parse('$_openAiBase/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content':
            "Siz o'zbek tilida javob beradigan AI yordamchisiz. Barcha javoblarni faqat o'zbek tilida bering.",
          },
          {
            'role': 'user',
            'content':
            'Quyidagi matnda "$keyword" so\'zi yoki iborasini toping. '
                "Uning qator raqamini, atrofidagi jumlani (kontekstini) ko'rsating. "
                "Topilmasa, \"Topilmadi\" deng.\n\nMatn:\n\n$text",
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String?;
    }
    throw Exception('OpenAI xatosi: ${response.statusCode} ${response.body}');
  }

  // ─── Audio/Video → ElevenLabs Scribe v2 (o'zbek tili) ───────────────────
  Future<Map<String, dynamic>?> searchInMedia(File file, String keyword) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_elevenLabsBase/speech-to-text'),
    );

    request.headers['xi-api-key'] = elevenLabsApiKey;
    request.fields['model_id'] = 'scribe_v2';
    request.fields['language_code'] = 'uzb'; // O'zbek tili ISO-639-3
    request.fields['timestamps_granularity'] = 'word';
    request.fields['tag_audio_events'] = 'false';

    final ext = p.extension(file.path).toLowerCase().replaceFirst('.', '');
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType.parse(_getMimeType(ext)),
    ));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('ElevenLabs xatosi: ${streamed.statusCode} $body');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final fullText = data['text'] as String? ?? '';
    final words = data['words'] as List<dynamic>?;

    if (words == null || words.isEmpty) {
      return {'timestamp': null, 'text': null, 'fullTranscript': fullText};
    }

    final kw = keyword.toLowerCase().trim();
    for (final w in words) {
      if ((w['type'] as String?) != 'word') continue;
      final wordText = (w['text'] as String? ?? '').toLowerCase().trim();
      if (wordText == kw || wordText.contains(kw)) {
        final start = (w['start'] as num).toDouble();
        return {
          'timestamp': start,
          'matchedWord': w['text'],
          'fullTranscript': fullText,
        };
      }
    }

    final gptResult = await searchInText(fullText, keyword);
    return {
      'timestamp': null,
      'text': gptResult,
      'fullTranscript': fullText,
    };
  }

  String _getMimeType(String ext) {
    switch (ext) {
      case 'mp3':  return 'audio/mpeg';
      case 'mp4':  return 'video/mp4';
      case 'wav':  return 'audio/wav';
      case 'm4a':  return 'audio/mp4';
      case 'ogg':  return 'audio/ogg';
      case 'webm': return 'video/webm';
      case 'mov':  return 'video/quicktime';
      default:     return 'application/octet-stream';
    }
  }
}