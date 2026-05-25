import 'dart:convert';

import 'ApiService.dart';

class ChatbotApiResult {
  final String response;
  final double? score;
  final String? confidence;
  final String? category;
  final String? source;
  final String? matchedQuestion;
  final List<String> suggestions;

  ChatbotApiResult({
    required this.response,
    this.score,
    this.confidence,
    this.category,
    this.source,
    this.matchedQuestion,
    this.suggestions = const [],
  });

  factory ChatbotApiResult.fromJson(Map<String, dynamic> json) {
    final suggestionsRaw = json['suggestions'];
    return ChatbotApiResult(
      response: (json['response'] ?? json['answer'] ?? '').toString(),
      score: json['score'] is num ? (json['score'] as num).toDouble() : null,
      confidence: json['confidence']?.toString(),
      category: json['category']?.toString(),
      source: json['source']?.toString(),
      matchedQuestion:
          (json['matched_question'] ?? json['matchedQuestion'])?.toString(),
      suggestions:
          suggestionsRaw is List
              ? suggestionsRaw.map((item) => item.toString()).toList()
              : const [],
    );
  }
}

/// Chatbot service backed by the Spring Boot academy assistant endpoint.
class ChatbotService {
  final ApiClient _api;

  ChatbotService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<ChatbotApiResult> sendMessage(
    String message, {
    int? academyId,
    int? sportId,
  }) async {
    final resp = await _api.post(
      '/chatbot/ask',
      body: {
        'question': message,
        if (academyId != null) 'academyId': academyId,
        if (sportId != null) 'sportId': sportId,
      },
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(resp.bodyBytes));
      return ChatbotApiResult.fromJson(data);
    }

    // Try to decode error body
    String details = '';
    try {
      final j = jsonDecode(utf8.decode(resp.bodyBytes));
      details = j is Map && j['error'] != null ? ' (${j['error']})' : '';
    } catch (_) {}

    throw Exception('Chatbot API error: ${resp.statusCode}$details');
  }

  /// Backward compatible helper used by older UI.
  Future<String> getAnswer(String question) async {
    final r = await sendMessage(question);
    return r.response.isNotEmpty
        ? r.response
        : 'No confident answer found. Try rephrasing your question.';
  }

  /// The new Django chatbot API does not expose the full knowledge base.
  /// Keep this method for compatibility but return an empty list.
  Future<List<dynamic>> getKnowledgeBase() async => [];
}
