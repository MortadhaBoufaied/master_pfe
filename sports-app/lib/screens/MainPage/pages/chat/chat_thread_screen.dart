import 'package:flutter/material.dart';

import '../../../../controllers/ChatController.dart';
import '../../../../models/conversation_summary.dart';
import 'chat_ui_tokens.dart';

class ChatThreadScreen extends StatefulWidget {
  final ChatController controller;
  final int conversationId;

  const ChatThreadScreen({
    super.key,
    required this.controller,
    required this.conversationId,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _opening = true;

  String _conversationDisplayName(ConversationSummary? c) {
    if (c == null) return 'Conversation ${widget.conversationId}';

    final myId = widget.controller.currentUserId;

    if (c.participants.length == 2 && myId != null) {
      final other = c.participants.firstWhere(
            (p) => p.id != myId,
        orElse: () => c.participants.first,
      );

      final otherName = other.name.trim();
      if (otherName.isNotEmpty) return otherName;
    }

    final title = (c.title ?? '').trim();
    if (title.isNotEmpty) return title;

    final names = c.participants
        .map((p) => p.name.trim())
        .where((n) => n.isNotEmpty)
        .join(', ');

    if (names.isNotEmpty) return names;

    return 'Conversation ${c.id}';
  }

  String _conversationSubtitle(ConversationSummary? c) {
    if (c == null || c.participants.isEmpty) return 'Online';

    if (c.participants.length == 1) return 'Online';

    return '${c.participants.length} members';
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await widget.controller.openConversation(widget.conversationId);
    } finally {
      if (!mounted) return;

      setState(() => _opening = false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;

    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    _input.clear();

    await widget.controller.sendMessage(content: text);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.controller.findConversationById(widget.conversationId);
    final conversationName = _conversationDisplayName(conv);

    return Scaffold(
      backgroundColor: AcademyChatUi.pageBg(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: AcademyChatUi.backgroundGradient(context),
        ),
        child: Column(
          children: [
            _buildHeader(
              title: conversationName,
              subtitle: _conversationSubtitle(conv),
            ),
            Expanded(
              child: _buildMessages(),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String title,
    required String subtitle,
  }) {
    final dark = AcademyChatUi.isDark(context);

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 10),
        decoration: BoxDecoration(
          color: AcademyChatUi.surface(context),
          border: Border(
            bottom: BorderSide(color: AcademyChatUi.divider(context)),
          ),
          boxShadow: [
            BoxShadow(
              color: AcademyChatUi.shadow(context),
              blurRadius: dark ? 14 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AcademyChatUi.titleText(context),
                size: 20,
              ),
            ),

            _buildAvatar(title, radius: 19),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AcademyChatUi.titleText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AcademyChatUi.primary2,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AcademyChatUi.secondaryText(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _headerIcon(Icons.videocam_outlined),
            const SizedBox(width: 6),
            _headerIcon(Icons.call_outlined),
          ],
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    final dark = AcademyChatUi.isDark(context);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.07) : const Color(0xFFF1F6F4),
        shape: BoxShape.circle,
        border: Border.all(color: AcademyChatUi.divider(context)),
      ),
      child: Icon(
        icon,
        color: AcademyChatUi.titleText(context),
        size: 20,
      ),
    );
  }

  Widget _buildMessages() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (_opening || widget.controller.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AcademyChatUi.primary,
            ),
          );
        }

        final msgs = widget.controller.messages;

        if (msgs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          itemCount: msgs.length,
          itemBuilder: (context, i) {
            final m = msgs[i];
            final isMe = m.senderId == widget.controller.currentUserId;

            final showTime = i == 0 ||
                msgs[i - 1].senderId != m.senderId ||
                m.timestamp.difference(msgs[i - 1].timestamp).inMinutes > 5;

            return Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AcademyChatUi.inputSurface(context),
                          borderRadius: AcademyChatUi.r16,
                          border: Border.all(
                            color: AcademyChatUi.divider(context),
                          ),
                        ),
                        child: Text(
                          _formatTime(m.timestamp),
                          style: TextStyle(
                            color: AcademyChatUi.secondaryText(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                _buildBubble(
                  text: m.content,
                  time: _formatMessageHour(m.timestamp),
                  isMe: isMe,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBubble({
    required String text,
    required String time,
    required bool isMe,
  }) {
    final bubbleColor = isMe
        ? AcademyChatUi.sentBubble(context)
        : AcademyChatUi.receivedBubble(context);

    final textColor = isMe
        ? const Color(0xFF172000)
        : AcademyChatUi.bodyText(context);

    final timeColor = isMe
        ? Colors.black.withOpacity(0.46)
        : AcademyChatUi.secondaryText(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        padding: const EdgeInsets.fromLTRB(13, 9, 10, 7),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 5),
            bottomRight: Radius.circular(isMe ? 5 : 18),
          ),
          border: Border.all(
            color: isMe
                ? Colors.black.withOpacity(0.04)
                : AcademyChatUi.divider(context),
          ),
          boxShadow: [
            BoxShadow(
              color: AcademyChatUi.shadow(context),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.32,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: timeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Colors.black.withOpacity(0.45),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: AcademyChatUi.surface(context),
          border: Border(
            top: BorderSide(color: AcademyChatUi.divider(context)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _roundInputIcon(Icons.attach_file_rounded),

            const SizedBox(width: 8),

            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AcademyChatUi.inputSurface(context),
                  borderRadius: AcademyChatUi.r24,
                  border: Border.all(
                    color: AcademyChatUi.divider(context),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: AcademyChatUi.bodyText(context),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(
                            color: AcademyChatUi.secondaryText(context),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: AcademyChatUi.secondaryText(context),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AcademyChatUi.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _send,
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundInputIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AcademyChatUi.inputSurface(context),
        shape: BoxShape.circle,
        border: Border.all(color: AcademyChatUi.divider(context)),
      ),
      child: Icon(
        icon,
        color: AcademyChatUi.secondaryText(context),
        size: 20,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AcademyChatUi.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AcademyChatUi.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No messages yet',
              style: TextStyle(
                color: AcademyChatUi.titleText(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start the conversation with a message.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AcademyChatUi.secondaryText(context),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, {double radius = 24}) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AcademyChatUi.avatarBg(context),
      child: Text(
        initial,
        style: TextStyle(
          color: AcademyChatUi.primary,
          fontWeight: FontWeight.w900,
          fontSize: radius * 0.78,
        ),
      ),
    );
  }

  String _formatMessageHour(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);
    final hour = _formatMessageHour(dt);

    if (msgDate == today) {
      return 'Today, $hour';
    }

    if (msgDate == yesterday) {
      return 'Yesterday, $hour';
    }

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}