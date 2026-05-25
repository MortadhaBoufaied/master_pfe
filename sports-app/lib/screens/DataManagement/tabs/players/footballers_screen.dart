import 'package:flutter/material.dart';
import '../../../../controllers/PlayerController.dart';
import '../../../../models/player.dart';
import 'footballer_details_screen.dart';

class InlineFootballersList extends StatefulWidget {
  final List<Player>? players;
  final double itemWidth;
  final bool autoLoad;
  final int? divisionId;

  const InlineFootballersList({
    Key? key,
    this.players,
    this.itemWidth = 140,
    this.autoLoad = true,
    this.divisionId,
  }) : super(key: key);

  @override
  State<InlineFootballersList> createState() => _InlineFootballersListState();
}

class _InlineFootballersListState extends State<InlineFootballersList> {
  final PlayerController _controller = PlayerController();
  List<Player> _players = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.players != null) {
      _players = widget.players!;
    } else if (widget.autoLoad) {
      _loadPlayers();
    }
  }

  Future<void> _loadPlayers() async {
    setState(() => _loading = true);
    try {
      if (widget.divisionId != null) {
        _players = await _controller.loadPlayersByDivision(widget.divisionId!);
      } else {
        await _controller.loadPlayers();
        _players = _controller.players;
      }
    } catch (e) {
      debugPrint('Failed loading players: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed loading players')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openDetails(Player player) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FootballerDetailsScreen(playerId: player.id),
      ),
    );

    if (result == true) {
      _loadPlayers();
    }
  }

  Widget _miniStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _item(Player p) {
    return GestureDetector(
      onTap: () => _openDetails(p),
      child: Container(
        width: widget.itemWidth,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                  ? NetworkImage(p.imageUrl!)
                  : const AssetImage(
                  'assets/default_player.png') as ImageProvider,
            ),
            const SizedBox(height: 8),
            Text(
              p.nom ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              p.position ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniStat(Icons.sports_soccer, (p.goals ?? 0).toString()),
                const SizedBox(width: 6),
                _miniStat(Icons.assessment, (p.matches ?? 0).toString()),
                const SizedBox(width: 6),
                _miniStat(Icons.group_add, (p.assists ?? 0).toString()),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_players.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No players to show'),
              const SizedBox(height: 8),
              if (widget.players == null)
                TextButton.icon(
                  onPressed: _loadPlayers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _players.length,
          padding: const EdgeInsets
          .
          symmetric
          (
          horizontal
          :
          12),
      itemBuilder: (context, index) => _item(_players[index]),
    ),);
  }
}


