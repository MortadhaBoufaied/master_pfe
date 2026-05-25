import 'package:flutter/material.dart';

import '../../../../../../controllers/PlayerController.dart';
import '../../../../../../models/player.dart';

class PlayerDataScreen extends StatefulWidget {
  final String userId;
  const PlayerDataScreen({super.key, required this.userId});

  @override
  State<PlayerDataScreen> createState() => _PlayerDataScreenState();
}

class _PlayerDataScreenState extends State<PlayerDataScreen> {
  final PlayerController _playerController = PlayerController();
  Player? _player;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    setState(() => _isLoading = true);
    try {
      final player = await _playerController.getPlayerById(
          int.parse(widget.userId));
      setState(() => _player = player);
    } catch (e) {
      debugPrint('Error loading player: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading player data')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoTile(String title, String? value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value ?? '', style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
    elevation: 0,
        title: const Text('Player Profile'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayer,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _player == null
          ? const Center(child: Text('No player data found.'))
          : RefreshIndicator(
        onRefresh: _loadPlayer,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: (_player!.imageUrl != null &&
                    _player!.imageUrl!.isNotEmpty)
                    ? NetworkImage(_player!.imageUrl!)
                    : const AssetImage(
                    'assets/default_player.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _player!.nom ?? '',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                _player!.position ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Personal Information'),
            _buildInfoTile('Email', _player!.email),
            _buildInfoTile('Phone', _player!.tel),
            _buildInfoTile('Date of Birth', _player!.dateNaissance),
            _buildInfoTile('Nationality', _player!.nationalite),
            _buildInfoTile('Age', _player!.age?.toString()),
            _buildInfoTile('Height (cm)', _player!.height?.toString()),
            _buildInfoTile('Weight (kg)', _player!.weight?.toString()),

            _buildSectionTitle('Team Information'),
            _buildInfoTile('Division', _player!.divisionName),
            _buildInfoTile('Jersey Number', _player!.number?.toString()),
            _buildInfoTile('Position', _player!.position),

            _buildSectionTitle('Performance Statistics'),
            _buildInfoTile('Matches Played', _player!.matches?.toString()),
            _buildInfoTile('Goals', _player!.goals?.toString()),
            _buildInfoTile('Assists', _player!.assists?.toString()),
            _buildInfoTile('Rating', _player!.rating?.toStringAsFixed(2)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


