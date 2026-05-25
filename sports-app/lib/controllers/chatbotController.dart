import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/ChatbotService.dart';

class ChatbotController extends ChangeNotifier {
  final ChatbotService _service;

  final List<ChatMessage> messages = [];
  bool isSending = false;
  String? error;

  ChatbotController({ChatbotService? service})
    : _service = service ?? ChatbotService() {
    messages.add(
      ChatMessage.bot(
        "Hello! I'm your academy assistant. Ask me about players, attendance, scouting, injuries, activities, payments, users, and settings.",
      ),
    );
  }

  Future<void> send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty) return;

    messages.add(ChatMessage.user(msg));
    isSending = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.sendMessage(msg);
      messages.add(
        ChatMessage.bot(
          result.response.isNotEmpty
              ? result.response
              : 'No confident answer found yet. Add this answer in chatbot settings so I can reuse it next time.',
          meta: {
            'score': result.score,
            'confidence': result.confidence,
            'category': result.category,
            'source': result.source,
            'matched_question': result.matchedQuestion,
            'suggestions': result.suggestions,
          },
        ),
      );
    } catch (e) {
      error = e.toString();
      messages.add(
        ChatMessage.bot(
          "Sorry, I couldn't reach the chatbot server. Please try again later.",
        ),
      );
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void reset() {
    messages
      ..clear()
      ..add(
        ChatMessage.bot("Hello! I'm your academy assistant. How can I help?"),
      );
    error = null;
    isSending = false;
    notifyListeners();
  }
}
