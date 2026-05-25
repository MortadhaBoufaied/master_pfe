import 'package:flutter/material.dart';

import '../../components/app_background.dart';
import '../../components/ui_kit.dart';
import '../../models/super_admin_models.dart';
import '../../services/super_admin_service.dart';
import '../chatbot/chatbot_screen.dart';

class SuperAdminAcademiesScreen extends StatefulWidget {
  const SuperAdminAcademiesScreen({super.key});

  @override
  State<SuperAdminAcademiesScreen> createState() =>
      _SuperAdminAcademiesScreenState();
}

class _SuperAdminAcademiesScreenState extends State<SuperAdminAcademiesScreen> {
  final SuperAdminService _service = SuperAdminService();
  final TextEditingController _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<SuperAdminAcademy> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _items = await _service.getAcademies();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<SuperAdminAcademy> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.email.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q) ||
          a.sportName.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openForm([SuperAdminAcademy? academy]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _AcademyFormDialog(academy: academy, service: _service),
    );
    if (changed == true) _load();
  }

  Future<void> _openAdminForm(SuperAdminAcademy academy) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _AcademyAdminDialog(academy: academy, service: _service),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin created for ${academy.name}')),
      );
    }
  }

  Future<void> _delete(SuperAdminAcademy academy) async {
    final ok = await _confirm(context, 'Delete ${academy.name}?');
    if (!ok) return;
    try {
      await _service.deleteAcademy(academy.id);
      await _load();
    } catch (e) {
      _toast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Academies',
      subtitle: 'Create and manage academy organizations.',
      icon: Icons.domain_rounded,
      onRefresh: _load,
      action: FilledButton.icon(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Academy'),
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorState(message: _error!, onRetry: _load);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search academies',
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final academy = _filtered[i];
                return SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IconBadge(
                            icon: Icons.domain_rounded,
                            color: _statusColor(academy.status),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  academy.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    academy.sportName,
                                    academy.city,
                                    academy.country,
                                  ].where((e) => e.isNotEmpty).join(' - '),
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusChip(label: academy.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniChip(
                            icon: Icons.workspace_premium_rounded,
                            text: academy.subscriptionOffer,
                          ),
                          _MiniChip(
                            icon: Icons.receipt_long_rounded,
                            text: academy.subscriptionPaymentStatus,
                          ),
                          if (academy.email.isNotEmpty)
                            _MiniChip(
                              icon: Icons.mail_outline,
                              text: academy.email,
                            ),
                          if (academy.phone.isNotEmpty)
                            _MiniChip(
                              icon: Icons.phone_outlined,
                              text: academy.phone,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _openForm(academy),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _openAdminForm(academy),
                            icon: const Icon(
                              Icons.admin_panel_settings,
                              size: 18,
                            ),
                            label: const Text('Add admin'),
                          ),
                          TextButton.icon(
                            onPressed: () => _delete(academy),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SuperAdminSportsScreen extends StatefulWidget {
  const SuperAdminSportsScreen({super.key});

  @override
  State<SuperAdminSportsScreen> createState() => _SuperAdminSportsScreenState();
}

class _SuperAdminSportsScreenState extends State<SuperAdminSportsScreen> {
  final SuperAdminService _service = SuperAdminService();
  bool _loading = true;
  String? _error;
  bool _showCategories = false;
  List<SuperAdminSport> _sports = [];
  List<SuperAdminSportCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getSports(),
        _service.getSportCategories(),
      ]);
      _sports = results[0] as List<SuperAdminSport>;
      _categories = results[1] as List<SuperAdminSportCategory>;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSportForm([SuperAdminSport? sport]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _SportFormDialog(sport: sport, service: _service),
    );
    if (changed == true) _load();
  }

  Future<void> _openCategoryForm([SuperAdminSportCategory? category]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder:
          (_) => _CategoryFormDialog(
            category: category,
            sports: _sports,
            service: _service,
          ),
    );
    if (changed == true) _load();
  }

  Future<void> _deleteSport(SuperAdminSport sport) async {
    final ok = await _confirm(context, 'Delete ${sport.name}?');
    if (!ok) return;
    try {
      await _service.deleteSport(sport.id);
      await _load();
    } catch (e) {
      _toast(context, e.toString());
    }
  }

  Future<void> _deleteCategory(SuperAdminSportCategory category) async {
    final ok = await _confirm(context, 'Delete ${category.name}?');
    if (!ok) return;
    try {
      await _service.deleteSportCategory(category.id);
      await _load();
    } catch (e) {
      _toast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Sports',
      subtitle: 'Catalog entries and sport categories from the web portal.',
      icon: Icons.sports_rounded,
      onRefresh: _load,
      action: FilledButton.icon(
        onPressed:
            () => _showCategories ? _openCategoryForm() : _openSportForm(),
        icon: const Icon(Icons.add),
        label: Text(_showCategories ? 'Category' : 'Sport'),
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorState(message: _error!, onRetry: _load);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Sports'),
                icon: Icon(Icons.sports),
              ),
              ButtonSegment(
                value: true,
                label: Text('Categories'),
                icon: Icon(Icons.category),
              ),
            ],
            selected: {_showCategories},
            onSelectionChanged:
                (s) => setState(() => _showCategories = s.first),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: _showCategories ? _categoryList() : _sportList(),
          ),
        ),
      ],
    );
  }

  Widget _sportList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      itemCount: _sports.length,
      itemBuilder: (_, i) {
        final sport = _sports[i];
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBadge(
                    icon: Icons.sports_rounded,
                    color: const Color(0xFF115CB9),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sport.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          sport.code.isEmpty
                              ? 'Display order ${sport.displayOrder}'
                              : sport.code,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: sport.isActive,
                    onChanged: (v) async {
                      await _service.setSportActive(sport.id, v);
                      await _load();
                    },
                  ),
                ],
              ),
              if (sport.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(sport.description),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openSportForm(sport),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteSport(sport),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      itemCount: _categories.length,
      itemBuilder: (_, i) {
        final category = _categories[i];
        return SoftCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _IconBadge(
              icon: Icons.category_rounded,
              color: const Color(0xFF0F766E),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              [
                category.code,
                category.sportName,
                'Order ${category.displayOrder}',
              ].where((e) => e.isNotEmpty).join(' - '),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _openCategoryForm(category);
                if (value == 'delete') _deleteCategory(category);
              },
              itemBuilder:
                  (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          ),
        );
      },
    );
  }
}

class SuperAdminContactsScreen extends StatefulWidget {
  const SuperAdminContactsScreen({super.key});

  @override
  State<SuperAdminContactsScreen> createState() =>
      _SuperAdminContactsScreenState();
}

class _SuperAdminContactsScreenState extends State<SuperAdminContactsScreen> {
  final SuperAdminService _service = SuperAdminService();
  bool _loading = true;
  String? _error;
  List<AcademyContactGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _groups = await _service.getAdminContacts();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Contact Admins',
      subtitle: 'Academy owners and admin contacts.',
      icon: Icons.contact_mail_rounded,
      onRefresh: _load,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  itemCount: _groups.length,
                  itemBuilder: (_, i) {
                    final group = _groups[i];
                    final contacts = [
                      if (group.ownerUser != null) group.ownerUser!,
                      ...group.admins,
                    ];
                    return SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.academyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          if (group.city.isNotEmpty || group.country.isNotEmpty)
                            Text(
                              [
                                group.city,
                                group.country,
                              ].where((e) => e.isNotEmpty).join(', '),
                            ),
                          const SizedBox(height: 10),
                          if (contacts.isEmpty)
                            const Text('No admins linked yet.')
                          else
                            for (final contact in contacts)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Text(
                                    contact.name.isEmpty
                                        ? 'A'
                                        : contact.name[0].toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  contact.name.isEmpty
                                      ? contact.email
                                      : contact.name,
                                ),
                                subtitle: Text(
                                  [
                                    contact.email,
                                    contact.phone,
                                  ].where((e) => e.isNotEmpty).join(' - '),
                                ),
                                trailing: _StatusChip(
                                  label: contact.active ? 'ACTIVE' : 'INACTIVE',
                                ),
                              ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class SuperAdminAppDataScreen extends StatelessWidget {
  const SuperAdminAppDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SuperAdminService();
    return _FutureMapScreen(
      title: 'App Data',
      subtitle: 'Platform data and chatbot knowledge base status.',
      icon: Icons.dataset_rounded,
      loader: service.getAppData,
      builder: (data) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _DataGrid(
              data: data,
              keys: const [
                ('academiesCount', 'Academies', Icons.domain_rounded),
                ('sportsCount', 'Sports', Icons.sports_rounded),
                ('usersCount', 'Users', Icons.group_rounded),
                ('chatbotCount', 'Chatbot', Icons.smart_toy_rounded),
                ('webhooksCount', 'Webhooks', Icons.webhook_rounded),
              ],
            ),
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Knowledge Base',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow('Exists', '${data['knowledgeBaseExists'] ?? false}'),
                  _InfoRow(
                    'Web path',
                    '${data['knowledgeBaseWebPath'] ?? '-'}',
                  ),
                  _InfoRow(
                    'Server path',
                    '${data['knowledgeBaseServerPath'] ?? '-'}',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SuperAdminChatbotScreen extends StatefulWidget {
  const SuperAdminChatbotScreen({super.key});

  @override
  State<SuperAdminChatbotScreen> createState() =>
      _SuperAdminChatbotScreenState();
}

class _SuperAdminChatbotScreenState extends State<SuperAdminChatbotScreen> {
  final SuperAdminService _service = SuperAdminService();
  bool _loading = true;
  String? _error;
  List<ChatbotKnowledgeEntry> _entries = [];
  Map<String, dynamic> _bootstrap = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bootstrap = await _service.getChatbotBootstrap();
      final entries = await _service.getGlobalChatbotEntries();
      _bootstrap = bootstrap;
      _entries = entries;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openTeach([ChatbotKnowledgeEntry? entry]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _ChatbotTeachDialog(service: _service, entry: entry),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(ChatbotKnowledgeEntry entry) async {
    final ok = await _confirm(context, 'Delete this answer?');
    if (!ok) return;
    try {
      await _service.deleteChatbotEntry(entry.id);
      await _load();
    } catch (e) {
      _toast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChatbotScreen(
      title: 'Global Chatbot',
      subtitle: 'Ask first, manage knowledge from settings',
      quickPrompts: const [
        'How should the scouting AI detect hidden potential?',
        'Which data should academies collect every week?',
        'How do Pro service locks work?',
      ],
      onSettingsTap: _openSettingsSheet,
    );
  }

  Future<void> _openSettingsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          minChildSize: 0.55,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.settings_suggest_rounded),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Chatbot settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _load,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      FilledButton.icon(
                        onPressed: () => _openTeach(),
                        icon: const Icon(Icons.add_comment_rounded),
                        label: const Text('Teach'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                          ? _ErrorState(message: _error!, onRetry: _load)
                          : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                            children: [
                              SoftCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Knowledge console',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      'Mode',
                                      '${_bootstrap['mode'] ?? 'SUPER_ADMIN'}',
                                    ),
                                    _InfoRow(
                                      'Default scope',
                                      '${_bootstrap['defaultScope'] ?? 'GLOBAL'}',
                                    ),
                                    _InfoRow(
                                      'Knowledge path',
                                      '${_bootstrap['knowledgeBasePath'] ?? '-'}',
                                    ),
                                  ],
                                ),
                              ),
                              if (_entries.isEmpty)
                                const SoftCard(
                                  child: Text(
                                    'No global chatbot knowledge entries yet.',
                                  ),
                                ),
                              for (final entry in _entries)
                                SoftCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.question,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        entry.answer,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          if (entry.tags.isNotEmpty)
                                            _MiniChip(
                                              icon: Icons.sell_outlined,
                                              text: entry.tags,
                                            ),
                                          _MiniChip(
                                            icon: Icons.public,
                                            text:
                                                entry.scope.isEmpty
                                                    ? 'GLOBAL'
                                                    : entry.scope,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () => _openTeach(entry),
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                            ),
                                            label: const Text('Edit'),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            onPressed: () => _delete(entry),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                            ),
                                            label: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class SuperAdminWebhooksScreen extends StatefulWidget {
  const SuperAdminWebhooksScreen({super.key});

  @override
  State<SuperAdminWebhooksScreen> createState() =>
      _SuperAdminWebhooksScreenState();
}

class _SuperAdminWebhooksScreenState extends State<SuperAdminWebhooksScreen> {
  final SuperAdminService _service = SuperAdminService();
  bool _loading = true;
  String? _error;
  List<WebhookItem> _webhooks = [];
  List<WebhookLogItem> _failedLogs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getWebhooks(),
        _service.getFailedWebhookLogs(),
      ]);
      _webhooks = results[0] as List<WebhookItem>;
      _failedLogs = results[1] as List<WebhookLogItem>;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([WebhookItem? webhook]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _WebhookFormDialog(webhook: webhook, service: _service),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(WebhookItem webhook) async {
    final ok = await _confirm(context, 'Delete ${webhook.name}?');
    if (!ok) return;
    try {
      await _service.deleteWebhook(webhook.id);
      await _load();
    } catch (e) {
      _toast(context, e.toString());
    }
  }

  Future<void> _test(WebhookItem webhook) async {
    try {
      await _service.testWebhook(webhook.id);
      _toast(context, 'Webhook test triggered');
      await _load();
    } catch (e) {
      _toast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Webhooks',
      subtitle: 'Automation endpoints and failed execution logs.',
      icon: Icons.webhook_rounded,
      onRefresh: _load,
      action: FilledButton.icon(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Webhook'),
      ),
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  children: [
                    for (final webhook in _webhooks)
                      SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _IconBadge(
                                  icon: Icons.webhook_rounded,
                                  color: const Color(0xFF115CB9),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        webhook.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        webhook.url,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: webhook.isActive,
                                  onChanged: (v) async {
                                    await _service.setWebhookActive(
                                      webhook.id,
                                      v,
                                    );
                                    await _load();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MiniChip(
                                  icon: Icons.bolt_rounded,
                                  text: webhook.eventType,
                                ),
                                _MiniChip(
                                  icon: Icons.http_rounded,
                                  text: webhook.httpMethod,
                                ),
                                _MiniChip(
                                  icon: Icons.repeat_rounded,
                                  text: '${webhook.triggerCount} runs',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _openForm(webhook),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _test(webhook),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Test'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _delete(webhook),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  label: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (_failedLogs.isNotEmpty)
                      SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Failed Logs',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            for (final log in _failedLogs.take(6))
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                ),
                                title: Text(log.eventType),
                                subtitle: Text(
                                  log.errorMessage.isEmpty
                                      ? log.executedAt
                                      : log.errorMessage,
                                ),
                                trailing: Text('${log.statusCode}'),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}

class SuperAdminAcademyPaymentsScreen extends StatefulWidget {
  const SuperAdminAcademyPaymentsScreen({super.key});

  @override
  State<SuperAdminAcademyPaymentsScreen> createState() =>
      _SuperAdminAcademyPaymentsScreenState();
}

class _SuperAdminAcademyPaymentsScreenState
    extends State<SuperAdminAcademyPaymentsScreen> {
  final SuperAdminService _service = SuperAdminService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _data = {};
  List<AcademyPaymentItem> _payments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _data = await _service.getAcademyPayments();
      final raw = _data['payments'];
      _payments =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map(
                    (e) => AcademyPaymentItem.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
              : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markPaid(AcademyPaymentItem payment) async {
    final ok = await _confirm(
      context,
      'Mark ${payment.referenceCode} as paid?',
    );
    if (!ok) return;
    try {
      await _service.markAcademyPaymentPaid(payment.id);
      await _load();
    } catch (e) {
      _toast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Academy Payments',
      subtitle: 'Subscription invoices and approval queue.',
      icon: Icons.credit_card_rounded,
      onRefresh: _load,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  children: [
                    _DataGrid(
                      data: _data,
                      keys: const [
                        (
                          'pendingPaymentsCount',
                          'Pending',
                          Icons.pending_actions_rounded,
                        ),
                        ('totalCollected', 'Collected', Icons.payments_rounded),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final payment in _payments)
                      SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _IconBadge(
                                  icon: Icons.receipt_long_rounded,
                                  color:
                                      payment.isPaid
                                          ? const Color(0xFF0F766E)
                                          : const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        payment.academyName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(payment.referenceCode),
                                    ],
                                  ),
                                ),
                                _StatusChip(label: payment.status),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                _MiniChip(
                                  icon: Icons.workspace_premium_rounded,
                                  text: payment.offer,
                                ),
                                _MiniChip(
                                  icon: Icons.payments_rounded,
                                  text:
                                      '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                                ),
                                if (payment.dueDate.isNotEmpty)
                                  _MiniChip(
                                    icon: Icons.event_rounded,
                                    text: payment.dueDate,
                                  ),
                              ],
                            ),
                            if (payment.isPending) ...[
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                onPressed: () => _markPaid(payment),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Mark paid'),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}

class SuperAdminSettingsScreen extends StatelessWidget {
  const SuperAdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SuperAdminService();
    return _FutureMapScreen(
      title: 'Settings',
      subtitle: 'Platform retention and subscription policy reference.',
      icon: Icons.settings_rounded,
      loader: service.getSettings,
      builder: (data) {
        final policies = data['retentionPolicies'];
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription Prices',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow('Currency', '${data['currency'] ?? 'TND'}'),
                  _InfoRow('Offers', '${data['offerPrices'] ?? '-'}'),
                ],
              ),
            ),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Retention Policies',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text('$policies'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class AdminServiceDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AdminServiceDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademyFormDialog extends StatefulWidget {
  final SuperAdminAcademy? academy;
  final SuperAdminService service;

  const _AcademyFormDialog({this.academy, required this.service});

  @override
  State<_AcademyFormDialog> createState() => _AcademyFormDialogState();
}

class _AcademyFormDialogState extends State<_AcademyFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _slug;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _country;
  late final TextEditingController _logo;
  late final TextEditingController _sportId;
  String _status = 'ACTIVE';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.academy;
    _name = TextEditingController(text: a?.name ?? '');
    _slug = TextEditingController(text: a?.slug ?? '');
    _email = TextEditingController(text: a?.email ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _address = TextEditingController(text: a?.address ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _country = TextEditingController(text: a?.country ?? '');
    _logo = TextEditingController(text: a?.logoUrl ?? '');
    _sportId = TextEditingController(text: a?.sportId?.toString() ?? '');
    _status = a?.status ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _country.dispose();
    _logo.dispose();
    _sportId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final academy = SuperAdminAcademy(
      id: widget.academy?.id ?? 0,
      name: _name.text.trim(),
      slug: _slug.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      country: _country.text.trim(),
      status: _status,
      logoUrl: _logo.text.trim(),
      sportId: int.tryParse(_sportId.text.trim()),
    );
    try {
      if (widget.academy == null) {
        await widget.service.createAcademy(academy);
      } else {
        await widget.service.updateAcademy(academy);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.academy == null ? 'New Academy' : 'Edit Academy'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(_name, 'Academy name', isRequired: true),
                _dialogField(_slug, 'Slug', isRequired: true),
                _dialogField(_email, 'Email'),
                _dialogField(_phone, 'Phone'),
                _dialogField(_address, 'Address'),
                Row(
                  children: [
                    Expanded(child: _dialogField(_city, 'City')),
                    const SizedBox(width: 10),
                    Expanded(child: _dialogField(_country, 'Country')),
                  ],
                ),
                _dialogField(_logo, 'Logo URL'),
                _dialogField(
                  _sportId,
                  'Sport ID',
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'INACTIVE',
                      child: Text('Inactive'),
                    ),
                    DropdownMenuItem(
                      value: 'SUSPENDED',
                      child: Text('Suspended'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon:
              _saving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.save),
          label: Text(_saving ? 'Saving' : 'Save'),
        ),
      ],
    );
  }
}

class _AcademyAdminDialog extends StatefulWidget {
  final SuperAdminAcademy academy;
  final SuperAdminService service;

  const _AcademyAdminDialog({required this.academy, required this.service});

  @override
  State<_AcademyAdminDialog> createState() => _AcademyAdminDialogState();
}

class _AcademyAdminDialogState extends State<_AcademyAdminDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.createAcademyAdmin(
        academyId: widget.academy.id,
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _phone.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Admin for ${widget.academy.name}'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(_name, 'Name', isRequired: true),
              _dialogField(_email, 'Email', isRequired: true),
              _dialogField(
                _password,
                'Password',
                isRequired: true,
                obscureText: true,
              ),
              _dialogField(_phone, 'Phone'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Creating' : 'Create'),
        ),
      ],
    );
  }
}

class _SportFormDialog extends StatefulWidget {
  final SuperAdminSport? sport;
  final SuperAdminService service;

  const _SportFormDialog({this.sport, required this.service});

  @override
  State<_SportFormDialog> createState() => _SportFormDialogState();
}

class _SportFormDialogState extends State<_SportFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _order;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.sport;
    _code = TextEditingController(text: s?.code ?? '');
    _name = TextEditingController(text: s?.name ?? '');
    _description = TextEditingController(text: s?.description ?? '');
    _order = TextEditingController(text: '${s?.displayOrder ?? 0}');
    _active = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
    _order.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final sport = SuperAdminSport(
      id: widget.sport?.id ?? 0,
      code: _code.text.trim(),
      name: _name.text.trim(),
      description: _description.text.trim(),
      displayOrder: int.tryParse(_order.text.trim()) ?? 0,
      isActive: _active,
    );
    try {
      if (widget.sport == null) {
        await widget.service.createSport(sport);
      } else {
        await widget.service.updateSport(sport);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.sport == null ? 'New Sport' : 'Edit Sport'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(_code, 'Code', isRequired: true),
                _dialogField(_name, 'Name', isRequired: true),
                _dialogField(_description, 'Description', maxLines: 3),
                _dialogField(
                  _order,
                  'Display order',
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                  title: const Text('Active'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving' : 'Save'),
        ),
      ],
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final SuperAdminSportCategory? category;
  final List<SuperAdminSport> sports;
  final SuperAdminService service;

  const _CategoryFormDialog({
    this.category,
    required this.sports,
    required this.service,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _order;
  int? _sportId;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _code = TextEditingController(text: c?.code ?? '');
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _order = TextEditingController(text: '${c?.displayOrder ?? 0}');
    _sportId =
        c?.sportId ??
        (widget.sports.isNotEmpty ? widget.sports.first.id : null);
    _active = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
    _order.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final category = SuperAdminSportCategory(
      id: widget.category?.id ?? 0,
      code: _code.text.trim(),
      name: _name.text.trim(),
      description: _description.text.trim(),
      sportId: _sportId,
      displayOrder: int.tryParse(_order.text.trim()) ?? 0,
      isActive: _active,
    );
    try {
      if (widget.category == null) {
        await widget.service.createSportCategory(category);
      } else {
        await widget.service.updateSportCategory(category);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'New Category' : 'Edit Category'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _sportId,
                  decoration: const InputDecoration(labelText: 'Sport'),
                  items:
                      widget.sports
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _sportId = v),
                  validator: (v) => v == null ? 'Select sport' : null,
                ),
                _dialogField(_code, 'Code', isRequired: true),
                _dialogField(_name, 'Name', isRequired: true),
                _dialogField(_description, 'Description', maxLines: 3),
                _dialogField(
                  _order,
                  'Display order',
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                  title: const Text('Active'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving' : 'Save'),
        ),
      ],
    );
  }
}

class _ChatbotTeachDialog extends StatefulWidget {
  final SuperAdminService service;
  final ChatbotKnowledgeEntry? entry;

  const _ChatbotTeachDialog({required this.service, this.entry});

  @override
  State<_ChatbotTeachDialog> createState() => _ChatbotTeachDialogState();
}

class _ChatbotTeachDialogState extends State<_ChatbotTeachDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _question;
  late final TextEditingController _answer;
  late final TextEditingController _tags;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: widget.entry?.question ?? '');
    _answer = TextEditingController(text: widget.entry?.answer ?? '');
    _tags = TextEditingController(text: widget.entry?.tags ?? '');
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.teachGlobalChatbot(
        question: _question.text.trim(),
        answer: _answer.text.trim(),
        tags: _tags.text.trim(),
        replaceEntryId: widget.entry?.id,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.entry == null ? 'Teach Chatbot' : 'Edit Answer'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  _question,
                  'Question',
                  isRequired: true,
                  maxLines: 2,
                ),
                _dialogField(_answer, 'Answer', isRequired: true, maxLines: 5),
                _dialogField(_tags, 'Tags'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving' : 'Save'),
        ),
      ],
    );
  }
}

class _WebhookFormDialog extends StatefulWidget {
  final WebhookItem? webhook;
  final SuperAdminService service;

  const _WebhookFormDialog({this.webhook, required this.service});

  @override
  State<_WebhookFormDialog> createState() => _WebhookFormDialogState();
}

class _WebhookFormDialogState extends State<_WebhookFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _url;
  late final TextEditingController _eventType;
  late final TextEditingController _headers;
  late final TextEditingController _auth;
  String _method = 'POST';
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final w = widget.webhook;
    _name = TextEditingController(text: w?.name ?? '');
    _url = TextEditingController(text: w?.url ?? '');
    _eventType = TextEditingController(text: w?.eventType ?? '');
    _headers = TextEditingController(text: w?.headers ?? '');
    _auth = TextEditingController(text: w?.authentication ?? '');
    _method = w?.httpMethod ?? 'POST';
    _active = w?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _eventType.dispose();
    _headers.dispose();
    _auth.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final webhook = WebhookItem(
      id: widget.webhook?.id ?? 0,
      name: _name.text.trim(),
      url: _url.text.trim(),
      eventType: _eventType.text.trim(),
      httpMethod: _method,
      isActive: _active,
      headers: _headers.text.trim(),
      authentication: _auth.text.trim(),
    );
    try {
      if (widget.webhook == null) {
        await widget.service.createWebhook(webhook);
      } else {
        await widget.service.updateWebhook(webhook);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.webhook == null ? 'New Webhook' : 'Edit Webhook'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(_name, 'Name', isRequired: true),
                _dialogField(_url, 'URL', isRequired: true),
                _dialogField(_eventType, 'Event type', isRequired: true),
                DropdownButtonFormField<String>(
                  value: _method,
                  decoration: const InputDecoration(labelText: 'HTTP method'),
                  items:
                      const ['POST', 'GET', 'PUT', 'DELETE']
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _method = v ?? 'POST'),
                ),
                _dialogField(_headers, 'Headers JSON', maxLines: 3),
                _dialogField(_auth, 'Authentication header'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                  title: const Text('Active'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving' : 'Save'),
        ),
      ],
    );
  }
}

class _ModuleScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? action;
  final Future<void> Function()? onRefresh;

  const _ModuleScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.action,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title),
          actions: [
            if (onRefresh != null)
              IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF012D1D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (action != null) ...[const SizedBox(width: 10), action!],
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _FutureMapScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Future<Map<String, dynamic>> Function() loader;
  final Widget Function(Map<String, dynamic>) builder;

  const _FutureMapScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.loader,
    required this.builder,
  });

  @override
  State<_FutureMapScreen> createState() => _FutureMapScreenState();
}

class _FutureMapScreenState extends State<_FutureMapScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _reload() {
    setState(() => _future = widget.loader());
  }

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      icon: widget.icon,
      onRefresh: () async => _reload(),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorState(
              message: snap.error.toString(),
              onRetry: _reload,
            );
          }
          return widget.builder(snap.data ?? {});
        },
      ),
    );
  }
}

class _DataGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<(String, String, IconData)> keys;

  const _DataGrid({required this.data, required this.keys});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final item = keys[i];
        return SoftCard(
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              _IconBadge(icon: item.$3, color: const Color(0xFF0F766E)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data[item.$1] ?? 0}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    Text(item.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 46,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _dialogField(
  TextEditingController controller,
  String label, {
  bool isRequired = false,
  bool obscureText = false,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator:
          isRequired
              ? (v) =>
                  v == null || v.trim().isEmpty ? '$label is required' : null
              : null,
    ),
  );
}

Color _statusColor(String value) {
  final normalized = value.toUpperCase();
  if (normalized.contains('PAID') || normalized.contains('ACTIVE')) {
    return const Color(0xFF0F766E);
  }
  if (normalized.contains('PENDING')) return const Color(0xFFF59E0B);
  if (normalized.contains('SUSPENDED') || normalized.contains('FAIL')) {
    return const Color(0xFFBA1A1A);
  }
  return const Color(0xFF115CB9);
}

Future<bool> _confirm(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Confirm'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
      ) ??
      false;
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

class SuperAdminThemesScreen extends StatelessWidget {
  const SuperAdminThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _ThemeInfo(
        'Platform default theme',
        'Global fallback used when an academy or sport does not define a custom theme.',
        Icons.public_rounded,
        Color(0xFF0F766E),
      ),
      _ThemeInfo(
        'Sport theme',
        'Sport-level colors, logos, cards, font, buttons, and icons exposed by the web platform.',
        Icons.sports_rounded,
        Color(0xFF2563EB),
      ),
      _ThemeInfo(
        'Academy theme',
        'Academy logo, home banner, splash image, and custom colors shown in the mobile app.',
        Icons.domain_rounded,
        Color(0xFFF59E0B),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Themes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const SectionTitle(
              title: 'Themes',
              subtitle:
                  'Mobile view of the web theme modules: platform, sport, and academy visual identity.',
            ),
            ...items.map(
              (item) => SoftCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it is applied in mobile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The app loads the academy theme after authentication and applies it through AppTheme, AppBackground, cards, buttons, and banners. This keeps admin/super-admin design close to the web portal while preserving the existing mobile UI.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ThemeInfo(this.title, this.subtitle, this.icon, this.color);
}
