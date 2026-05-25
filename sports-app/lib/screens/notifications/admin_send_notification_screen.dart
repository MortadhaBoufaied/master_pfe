import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../controllers/session_controller.dart';
import '../../models/notification_campaign_stats.dart';
import '../../models/role.dart';
import '../../services/notification_realtime_service.dart';
import '../../services/notification_service.dart';
import '../../components/app_background.dart';
import '../../components/ui_kit.dart';

/// Admin advanced notification sender (mobile + web).
/// Supports:
/// - single user (by name/email)
/// - division
/// - advanced filters (credit threshold, months unpaid, joined/attendance windows)
/// Message content supports limited HTML (<b>, <u>, <span style="color:#RRGGBB">).
class AdminSendNotificationScreen extends StatefulWidget {
  final bool embedded;

  const AdminSendNotificationScreen({super.key, this.embedded = false});

  @override
  State<AdminSendNotificationScreen> createState() => _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState extends State<AdminSendNotificationScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _userQuery = TextEditingController();
  final _division = TextEditingController();
  final _credit = TextEditingController(text: '100');
  final _months = TextEditingController(text: '2');
  final NotificationRealtimeService _realtime = NotificationRealtimeService();

  String mode = 'USER'; // USER | DIVISION | CREDIT | NEW | ACTIVE | INACTIVE
  bool sending = false;
  bool loadingCampaigns = false;
  String? status;
  String? campaignsError;
  StompUnsubscribe? _statsSubscription;
  List<NotificationCampaignStats> _campaigns = [];

  bool get isAdmin =>
      AppSession.instance.session.role == Role.admin ||
      AppSession.instance.session.role == Role.superAdmin;

  @override
  void initState() {
    super.initState();
    if (isAdmin) {
      _loadCampaigns();
      final userId = AppSession.instance.session.userId;
      if (userId != null) {
        _listenToCampaignStats(userId);
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _userQuery.dispose();
    _division.dispose();
    _credit.dispose();
    _months.dispose();
    _statsSubscription?.call();
    _realtime.disconnect();
    super.dispose();
  }

  void _wrap(String open, String close) {
    final sel = _content.selection;
    final text = _content.text;
    if (!sel.isValid) return;
    final start = sel.start;
    final end = sel.end;
    if (start < 0 || end < 0 || start > end) return;
    final before = text.substring(0, start);
    final mid = text.substring(start, end);
    final after = text.substring(end);
    final next = before + open + mid + close + after;
    _content.text = next;
    _content.selection = TextSelection.collapsed(offset: (before + open + mid + close).length);
    setState(() {});
  }

  Future<void> _send() async {
    setState(() {
      sending = true;
      status = null;
    });
    try {
      final payload = {
        'mode': mode,
        'userQuery': _userQuery.text.trim(),
        'divisionName': _division.text.trim(),
        'creditMin': double.tryParse(_credit.text.trim()) ?? 100.0,
        'monthsUnpaidMin': int.tryParse(_months.text.trim()) ?? 2,
      };
      final res = await NotificationService().sendTargeted(
        title: _title.text.trim(),
        contentHtml: _content.text.trim(),
        targeting: payload,
      );
      final campaignRaw = res['campaign'];
      if (campaignRaw is Map) {
        _upsertCampaign(
          NotificationCampaignStats.fromJson(
            Map<String, dynamic>.from(campaignRaw),
          ),
        );
      } else {
        await _loadCampaigns();
      }
      setState(() {
        status =
            'Sent to ${res['sentCount'] ?? res['sent'] ?? 'N/A'} recipients.';
      });
    } catch (e) {
      setState(() {
        status = 'Error: $e';
      });
    } finally {
      setState(() {
        sending = false;
      });
    }
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      loadingCampaigns = true;
      campaignsError = null;
    });
    try {
      final campaigns = await NotificationService().getCampaigns(mineOnly: false);
      if (!mounted) return;
      setState(() {
        _campaigns = campaigns;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        campaignsError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        loadingCampaigns = false;
      });
    }
  }

  Future<void> _listenToCampaignStats(int userId) async {
    try {
      await _realtime.connect();
      _statsSubscription = await _realtime.subscribeCampaignStats(userId, (stats) {
        if (!mounted) return;
        setState(() {
          _upsertCampaign(stats);
        });
      });
    } catch (_) {}
  }

  void _upsertCampaign(NotificationCampaignStats stats) {
    final index = _campaigns.indexWhere((item) => item.id == stats.id);
    if (index >= 0) {
      _campaigns[index] = stats;
    } else {
      _campaigns.insert(0, stats);
    }
    _campaigns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  InputDecoration _buildInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 20),
            )
          : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF14B8A6),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formContent = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Targeting section
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipient Targeting',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: mode,
                    decoration: _buildInputDecoration(
                      'Select Target Group',
                      icon: Icons.people,
                    ),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'USER',
                        child: Text('Single user (name/email)'),
                      ),
                      DropdownMenuItem(
                        value: 'DIVISION',
                        child: Text('Division broadcast'),
                      ),
                      DropdownMenuItem(
                        value: 'CREDIT',
                        child: Text('Credit / unpaid threshold'),
                      ),
                      DropdownMenuItem(
                        value: 'NEW',
                        child: Text('New participants'),
                      ),
                      DropdownMenuItem(
                        value: 'ACTIVE',
                        child: Text('Active (attended since X months)'),
                      ),
                      DropdownMenuItem(
                        value: 'INACTIVE',
                        child: Text('Inactive (no attendance since X months)'),
                      ),
                    ],
                    onChanged: (v) => setState(() => mode = v ?? 'USER'),
                  ),
                  const SizedBox(height: 12),
                  if (mode == 'USER')
                    TextField(
                      controller: _userQuery,
                      decoration: _buildInputDecoration(
                        'User name or email',
                        icon: Icons.person,
                      ),
                    ),
                  if (mode == 'DIVISION')
                    TextField(
                      controller: _division,
                      decoration: _buildInputDecoration(
                        'Division name',
                        icon: Icons.category,
                      ),
                    ),
                  if (mode == 'CREDIT')
                    Column(
                      children: [
                        TextField(
                          controller: _credit,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            'Min unpaid (DT)',
                            icon: Icons.payments,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _months,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            'Min unpaid months',
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                  if (mode == 'NEW' || mode == 'ACTIVE' || mode == 'INACTIVE')
                    TextField(
                      controller: _months,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(
                        'Months (X)',
                        icon: Icons.calendar_today,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Message content section
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _title,
                    decoration: _buildInputDecoration(
                      'Notification Title',
                      icon: Icons.text_fields,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Formatting toolbar
                  Text(
                    'Message Formatting',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _wrap('<b>', '</b>'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF14B8A6).withOpacity(0.18),
                            foregroundColor: const Color(0xFF14B8A6),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Bold', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _wrap('<u>', '</u>'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.withOpacity(0.18),
                            foregroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Underline',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _wrap(
                              '<span style="color:#e74c3c">', '</span>'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFEF4444).withOpacity(0.18),
                            foregroundColor: const Color(0xFFEF4444),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Red', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _wrap(
                              '<span style="color:#27ae60">', '</span>'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF22C55E).withOpacity(0.18),
                            foregroundColor: const Color(0xFF22C55E),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                          const Text('Green', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _content,
                    minLines: 6,
                    maxLines: 12,
                    decoration: InputDecoration(
                      labelText: 'Message (HTML supported)',
                      hintText:
                      'Example: Hello <b>team</b> <span style="color:#3498db">blue</span>',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF14B8A6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            SoftCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor:
                      const Color(0xFF14B8A6).withOpacity(0.5),
                    ),
                    icon: sending
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                        : const Icon(Icons.send, size: 18),
                    label: Text(
                      sending ? 'Sending' : 'Send Notification',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: status!.startsWith('Error')
                            ? Colors.red.withOpacity(0.15)
                            : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: status!.startsWith('Error')
                              ? Colors.red.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status!.startsWith('Error')
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            color: status!.startsWith('Error')
                                ? Colors.red
                                : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              status!,
                              style: TextStyle(
                                color: status!.startsWith('Error')
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            SoftCard(
              padding: const EdgeInsets.all(16),
              child: _buildCampaignsSection(context),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (!isAdmin) {
      if (widget.embedded) {
        return const Center(child: Text('Admin only'));
      }

      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text('Send Notification'),
          ),
          body: const Center(
            child: Text('Admin only'),
          ),
        ),
      );
    }

    if (widget.embedded) {
      return formContent;
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text('Broadcast Notification'),
          centerTitle: false,
        ),
        body: formContent,
      ),
    );
  }

  Widget _buildCampaignsSection(BuildContext context) {
    final visibleCampaigns = _campaigns.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Delivery Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Refresh campaigns',
              onPressed: loadingCampaigns ? null : _loadCampaigns,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Track how many recipients received and opened each broadcast in real time.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        if (loadingCampaigns)
          const Center(child: CircularProgressIndicator())
        else if (campaignsError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              campaignsError!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          )
        else if (visibleCampaigns.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No campaigns yet. Send your first notification to start measuring reach and reads.',
              style: TextStyle(color: Colors.white.withOpacity(0.72)),
            ),
          )
        else
          ...visibleCampaigns.map(
            (campaign) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _campaignCard(context, campaign),
            ),
          ),
      ],
    );
  }

  Widget _campaignCard(BuildContext context, NotificationCampaignStats campaign) {
    final progress = (campaign.readPercentage.clamp(0, 100) / 100).toDouble();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      campaign.audienceSummary.isEmpty
                          ? campaign.targetingMode
                          : campaign.audienceSummary,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${campaign.readPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Color(0xFF14B8A6),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (campaign.contentPreview.isNotEmpty)
            Text(
              campaign.contentPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                height: 1.35,
              ),
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF14B8A6)),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _campaignMetric('Recipients', '${campaign.totalRecipients}'),
              _campaignMetric('Read', '${campaign.readCount}'),
              _campaignMetric('Unread', '${campaign.unreadCount}'),
              _campaignMetric('Sent', _formatDate(campaign.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campaignMetric(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          TextSpan(text: label),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('dd MMM ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· HH:mm').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }
}


