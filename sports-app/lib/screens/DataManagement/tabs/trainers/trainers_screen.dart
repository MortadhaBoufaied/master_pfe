import 'package:flutter/material.dart';

import '../../../../models/trainer.dart';
import '../../../../services/trainer_service.dart';
import '../../../../theme/app_theme.dart';
import 'trainerDetails.dart';

class TrainersScreen extends StatefulWidget {
  final String divisionId;

  const TrainersScreen({super.key, required this.divisionId});

  @override
  State<TrainersScreen> createState() => _InlineTrainersListState();
}

class _InlineTrainersListState extends State<TrainersScreen> {
  final TrainerService _service = TrainerService();
  bool _loading = true;
  String? _error;
  List<Trainer> _trainers = [];

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
      final divisionId = int.tryParse(widget.divisionId);
      final all = await _service.getAllTrainers();
      _trainers =
          divisionId == null
              ? all
              : all
                  .where((trainer) => trainer.divisionId == divisionId)
                  .toList();
    } catch (e) {
      _error = e.toString();
      _trainers = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.surface.withOpacity(0.96),
            cs.surfaceVariant.withOpacity(0.72),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          children: [
            Text(
              'Division trainers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Division ${widget.divisionId}',
              style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.teal),
                ),
              )
            else if (_error != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: const Text('Could not load trainers'),
                  subtitle: Text(_error!),
                ),
              )
            else if (_trainers.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.sports, color: AppTheme.teal),
                  title: Text('No trainers assigned'),
                  subtitle: Text(
                    'Assign a trainer to this division to show them here.',
                  ),
                ),
              )
            else
              ..._trainers.map(_trainerCard),
          ],
        ),
      ),
    );
  }

  Widget _trainerCard(Trainer trainer) {
    final name = _value(trainer.name, fallback: 'Trainer');
    final subtitle = [
      _value(trainer.specialty),
      _value(trainer.email),
    ].where((item) => item.isNotEmpty && item != '-').join(' - ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.teal.withOpacity(0.14),
          child: Text(
            name.isEmpty ? '?' : name[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.teal,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap:
            trainer.id == null
                ? null
                : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              TrainerDetailsScreen(trainerId: trainer.id!),
                    ),
                  );
                },
      ),
    );
  }

  String _value(String? value, {String fallback = '-'}) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}


