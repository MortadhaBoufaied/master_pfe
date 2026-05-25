import 'package:flutter/material.dart';
import 'package:moez_project/components/NavigationLink.dart';
import 'package:intl/intl.dart';

import '../../controllers/chatbotController.dart';

class ChatbotScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onSettingsTap;
  final String? settingsRoute;
  final List<String> quickPrompts;

  const ChatbotScreen({
    Key? key,
    this.title = 'Academy Assistant',
    this.subtitle = 'Live chatbot for academy operations',
    this.onSettingsTap,
    this.settingsRoute,
    this.quickPrompts = const [
      'How do trainers mark attendance?',
      'How does scouting detect hidden potential?',
      'How do injuries affect player potential?',
    ],
  }) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final ChatbotController _controller;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  // Design system properties (matching home page)
  ColorScheme get cs => Theme.of(context).colorScheme;
  TextTheme get tt => Theme.of(context).textTheme;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  double get _radius => 16;

  Color get _cardColor =>
      isDark ? const Color(0xFF141A20) : Colors.white.withOpacity(0.92);

  Color get _botCardColor =>
      isDark ? cs.surfaceVariant.withOpacity(0.35) : const Color(0xFFF4F7F7);

  Color get _userBubbleColor => const Color(0xFF20B2A7); // teal

  Color get _strokeColor => cs.outlineVariant.withOpacity(isDark ? 0.28 : 0.16);

  List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  TextStyle get _botLabelStyle => (tt.labelSmall ?? const TextStyle()).copyWith(
    fontWeight: FontWeight.w800,
    fontSize: 11,
    color: _userBubbleColor,
    letterSpacing: 0.5,
  );

  TextStyle get _messageStyle => (tt.bodyMedium ?? const TextStyle()).copyWith(
    color: cs.onSurface,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  TextStyle get _timeStyle => (tt.labelSmall ?? const TextStyle()).copyWith(
    color: cs.onSurface.withOpacity(isDark ? 0.60 : 0.50),
    fontWeight: FontWeight.w500,
    fontSize: 11,
  );

  TextStyle get _confidenceStyle =>
      (tt.labelSmall ?? const TextStyle()).copyWith(
        color: cs.onSurface.withOpacity(isDark ? 0.50 : 0.45),
        fontWeight: FontWeight.w500,
        fontSize: 10,
      );

  @override
  void initState() {
    super.initState();
    _controller = ChatbotController();
    _controller.addListener(_autoScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_autoScroll);
    _controller.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _autoScroll() {
    if (!mounted || !_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      try {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // Ignore scroll errors if widget is being disposed
      }
    });
  }

  void _send() {
    final text = _input.text;
    _input.clear();
    _controller.send(text);
  }

  void _sendPrompt(String text) {
    _input.clear();
    _controller.send(text);
  }

  void _openSettings() {
    if (widget.onSettingsTap != null) {
      widget.onSettingsTap!();
      return;
    }

    final settingsRoute = widget.settingsRoute;
    if (settingsRoute == null || settingsRoute.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chatbot settings',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'The live chat is the main page. Knowledge management stays available here as a settings option.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.manage_search_rounded),
                title: const Text('Open knowledge/settings page'),
                subtitle: const Text(
                  'Manage saved answers and admin chatbot configuration',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, settingsRoute);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt_rounded),
                title: const Text('Reset conversation'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.reset();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubble({
    required bool isUser,
    required String text,
    required String time,
    Map<String, dynamic>? meta,
  }) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _userBubbleColor,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: _softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(text, style: _messageStyle.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(time, style: _timeStyle.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _botCardColor,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: _strokeColor),
              boxShadow: _softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _userBubbleColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        size: 14,
                        color: _userBubbleColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Chatbot', style: _botLabelStyle),
                  ],
                ),
                const SizedBox(height: 10),
                Text(text, style: _messageStyle),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(time, style: _timeStyle),
                    if (meta != null &&
                        (meta['confidence'] != null || meta['score'] != null))
                      Text(
                        '${meta['confidence'] ?? 'confidence'}'
                        '${meta['score'] != null ? ' | ${meta['score']}' : ''}',
                        style: _confidenceStyle,
                      ),
                  ],
                ),
                if (meta != null &&
                    meta['suggestions'] is List &&
                    (meta['suggestions'] as List).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        (meta['suggestions'] as List)
                            .take(3)
                            .map(
                              (suggestion) => ActionChip(
                                visualDensity: VisualDensity.compact,
                                label: Text(
                                  suggestion.toString(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed:
                                    _controller.isSending
                                        ? null
                                        : () =>
                                            _sendPrompt(suggestion.toString()),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TopNavigationBar(
        title: widget.title,
        subtitle: widget.subtitle,
        onSearchTap: () => Navigator.pushNamed(context, '/global-search'),
        showLogo: true,
        onNotificationTap: () => Navigator.pushNamed(context, '/notifications'),
        extraActions:
            widget.onSettingsTap != null || widget.settingsRoute != null
                ? [
                  Tooltip(
                    message: 'Chatbot settings',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openSettings,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.primary.withOpacity(0.16),
                          ),
                        ),
                        child: Icon(
                          Icons.settings_suggest_rounded,
                          color: cs.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ]
                : const [],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              _quickPromptBar(),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount:
                      _controller.messages.length +
                      (_controller.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_controller.isSending &&
                        index == _controller.messages.length) {
                      return _bubble(
                        isUser: false,
                        text: 'Typing...',
                        time: DateFormat('HH:mm').format(DateTime.now()),
                      );
                    }
                    final m = _controller.messages[index];
                    return _bubble(
                      isUser: m.role == 'user',
                      text: m.content,
                      time: DateFormat('HH:mm').format(m.time),
                      meta: m.meta,
                    );
                  },
                ),
              ),
              if (_controller.error != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.withOpacity(isDark ? 0.25 : 0.15),
                    ),
                  ),
                  child: Text(
                    _controller.error!,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _strokeColor),
                            boxShadow: _softShadow,
                          ),
                          child: TextField(
                            controller: _input,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            style: _messageStyle,
                            decoration: InputDecoration(
                              hintText: 'Ask the chatbot...',
                              hintStyle: _messageStyle.copyWith(
                                color: cs.onSurface.withOpacity(
                                  isDark ? 0.50 : 0.45,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _userBubbleColor.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _userBubbleColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              _controller.isSending
                                  ? []
                                  : [
                                    BoxShadow(
                                      color: _userBubbleColor.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _controller.isSending ? null : _send,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.send_rounded,
                                size: 18,
                                color: Colors.white.withOpacity(
                                  _controller.isSending ? 0.5 : 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _quickPromptBar() {
    if (widget.quickPrompts.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final prompt = widget.quickPrompts[index];
          return ActionChip(
            avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: Text(prompt),
            onPressed: _controller.isSending ? null : () => _sendPrompt(prompt),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: widget.quickPrompts.length,
      ),
    );
  }
}
