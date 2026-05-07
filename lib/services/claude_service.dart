import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/extracted_contact.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ClaudeService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';
  static const _maxTokens = 256;
  static const _timeout = Duration(seconds: 30);

  static const _prompt =
      'Extract contact information from this image.\n'
      'Respond ONLY with a JSON object — no markdown, no explanation.\n'
      'Use exactly these keys: name, phone, email, address.\n'
      'Omit a key entirely if that information is not visible.\n'
      'Example: {"name":"Jane Smith","phone":"+1 555-234-5678","email":"jane@example.com"}';

  static Future<ExtractedContact> extractContact(
    Uint8List imageBytes,
    String apiKey,
  ) async {
    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      'model': _model,
      'max_tokens': _maxTokens,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': 'image/jpeg',
                'data': base64Image,
              },
            },
            {
              'type': 'text',
              'text': _prompt,
            },
          ],
        },
      ],
    });

    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'x-api-key': apiKey,
              'anthropic-version': '2023-06-01',
              'content-type': 'application/json',
            },
            body: body,
          )
          .timeout(_timeout);
    } on Exception catch (e) {
      throw ApiException('Network error: $e');
    }

    if (response.statusCode == 401) {
      throw ApiException('Invalid API key. Check your key in Settings.');
    }
    if (response.statusCode != 200) {
      throw ApiException('API error ${response.statusCode}. Please try again.');
    }

    final Map<String, dynamic> outer;
    try {
      outer = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException('Unexpected response from Claude. Please try again.');
    }

    final text =
        ((outer['content'] as List?)?.firstOrNull
                as Map<String, dynamic>?)?['text']
            as String?;

    if (text == null || text.trim().isEmpty) {
      throw ApiException('No text found in response. Please try again.');
    }

    final Map<String, dynamic> inner;
    try {
      inner = jsonDecode(text) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException('Could not parse contact data. Try a clearer photo.');
    }

    final contact = ExtractedContact.fromJson(inner);

    if (!contact.isValid) {
      throw ApiException(
          'No contact information found on this card. Try a clearer photo.');
    }

    return contact;
  }
}
