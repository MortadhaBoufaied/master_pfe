import 'package:flutter/material.dart';

import '../../../../models/player.dart';
import '../../../../services/PlayerServices.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/backend_image.dart';

class FootballerDetailsScreen extends StatefulWidget {
  final int playerId;
  final bool isCurrentUser;

  const FootballerDetailsScreen({
    Key? key,
    required this.playerId,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  State<FootballerDetailsScreen> createState() =>
      _FootballerDetailsScreenState();
}

class _FootballerDetailsScreenState extends State<FootballerDetailsScreen> {
  Player? _player;
  bool _loading = true;
  String? _error;

  final PlayerService _playerService = PlayerService();

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final player = await _playerService.getPlayerById(widget.playerId);

      if (!mounted) return;

      setState(() {
        _player = player;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });

      debugPrint('Failed to load player: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _LoadingScreen();
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: _ErrorState(
            message: _error!,
            onRetry: _loadPlayer,
          ),
        ),
      );
    }

    if (_player == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: Text('Athlete not found'),
        ),
      );
    }

    final player = _player!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        color: AppTheme.teal,
        onRefresh: _loadPlayer,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                player: player,
                isCurrentUser: widget.isCurrentUser,
                onBack: () => Navigator.of(context).maybePop(),
                onRefresh: _loadPlayer,
              ),
            ),
            SliverToBoxAdapter(
              child: _ProfileContent(
                player: player,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.teal,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Player player;
  final bool isCurrentUser;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _ProfileHeader({
    required this.player,
    required this.isCurrentUser,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final name = _clean(player.nom, fallback: 'Unknown Athlete');
    final position = _clean(player.position, fallback: 'Athlete');
    final division = _clean(player.divisionName, fallback: 'Academy');
    final number = _formatNumber(player.number);
    final rating = _toDouble(player.rating);
    final matches = _toInt(player.matches);
    final goals = _toInt(player.goals);
    final assists = _toInt(player.assists);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF07120E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
                Expanded(
                  child: Text(
                    isCurrentUser ? 'My Profile' : 'Athlete Profile',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _HeaderIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 26),
            BackendAvatar(
              pathOrUrl: player.imageUrl,
              radius: 54,
              initials: _initialsFromName(name),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$position • $division',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (number != '-') ...[
              const SizedBox(height: 8),
              Text(
                '#$number',
                style: const TextStyle(
                  color: Color(0xFFE6FF00),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _HeaderStats(
              rating: rating,
              matches: matches,
              goals: goals,
              assists: assists,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _HeaderStats extends StatelessWidget {
  final double rating;
  final int matches;
  final int goals;
  final int assists;

  const _HeaderStats({
    required this.rating,
    required this.matches,
    required this.goals,
    required this.assists,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderStatItem(
          label: 'Rating',
          value: rating > 0 ? rating.toStringAsFixed(1) : '-',
          color: const Color(0xFFE6FF00),
        ),
        _HeaderStatItem(
          label: 'Matches',
          value: '$matches',
          color: const Color(0xFF61A5FF),
        ),
        _HeaderStatItem(
          label: 'Goals',
          value: '$goals',
          color: AppTheme.teal,
        ),
        _HeaderStatItem(
          label: 'Assists',
          value: '$assists',
          color: const Color(0xFFFFB84D),
        ),
      ],
    );
  }
}

class _HeaderStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeaderStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Player player;

  const _ProfileContent({
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final matches = _toInt(player.matches);
    final goals = _toInt(player.goals);
    final assists = _toInt(player.assists);
    final rating = _toDouble(player.rating);

    final age = _formatValue(player.age);
    final height = _formatValue(player.height, suffix: ' cm');
    final weight = _formatValue(player.weight, suffix: ' kg');

    final goalContribution = matches <= 0
        ? '-'
        : ((goals + assists) / matches).toStringAsFixed(2);

    final ratingProgress = (rating / 10).clamp(0.0, 1.0);
    final contributionProgress = matches <= 0
        ? 0.0
        : ((goals + assists) / matches).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Overview',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _DataRow(
            label: 'Full name',
            value: _clean(player.nom, fallback: 'Not available'),
          ),
          _DataRow(
            label: 'Division',
            value: _clean(player.divisionName, fallback: 'Academy'),
          ),
          _DataRow(
            label: 'Position',
            value: _clean(player.position, fallback: 'Not defined'),
          ),
          _DataRow(
            label: 'Number',
            value: _formatNumber(player.number) == '-'
                ? 'Not assigned'
                : '#${_formatNumber(player.number)}',
          ),
          _DataRow(
            label: 'Nationality',
            value: _clean(player.nationalite, fallback: 'Not available'),
            showDivider: false,
          ),
          const SizedBox(height: 28),

          _SectionTitle(
            title: 'Performance',
            icon: Icons.query_stats_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Matches',
                  value: '$matches',
                  color: const Color(0xFF61A5FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Goals',
                  value: '$goals',
                  color: AppTheme.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Assists',
                  value: '$assists',
                  color: const Color(0xFFFFB84D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressLine(
            label: 'Rating',
            value: rating > 0 ? '${rating.toStringAsFixed(1)} / 10' : 'N/A',
            progress: ratingProgress,
            color: const Color(0xFFE6B800),
          ),
          const SizedBox(height: 14),
          _ProgressLine(
            label: 'Goal contribution',
            value: goalContribution == '-' ? 'N/A' : '$goalContribution / match',
            progress: contributionProgress,
            color: AppTheme.teal,
          ),
          const SizedBox(height: 28),

          _SectionTitle(
            title: 'Physical',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Age',
                  value: age,
                  color: const Color(0xFF61A5FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Height',
                  value: height,
                  color: AppTheme.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Weight',
                  value: weight,
                  color: const Color(0xFFFFB84D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          _SectionTitle(
            title: 'Contact',
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 12),
          _DataRow(
            label: 'Email',
            value: _clean(player.email, fallback: 'No email provided'),
          ),
          _DataRow(
            label: 'Phone',
            value: _clean(player.tel, fallback: 'No phone provided'),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.teal,
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF07152B),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _DataRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7B8794),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF07152B),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE4E9EF),
          ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5E6A78),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _ProgressLine({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF07152B),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: safeProgress,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.13),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF07152B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7B8794),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _clean(dynamic value, {required String fallback}) {
  if (value == null) return fallback;

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') {
    return fallback;
  }

  return text;
}

String _formatValue(dynamic value, {String suffix = ''}) {
  if (value == null) return '-';

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') {
    return '-';
  }

  return '$text$suffix';
}

String _formatNumber(dynamic value) {
  if (value == null) return '-';

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') {
    return '-';
  }

  return text;
}

int _toInt(dynamic value) {
  if (value == null) return 0;

  if (value is int) return value;

  if (value is double) return value.toInt();

  if (value is num) return value.toInt();

  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;

  if (value is double) return value;

  if (value is int) return value.toDouble();

  if (value is num) return value.toDouble();

  return double.tryParse(value.toString()) ?? 0.0;
}

String _initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.isEmpty || parts.first.isEmpty) {
    return '?';
  }

  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }

  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}