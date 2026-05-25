import 'package:flutter/material.dart';

import 'chat_home_screen.dart';

/// Backward-compatible screen.
class ChatConversationsScreen extends StatelessWidget {
  final int? initialConversationId;

  const ChatConversationsScreen({
    super.key,
    this.initialConversationId,
  });

  @override
  Widget build(BuildContext context) {
    return ChatHomeScreen(initialConversationId: initialConversationId);
  }
}
