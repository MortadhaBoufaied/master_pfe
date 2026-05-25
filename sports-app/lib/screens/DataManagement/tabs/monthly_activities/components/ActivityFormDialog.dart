import 'package:flutter/material.dart';
import '../../../../../models/activity.dart';

class ActivityFormDialog extends StatefulWidget {
  final Activity? activity; // null => create
  final Function(Activity) onSave;

  const ActivityFormDialog({
    Key? key,
    this.activity,
    required this.onSave,
  }) : super(key: key);

  @override
  _ActivityFormDialogState createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController; // display only
  late final TextEditingController _lieuController;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _titreController = TextEditingController(text: widget.activity?.titre ?? '');
    _descriptionController =
        TextEditingController(text: widget.activity?.description ?? '');
    _dateController = TextEditingController(); // filled from DateTime
    _lieuController = TextEditingController(text: widget.activity?.lieu ?? '');

    if (widget.activity != null) {
      _selectedDate = _parseDate(widget.activity!.date); // <-- date is String
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  /// Supports:
  /// - "2025-12-28"
  /// - "2025-12-28T10:20:30.000"
  DateTime? _parseDate(String? value) {
    if (value == null) return null;
    final v = value.trim();
    if (v.isEmpty) return null;

    // Try normal parse first
    final parsed = DateTime.tryParse(v);
    if (parsed != null) return parsed;

    // If it's like "yyyy-MM-dd" but parse failed for some reason:
    // Try manual split
    try {
      final parts = v.split('-');
      if (parts.length >= 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2].substring(0, 2));
        return DateTime(y, m, d);
      }
    } catch (_) {}

    return null;
  }

  String _formatToYmd(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  String _formatForDisplay(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatForDisplay(context, picked);
      });
    }
  }

  void _saveAndClose() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;

    final act = Activity(
      id: widget.activity?.id ?? 0,
      titre: _titreController.text.trim(),
      description: _descriptionController.text.trim(),

      date: _formatToYmd(_selectedDate!), // e.g. "2025-12-28"

      lieu: _lieuController.text.trim(),
      trainerId: widget.activity?.trainerId,
    );

    widget.onSave(act);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    final keyboardH = MediaQuery.of(context).viewInsets.bottom;

    final contentHeight = screenH * 0.55;

    if (_selectedDate != null && _dateController.text.isEmpty) {
      _dateController.text = _formatForDisplay(context, _selectedDate!);
    }

    return AlertDialog(
      title: Text(widget.activity == null ? 'Create Activity' : 'Edit Activity'),

      content: SizedBox(
        height: contentHeight,
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titreController,
                  decoration: const InputDecoration(
                    labelText: 'Title (titre)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _pickDate,
                    ),
                  ),
                  onTap: _pickDate,
                  validator: (_) => _selectedDate == null ? 'Date is required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _lieuController,
                  decoration: const InputDecoration(
                    labelText: 'Location (lieu)',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveAndClose(),
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAndClose,
          child: const Text('Save'),
        ),
      ],
    );
  }
}


