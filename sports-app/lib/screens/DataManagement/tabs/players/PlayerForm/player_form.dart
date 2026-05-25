import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moez_project/components/NavigationLink.dart';

import '../../../../../models/player.dart';
import '../../../../../services/PlayerServices.dart';
import '../../../../../services/admin_users_service.dart';
import '../../../../../models/admin_user.dart';
import '../../../../../services/file_service.dart';

import 'components/player_form_controller.dart';
import 'components/football_info_step.dart';
import 'components/image_step.dart';
import 'components/StepOfPersonalInfo.dart';

class PlayerForm extends StatefulWidget {
  final String? divisionId; // nullable
  final String? playerId;

  const PlayerForm({
    Key? key,
    this.divisionId,
    this.playerId,
  }) : super(key: key);

  @override
  State<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  final PageController _pageController = PageController();
  final PlayerFormController _controller = PlayerFormController();

  final PlayerService _playerService = PlayerService();
  final AdminUsersService _adminUsers = AdminUsersService();
  final FileService _fileService = FileService();

  int _currentPage = 0;
  bool _isSaving = false;

  File? _playerImageFile;
  String? _existingPlayerImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.playerId != null) {
      _loadPlayer();
    }
  }

  Future<void> _loadPlayer() async {
    try {
      final Player? player = await _playerService.getPlayerById(int.parse(widget.playerId!));
      if (player == null) return;
      setState(() {
        _controller.nomController.text = player.nom ?? '';
        _controller.dateNaissanceController.text = player.dateNaissance ?? '';
        _controller.telController.text = player.tel ?? '';
        _controller.emailController.text = player.email ?? '';
        _controller.nationaliteController.text = player.nationalite ?? '';
        _controller.ageController.text = player.age?.toString() ?? '';
        _controller.position = player.position;
        _controller.number = player.number;
        _controller.heightController.text = player.height?.toString() ?? '';
        _controller.weightController.text = player.weight?.toString() ?? '';
        _existingPlayerImageUrl = player.imageUrl;
        _controller.imageUrl = player.imageUrl;
      });
    } catch (e) {
      debugPrint('Error loading player: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _controller.dateNaissanceController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }


  Future<void> _savePlayer(BuildContext context) async {
    setState(() => _isSaving = true);

    AdminUser? createdUser; // rollback if player create fails

    try {
      // Prepare image (if a local path was chosen)
      final maybeLocalPath = _controller.imageUrl;
      if (maybeLocalPath != null && File(maybeLocalPath).existsSync()) {
        _playerImageFile = File(maybeLocalPath);
      }
      if (_playerImageFile != null) {
        final uploaded = await _fileService.uploadFile(_playerImageFile!, folder: 'players');
        if (uploaded != null) {
          _controller.imageUrl = uploaded.id;
        }
      }

      if (widget.playerId == null) {
        // 1) Create base User first (role PLAYER)
        createdUser = await _adminUsers.createUser(
          nom: _controller.nomController.text.trim(),
          email: _controller.emailController.text.trim(),
          password: _controller.passwordController.text.trim(),
          role: 'PLAYER',
        );
        if (createdUser == null) {
          throw Exception('User signup failed (email may already exist)');
        }

        final int? divId = (widget.divisionId == null || widget.divisionId!.isEmpty)
            ? null
            : int.tryParse(widget.divisionId!);

        // 2) Create Player linked to that User (MapsId on backend)
        final payload = <String, dynamic>{
          'user': {'id': createdUser.id},
          'position': _controller.position,
          'age': int.tryParse(_controller.ageController.text.trim()),
          'nationality': _controller.nationaliteController.text.trim().isEmpty
              ? null
              : _controller.nationaliteController.text.trim(),
          'phone': _controller.telController.text.trim().isEmpty
              ? null
              : _controller.telController.text.trim(),
          'imageUrl': _controller.imageUrl,
          'height': double.tryParse(_controller.heightController.text.trim()),
          'weight': double.tryParse(_controller.weightController.text.trim()),
          if (divId != null) 'division': {'id': divId},
        };

        final created = await _playerService.createPlayer(payload);
        if (created != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player created successfully')),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to create player');
        }
      } else {
        // Update existing player
        final int? divId = (widget.divisionId == null || widget.divisionId!.isEmpty)
            ? null
            : int.tryParse(widget.divisionId!);

        final payload = <String, dynamic>{
          'position': _controller.position,
          'age': int.tryParse(_controller.ageController.text.trim()),
          'nationality': _controller.nationaliteController.text.trim().isEmpty
              ? null
              : _controller.nationaliteController.text.trim(),
          'phone': _controller.telController.text.trim().isEmpty
              ? null
              : _controller.telController.text.trim(),
          'imageUrl': _controller.imageUrl,
          'height': double.tryParse(_controller.heightController.text.trim()),
          'weight': double.tryParse(_controller.weightController.text.trim()),
          if (divId != null) 'division': {'id': divId},
        };

        final ok = await _playerService.updatePlayer(
          playerId: int.parse(widget.playerId!),
          data: payload,
        );
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player updated successfully')),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to update player');
        }
      }
    } catch (e) {
      // rollback user if created but player failed
      if (widget.playerId == null && createdUser?.id != null) {
        try {
          await _adminUsers.deleteUser(createdUser!.id!);
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving player: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildStepper() {
    final steps = ['Personal', 'Football', 'Image'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(steps.length, (i) {
          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _currentPage == i ? Colors.teal : Colors.grey.shade400,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 12,
                    color: _currentPage == i ? Colors.teal : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationControls() {
    final lastPage = 2;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == 0 ? Colors.grey : Colors.teal,
            ),
            child: const Text('Back', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : (_currentPage < lastPage
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : () => _savePlayer(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == lastPage ? Colors.green : Colors.teal,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _currentPage == lastPage ? 'Save' : 'Next',
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TopNavigationBar(
        title: '',
        onSearchTap: () => Navigator.pushNamed(context, '/global-search'),
        showLogo: true,
        onNotificationTap: () => Navigator.pushNamed(context, '/notifications'), // <-- add this

      ),
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Column(
          children: [
            _buildStepper(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  PlayerPersonalInfoStep(
                    onDateSelected: () => _selectDate(context),
                    controller: _controller,
                    isCreate: widget.playerId == null,
                  ),
                  FootballInfoStep(controller: _controller),
                  PlayerImageStep(
                    controller: _controller,
                    existingPlayerImageUrl: _existingPlayerImageUrl,
                  ),
                ],
              ),
            ),
            _buildNavigationControls(),
          ],
        ),
      ),
    );
  }
}


