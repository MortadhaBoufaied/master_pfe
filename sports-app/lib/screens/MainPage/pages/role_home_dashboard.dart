library role_home_dashboard;

import 'package:flutter/material.dart';

import '../../../components/modern_design_system.dart';
import '../../../controllers/session_controller.dart';
import '../../../models/division.dart';
import '../../../models/player.dart';
import '../../../models/role.dart';
import '../../../services/PlayerServices.dart';
import '../../../services/academy_ranking_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../services/division_service.dart';
import '../../../services/player_ranking_service.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/backend_image.dart';
import '../../DataManagement/tabs/players/footballer_details_screen.dart';
import 'history.dart';

part 'home_components/home_models.dart';
part 'home_components/home_helpers.dart';
part 'home_components/home_background.dart';
part 'home_components/home_header.dart';
part 'home_components/home_quick_links_bar.dart';
part 'home_components/home_academy_rankings_section.dart';
part 'home_components/home_top_players_section.dart';
part 'home_components/home_role_sections.dart';
part 'home_components/home_shared_widgets.dart';

class RoleHomeDashboard extends StatefulWidget {
  final VoidCallback onContactPressed;

  const RoleHomeDashboard({
    super.key,
    required this.onContactPressed,
  });

  @override
  State<RoleHomeDashboard> createState() => _RoleHomeDashboardState();
}

class _RoleHomeDashboardState extends State<RoleHomeDashboard> {
  final DashboardService _dashboardService = DashboardService();
  final DivisionService _divisionService = DivisionService();
  final PlayerRankingService _playerRankingService = PlayerRankingService();
  final PlayerService _playerService = PlayerService();
  final AcademyRankingService _academyRankingService = AcademyRankingService();

  bool _dashboardLoading = true;
  bool _topPlayersLoading = true;
  bool _academyRankingsLoading = true;
  bool _isIntroExpanded = false;

  String? _dashboardError;
  String? _topPlayersError;
  String? _academyRankingsError;

  Map<String, dynamic>? _dashboardData;
  List<Division> _divisions = const [];
  List<_TopPlayerCardData> _topPlayers = const [];
  List<AcademyRanking> _academyRankings = const [];
  int? _selectedDivisionId;

  static const double _pageHorizontalPadding = 12;
  static const double _topPlayerCardWidth = 174;
  static const double _topPlayerListHeight = 176;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadDashboard(),
      _loadTopPlayers(),
      _loadAcademyRankings(),
    ]);
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;

    setState(() {
      _dashboardLoading = true;
      _dashboardError = null;
    });

    try {
      final session = AppSession.instance.session;

      if (session.role == Role.parent && session.parentId != null) {
        _dashboardData = await _dashboardService.getParentDashboard(
          session.parentId!,
        );
      } else if (session.role == Role.trainer && session.trainerId != null) {
        _dashboardData = await _dashboardService.getTrainerDashboard(
          session.trainerId!,
        );
      } else {
        _dashboardData = null;
      }
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _dashboardLoading = false;
        });
      }
    }
  }

  Future<void> _loadTopPlayers() async {
    if (!mounted) return;

    setState(() {
      _topPlayersLoading = true;
      _topPlayersError = null;
    });

    try {
      final divisions = await _divisionService.getSummaryList();

      final sortedDivisions = [...divisions]
        ..sort(
          (a, b) => a.nom.toLowerCase().compareTo(
                b.nom.toLowerCase(),
              ),
        );

      final sessionDivisionId = AppSession.instance.session.divisionId;
      int? resolvedDivisionId = _selectedDivisionId ?? sessionDivisionId;

      if (resolvedDivisionId != null &&
          !sortedDivisions.any(
            (division) => division.id == resolvedDivisionId,
          )) {
        resolvedDivisionId = null;
      }

      final topPlayers = await _fetchTopPlayers(
        divisionId: resolvedDivisionId,
      );

      if (!mounted) return;

      setState(() {
        _divisions = sortedDivisions;
        _selectedDivisionId = resolvedDivisionId;
        _topPlayers = topPlayers;
        _topPlayersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _divisions = const [];
        _topPlayers = const [];
        _topPlayersLoading = false;
        _topPlayersError = e.toString();
      });
    }
  }

  Future<void> _selectDivision(int? divisionId) async {
    if (_selectedDivisionId == divisionId && !_topPlayersLoading) return;

    setState(() {
      _selectedDivisionId = divisionId;
      _topPlayersLoading = true;
      _topPlayersError = null;
    });

    try {
      final topPlayers = await _fetchTopPlayers(
        divisionId: divisionId,
      );

      if (!mounted) return;

      setState(() {
        _topPlayers = topPlayers;
        _topPlayersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _topPlayers = const [];
        _topPlayersLoading = false;
        _topPlayersError = e.toString();
      });
    }
  }

  Future<List<_TopPlayerCardData>> _fetchTopPlayers({
    int? divisionId,
  }) async {
    final results = await Future.wait<dynamic>([
      _playerRankingService.getTopPlayers(
        limit: 5,
        divisionId: divisionId,
      ),
      divisionId != null
          ? _playerService.getPlayersByDivision(divisionId)
          : _playerService.getAllPlayers(),
    ]);

    final rankings = results[0] as List<PlayerRanking>;
    final players = results[1] as List<Player>;

    final playersById = <int, Player>{
      for (final player in players) player.id: player,
    };

    return rankings
        .map(
          (ranking) => _TopPlayerCardData(
            ranking: ranking,
            player: playersById[ranking.playerId],
            divisionName:
                playersById[ranking.playerId]?.divisionName ??
                    _selectedDivisionName,
          ),
        )
        .toList();
  }

  Future<void> _loadAcademyRankings() async {
    if (!mounted) return;

    setState(() {
      _academyRankingsLoading = true;
      _academyRankingsError = null;
    });

    try {
      final rankings = await _academyRankingService.getTopAcademies(limit: 5);
      if (!mounted) return;
      setState(() {
        _academyRankings = rankings;
        _academyRankingsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _academyRankings = const [];
        _academyRankingsLoading = false;
        _academyRankingsError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance.session;
    final cs = Theme.of(context).colorScheme;

    if (_dashboardLoading && _topPlayersLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.teal,
        ),
      );
    }

    if (session.role == Role.superAdmin) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        this.homeBackground(context),
        RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 110),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              this.homeQuickLinksBar(context, session.role),
              const SizedBox(height: 12),
              this.homeHeader(context, session),
              const SizedBox(height: 14),
              this.academyRankingsSection(context),
              const SizedBox(height: 14),
              this.topPlayersSection(context),
              const SizedBox(height: 18),
              const MatchHistorySection(embedded: true),
              const SizedBox(height: 18),
              if (_dashboardError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _pageHorizontalPadding,
                  ),
                  child: this.surfaceCard(
                    context,
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: cs.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _dashboardError!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: cs.error,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (session.role == Role.parent) this.parentDashboard(context),
              if (session.role == Role.trainer) this.trainerDashboard(context),
              if (session.role == Role.player) this.playerDashboard(context),
              if (session.role == Role.scouter) this.scouterDashboard(context),
            ],
          ),
        ),
      ],
    );
  }
}


