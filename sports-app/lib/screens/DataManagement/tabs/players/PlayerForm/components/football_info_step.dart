import 'package:flutter/material.dart';
import 'player_form_controller.dart';

class FootballInfoStep extends StatefulWidget {
  final PlayerFormController controller;
  const FootballInfoStep({Key? key, required this.controller}) : super(key: key);

  @override
  State<FootballInfoStep> createState() => _FootballInfoStepState();
}

class _FootballInfoStepState extends State<FootballInfoStep> {
  // Distinct, non-empty set of positions
  static const List<String> positions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Forward',
  ];

  @override
  Widget build(BuildContext context) {
    // Validate current value against positions
    final String? currentValue = positions.contains(widget.controller.position)
        ? widget.controller.position
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: currentValue,
            decoration: const InputDecoration(
              labelText: 'Position',
              border: OutlineInputBorder(),
            ),
            items: positions
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => widget.controller.position = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: widget.controller.number?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => widget.controller.number = int.tryParse(v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.controller.heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.controller.weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}


