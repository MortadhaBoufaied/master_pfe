import 'package:flutter/material.dart';

import '../../../../components/app_background.dart';
import '../../../../components/ui_kit.dart';
import '../../../../controllers/trainer_controller.dart';
import '../../../../models/trainer.dart';
import '../../../../theme/app_theme.dart';

class TrainerDetailsScreen extends StatefulWidget {
  final int trainerId;
  const TrainerDetailsScreen({super.key, required this.trainerId});

  @override
  State<TrainerDetailsScreen> createState() => _TrainerDetailsScreenState();
}

class _TrainerDetailsScreenState extends State<TrainerDetailsScreen> {
  final TrainerController _controller = TrainerController();
  Trainer? _trainer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _trainer = await _controller.fetchTrainerById(widget.trainerId);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,title: const Text('Trainer Details')),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
            : _trainer == null
            ? const Center(child: Text('Trainer not found', style: TextStyle(color: Colors.white)))
            : ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.sports, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_trainer!.name ?? 'Unknown',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(_trainer!.specialty ?? '-',
                            style: TextStyle(color: Theme.of(context).colorScheme.surface.withOpacity(0.92))),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    _kv('Email', _trainer!.email ?? '-'),
                    _kv('Phone', _trainer!.phone ?? '-'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    _kv('Experience', '${_trainer!.experience ?? '0'} yrs'),
                    _kv('License', _trainer!.license ?? '-'),
                    _kv('Notes', _trainer!.notes ?? '-'),
                    _kv('Division', _trainer!.divisionId?.toString() ?? '-'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(k, style: TextStyle( fontWeight: FontWeight.w700))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}


