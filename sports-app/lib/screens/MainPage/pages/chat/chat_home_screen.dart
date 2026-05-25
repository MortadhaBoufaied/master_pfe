import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../controllers/ChatController.dart';
import '../../../../controllers/session_controller.dart';
import '../../../../models/chat_contact.dart';
import '../../../../models/conversation_summary.dart';
import '../../../../models/role.dart';
import '../../../../services/chat_service.dart';
import '../../../scouting/academy_detail_screen.dart';
import 'chat_thread_screen.dart';
import 'chat_ui_tokens.dart';

class ChatHomeScreen extends StatefulWidget {
  final int? initialConversationId;

  const ChatHomeScreen({
    super.key,
    this.initialConversationId,
  });

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with SingleTickerProviderStateMixin {
  late final ChatController controller;
  final ChatService _chatService = ChatService();

  final TextEditingController _search = TextEditingController();
  final TextEditingController _academySearch = TextEditingController();

  Timer? _contactsSearchDebounce;
  Timer? _academySearchDebounce;

  bool _booting = true;
  bool _openingContact = false;
  bool _loadingAcademies = false;
  bool _openedInitialConversation = false;
  bool _discoveryMode = false;

  int _selectedChip = 0;
  int? _selectedSportId;
  String _academyOrderBy = 'performance';
  List<Map<String, dynamic>> _sports = const [];
  List<Map<String, dynamic>> _academyContacts = const [];

  final List<String> _chips = const [
    'All',
    'Personal',
    'Groups',
    'Unread',
  ];

  @override
  void initState() {
    super.initState();

    controller = ChatController();

    controller.addListener(_onControllerChanged);
    _search.addListener(_onSearchChanged);
    _academySearch.addListener(_onAcademySearchChanged);

    _bootstrap();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _bootstrap() async {
    if (controller.isBootstrapped) {
      controller.filterConversations(_search.text.trim());

      if (mounted) setState(() => _booting = false);
      return;
    }

    await AppSession.instance.session.loadFromStorage();

    final uid = AppSession.instance.session.userId;
    final div = AppSession.instance.session.divisionId;
    final role = AppSession.instance.session.role;

    if (uid == null) {
      if (mounted) setState(() => _booting = false);
      return;
    }

    await controller.bootstrap(
      userId: uid,
      divisionId: div,
      userRole: role,
    );

    if (role == Role.scouter) {
      await _loadScouterDiscovery();
    }

    controller.filterConversations(_search.text.trim());

    if (!mounted) return;
    setState(() => _booting = false);

    if (widget.initialConversationId != null && !_openedInitialConversation) {
      _openedInitialConversation = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openThreadById(widget.initialConversationId!),
      );
    }
  }

  void _onSearchChanged() {
    final query = _search.text.trim();
    controller.filterConversations(query);
  }

  void _onAcademySearchChanged() {
    _academySearchDebounce?.cancel();
    _academySearchDebounce = Timer(
      const Duration(milliseconds: 350),
      _loadAcademyContacts,
    );
  }

  @override
  void dispose() {
    _contactsSearchDebounce?.cancel();
    _academySearchDebounce?.cancel();

    _search.removeListener(_onSearchChanged);
    _academySearch.removeListener(_onAcademySearchChanged);
    controller.removeListener(_onControllerChanged);

    _search.dispose();
    _academySearch.dispose();

    super.dispose();
  }

  Future<void> _openThreadById(int conversationId) async {
    await controller.openConversation(conversationId);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatThreadScreen(
          controller: controller,
          conversationId: conversationId,
        ),
      ),
    );
  }

  Future<void> _openContact(ChatContact contact) async {
    if (_openingContact) return;

    setState(() => _openingContact = true);

    try {
      int? conversationId;

      if (contact.isGroup) {
        conversationId = contact.conversationId;
      } else {
        conversationId = await controller.openDirectWith(contact.id);
      }

      if (conversationId == null) {
        throw Exception('Unable to open this chat.');
      }

      await _openThreadById(conversationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open chat: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingContact = false);
    }
  }

  Future<void> _contactOwnAdmin() async {
    if (_openingContact) return;
    setState(() => _openingContact = true);
    try {
      final conversationId = await controller.contactAdmin();
      if (conversationId == null) {
        throw Exception(controller.error ?? 'Unable to contact admin');
      }
      await _openThreadById(conversationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to contact admin: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingContact = false);
    }
  }

  Future<void> _contactAcademyAdmin(int academyId) async {
    if (_openingContact) return;
    setState(() => _openingContact = true);
    try {
      final conversationId = await _chatService.contactAdmin(academyId: academyId);
      await controller.refreshConversations();
      await _openThreadById(conversationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to contact academy admin: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingContact = false);
    }
  }

  Future<void> _loadScouterDiscovery() async {
    try {
      final sports = await _chatService.getScoutingSports();
      final prefs = await SharedPreferences.getInstance();
      final savedSport = prefs.getString('recent_scouter_sport_id');
      int? recentSportId = int.tryParse(savedSport ?? '');
      if (recentSportId != null &&
          !sports.any((sport) => _toInt(sport['sportId']) == recentSportId)) {
        recentSportId = null;
      }
      if (!mounted) return;
      setState(() {
        _sports = sports;
        _selectedSportId = recentSportId ??
            (sports.isNotEmpty ? _toInt(sports.first['sportId']) : null);
      });
      await _loadAcademyContacts();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sports = const [];
        _academyContacts = const [];
      });
    }
  }

  Future<void> _loadAcademyContacts() async {
    if (AppSession.instance.session.role != Role.scouter) return;
    setState(() => _loadingAcademies = true);
    try {
      final data = await _chatService.getScouterAcademyContactList(
        sportId: _selectedSportId,
        academyName: _academySearch.text,
        orderBy: _academyOrderBy,
      );
      final items = (data['items'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (mounted) setState(() => _academyContacts = items);
    } catch (_) {
      if (mounted) setState(() => _academyContacts = const []);
    } finally {
      if (mounted) setState(() => _loadingAcademies = false);
    }
  }

  void _toggleDiscoveryMode() {
    if (AppSession.instance.session.role != Role.scouter) return;
    setState(() {
      _discoveryMode = !_discoveryMode;
    });
    if (_discoveryMode) {
      _loadAcademyContacts();
    }
  }

  Future<void> _changeSport(int? sportId) async {
    if (sportId == null || sportId == _selectedSportId) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_scouter_sport_id', sportId.toString());
    if (!mounted) return;
    setState(() => _selectedSportId = sportId);
    await _loadAcademyContacts();
  }

  String _displayName(ConversationSummary c) {
    final myId = controller.currentUserId;

    if (c.participants.length == 2 && myId != null) {
      final other = c.participants.firstWhere(
            (p) => p.id != myId,
        orElse: () => c.participants.first,
      );

      final name = other.name.trim();
      if (name.isNotEmpty) return name;
    }

    final title = (c.title ?? '').trim();
    if (title.isNotEmpty) return title;

    return c.participants.isEmpty
        ? 'Conversation ${c.id}'
        : c.participants
        .map((p) => p.name)
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
  }

  List<ConversationSummary> _visibleConversations() {
    final list = controller.filtered;

    if (_selectedChip == 3) {
      return list.where((c) => c.unreadCount > 0).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AcademyChatUi.pageBg(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: AcademyChatUi.backgroundGradient(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildPageContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AcademyChatUi.surface(context),
        border: Border(
          bottom: BorderSide(color: AcademyChatUi.divider(context)),
        ),
        boxShadow: AcademyChatUi.softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildSearchBar(),

          const SizedBox(height: 12),

          if (!_discoveryMode) _buildChips(),

          if (AppSession.instance.session.role == Role.scouter) ...[
            const SizedBox(height: 12),
            _buildScouterModeToggle(),
          ],

          if (!(_discoveryMode) && controller.contacts.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildContactsRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AcademyChatUi.inputSurface(context),
        borderRadius: AcademyChatUi.r24,
        border: Border.all(
          color: AcademyChatUi.divider(context),
        ),
      ),
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: AcademyChatUi.bodyText(context),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            color: AcademyChatUi.secondaryText(context),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AcademyChatUi.secondaryText(context),
            size: 21,
          ),
          suffixIcon: _search.text.trim().isEmpty
              ? null
              : IconButton(
            onPressed: () {
              _search.clear();
              controller.filterConversations('');
            },
            icon: Icon(
              Icons.close_rounded,
              color: AcademyChatUi.secondaryText(context),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == _selectedChip;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedChip = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? AcademyChatUi.primary
                    : AcademyChatUi.inputSurface(context),
                borderRadius: AcademyChatUi.r20,
                border: Border.all(
                  color: selected
                      ? AcademyChatUi.primary
                      : AcademyChatUi.divider(context),
                ),
              ),
              child: Center(
                child: Text(
                  _chips[i],
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AcademyChatUi.bodyText(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScouterModeToggle() {
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        onPressed: _toggleDiscoveryMode,
        icon: Icon(
          _discoveryMode ? Icons.arrow_back_ios_new_rounded : Icons.filter_alt_rounded,
          size: 18,
        ),
        label: Text(_discoveryMode ? 'Back to history' : 'Find new admin'),
      ),
    );
  }

  Widget _buildContactsRow() {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.contacts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final contact = controller.contacts[i];

          return GestureDetector(
            onTap: () => _openContact(contact),
            child: SizedBox(
              width: 58,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _contactAvatar(contact.name),
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AcademyChatUi.primary2,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AcademyChatUi.surface(context),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AcademyChatUi.secondaryText(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationsList() {
    final list = _visibleConversations();

    if ((_booting || controller.loading) && controller.conversations.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: 7,
        itemBuilder: (context, i) => _buildConversationShimmer(),
      );
    }

    if (list.isEmpty) {
      return _buildEmptyList();
    }

    return RefreshIndicator(
      color: AcademyChatUi.primary,
      backgroundColor: AcademyChatUi.surface(context),
      onRefresh: () async {
        try {
          await controller.refreshConversations();
          controller.filterConversations(_search.text.trim());
        } catch (_) {
          if (mounted && controller.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.error!),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        itemCount: list.length,
        itemBuilder: (context, i) {
          return _buildConversationTile(list[i]);
        },
      ),
    );
  }

  Widget _buildPageContent() {
    if (AppSession.instance.session.role == Role.scouter && _discoveryMode) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        child: _buildScouterDiscovery(),
      );
    }

    return _buildConversationsList();
  }

  Widget _buildScouterDiscovery() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AcademyChatUi.inputSurface(context),
              borderRadius: AcademyChatUi.r20,
              border: Border.all(color: AcademyChatUi.divider(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AcademyChatUi.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.travel_explore_rounded,
                        color: AcademyChatUi.primary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academy contact discovery',
                            style: TextStyle(
                              color: AcademyChatUi.titleText(context),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Filter by sport, search academies, then contact the responsible admin.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AcademyChatUi.secondaryText(context),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedSportId,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Sport',
                          border: OutlineInputBorder(),
                        ),
                        items: _sports
                            .map(
                              (sport) => DropdownMenuItem<int>(
                                value: _toInt(sport['sportId']),
                                child: Text(_display(sport['sportName'], fallback: 'Sport')),
                              ),
                            )
                            .toList(),
                        onChanged: _changeSport,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _academyOrderBy,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Order by',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'performance', child: Text('Best performance')),
                          DropdownMenuItem(value: 'academy_name', child: Text('Academy name')),
                          DropdownMenuItem(value: 'sport', child: Text('Sport')),
                          DropdownMenuItem(value: 'city_country', child: Text('City/Country')),
                          DropdownMenuItem(value: 'ai_ranking_score', child: Text('AI score')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _academyOrderBy = value);
                          _loadAcademyContacts();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _academySearch,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _loadAcademyContacts(),
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Search academy',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loadAcademyContacts,
                    icon: const Icon(Icons.filter_alt_rounded, size: 18),
                    label: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_loadingAcademies)
            const LinearProgressIndicator(minHeight: 2)
          else if (_academyContacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No academies match these filters yet.',
                style: TextStyle(color: AcademyChatUi.secondaryText(context)),
              ),
            )
          else
            Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _academyContacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _academyContactCard(_academyContacts[index]),
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }

  Widget _academyContactCard(Map<String, dynamic> academy) {
    final academyId = _toInt(academy['academyId']);
    final score = _display(academy['overallScore'], fallback: '0');
    final rank = _display(academy['rankingPosition'], fallback: '-');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AcademyChatUi.r20,
        onTap: academyId == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcademyDetailScreen(
                      academyId: academyId,
                      initialData: academy,
                    ),
                  ),
                );
              },
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AcademyChatUi.surface(context),
            borderRadius: AcademyChatUi.r20,
            border: Border.all(color: AcademyChatUi.divider(context)),
            boxShadow: AcademyChatUi.softShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _display(academy['academyName'], fallback: 'Academy'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AcademyChatUi.titleText(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                [
                  _display(academy['sportName']),
                  _display(academy['city']),
                  _display(academy['country']),
                ].where((e) => e.isNotEmpty).join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AcademyChatUi.secondaryText(context),
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  _miniMetric('Score', score),
                  const SizedBox(width: 8),
                  _miniMetric('Rank', '#$rank'),
                ],
              ),
              const Spacer(),
              Text(
                _display(
                  academy['explanation'],
                  fallback: 'Performance ranking is being calculated.',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AcademyChatUi.secondaryText(context),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: academyId == null ? null : () => _contactAcademyAdmin(academyId),
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                  label: const Text('Contact Admin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AcademyChatUi.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AcademyChatUi.primary)),
            const SizedBox(height: 1),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(ConversationSummary c) {
    final name = _displayName(c);
    final subtitle = c.lastMessage.trim().isEmpty
        ? 'No messages yet'
        : c.lastMessage.trim();

    final unread = c.unreadCount;
    final hasUnread = unread > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AcademyChatUi.r20,
        onTap: () => _openThreadById(c.id),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            color: hasUnread
                ? AcademyChatUi.primary.withOpacity(
              AcademyChatUi.isDark(context) ? 0.13 : 0.08,
            )
                : AcademyChatUi.surface(context),
            borderRadius: AcademyChatUi.r20,
            border: Border.all(
              color: hasUnread
                  ? AcademyChatUi.primary.withOpacity(0.22)
                  : AcademyChatUi.divider(context),
            ),
            boxShadow: AcademyChatUi.softShadow(context),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _conversationAvatar(name, hasUnread: hasUnread),
                  if (hasUnread)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AcademyChatUi.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AcademyChatUi.surface(context),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AcademyChatUi.titleText(context),
                              fontSize: 14,
                              fontWeight:
                              hasUnread ? FontWeight.w900 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (c.lastMessageAt != null)
                          Text(
                            _formatChatTime(c.lastMessageAt!),
                            style: TextStyle(
                              color: hasUnread
                                  ? AcademyChatUi.primary
                                  : AcademyChatUi.secondaryText(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AcademyChatUi.secondaryText(context),
                              fontSize: 12,
                              fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (!hasUnread)
                          Icon(
                            Icons.done_all_rounded,
                            size: 16,
                            color: AcademyChatUi.primary2.withOpacity(0.8),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyList() {
    final hasQuery = _search.text.trim().isNotEmpty;
    final isUnreadFilter = _selectedChip == 3;

    final title = isUnreadFilter
        ? 'No unread conversations'
        : hasQuery
        ? 'No matching conversations'
        : 'No conversations yet';

    final subtitle = isUnreadFilter
        ? 'You are all caught up'
        : hasQuery
        ? 'Try another keyword'
        : 'Start chatting with your contacts';

    return RefreshIndicator(
      color: AcademyChatUi.primary,
      backgroundColor: AcademyChatUi.surface(context),
      onRefresh: () async {
        try {
          await controller.refreshConversations();
          controller.filterConversations(_search.text.trim());
        } catch (_) {
          if (mounted && controller.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.error!),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 90),
          Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AcademyChatUi.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: AcademyChatUi.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: AcademyChatUi.titleText(context),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Center(
            child: Text(
              subtitle,
              style: TextStyle(
                color: AcademyChatUi.secondaryText(context),
                fontSize: 13,
              ),
            ),
          ),
          if (!hasQuery && !isUnreadFilter) ...[
            const SizedBox(height: 16),
            Center(
              child: FilledButton.icon(
                onPressed: _openingContact ? null : _contactOwnAdmin,
                icon: const Icon(Icons.admin_panel_settings_rounded),
                label: const Text('Contact Admin'),
              ),
            ),
          ],
          const SizedBox(height: 360),
        ],
      ),
    );
  }

  Widget _buildConversationShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AcademyChatUi.surface(context),
        borderRadius: AcademyChatUi.r20,
        border: Border.all(color: AcademyChatUi.divider(context)),
        boxShadow: AcademyChatUi.softShadow(context),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AcademyChatUi.inputSurface(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLine(width: 140, height: 12),
                const SizedBox(height: 9),
                _shimmerLine(width: 210, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AcademyChatUi.inputSurface(context),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _conversationAvatar(String name, {required bool hasUnread}) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: hasUnread ? AcademyChatUi.primary : AcademyChatUi.divider(context),
          width: hasUnread ? 2 : 1,
        ),
        color: AcademyChatUi.avatarBg(context),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AcademyChatUi.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _contactAvatar(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AcademyChatUi.avatarBg(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: AcademyChatUi.primary.withOpacity(0.45),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AcademyChatUi.primary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  String _formatChatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDate = DateTime(dt.year, dt.month, dt.day);

    if (dtDate == today) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    if (dtDate == yesterday) {
      return 'Yesterday';
    }

    if (now.difference(dt).inDays < 7) {
      const days = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];

      return days[dt.weekday - 1];
    }

    return '${dt.day}/${dt.month}';
  }

  String _display(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
