import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import '../MainPage/pages/chat/chat_conversations_screen.dart';

class AcademyDetailScreen extends StatefulWidget {
  final int academyId;
  final Map<String, dynamic>? initialData;

  const AcademyDetailScreen({
    super.key,
    required this.academyId,
    this.initialData,
  });

  @override
  State<AcademyDetailScreen> createState() => _AcademyDetailScreenState();
}

class _AcademyDetailScreenState extends State<AcademyDetailScreen> {
  final ChatService _service = ChatService();

  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _contacting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getScouterAcademyDetail(widget.academyId);
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _contactAdmin() async {
    if (_contacting) return;
    setState(() => _contacting = true);
    try {
      final conversationId = await _service.contactAdmin(academyId: widget.academyId);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationsScreen(
            initialConversationId: conversationId,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to contact admin: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _contacting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = _data ?? const <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(_text(data['academyName'], fallback: 'Academy detail')),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (_loading && _data == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _data == null)
              _messageCard(cs, Icons.error_outline_rounded, 'Unable to load academy', _error!)
            else ...[
              _hero(cs, data),
              const SizedBox(height: 12),
              _metricGrid(cs, data),
              const SizedBox(height: 12),
              _textSection(cs, 'Ranking explanation', _text(data['rankingExplanation'], fallback: 'No explanation available yet.')),
              const SizedBox(height: 12),
              _textSection(cs, 'Main strengths', _text(data['mainStrengths'], fallback: 'Not enough data yet.')),
              const SizedBox(height: 12),
              _textSection(cs, 'Main weaknesses', _text(data['mainWeaknesses'], fallback: 'No critical weaknesses detected.')),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _contacting ? null : _contactAdmin,
                icon: _contacting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.admin_panel_settings_rounded),
                label: const Text('Contact Admin'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hero(ColorScheme cs, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.shield_rounded, color: cs.primary, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(data['academyName'], fallback: 'Academy'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    _text(data['sportName']),
                    _text(data['city']),
                    _text(data['country']),
                  ].where((e) => e.isNotEmpty).join(' • '),
                  style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricGrid(ColorScheme cs, Map<String, dynamic> data) {
    final items = [
      ('Players', _text(data['playersCount'], fallback: '0'), Icons.groups_rounded),
      ('Trainers', _text(data['trainersCount'], fallback: '0'), Icons.sports_rounded),
      ('Score', _text(data['overallScore'], fallback: '0'), Icons.insights_rounded),
      ('Rank', '#${_text(data['rankingPosition'], fallback: '0')}', Icons.emoji_events_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.48),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Icon(item.$3, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(item.$1, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _textSection(ColorScheme cs, String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.44),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: cs.onSurfaceVariant, height: 1.35)),
        ],
      ),
    );
  }

  Widget _messageCard(ColorScheme cs, IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.error),
          const SizedBox(width: 10),
          Expanded(child: Text('$title\n$body')),
        ],
      ),
    );
  }

  String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
