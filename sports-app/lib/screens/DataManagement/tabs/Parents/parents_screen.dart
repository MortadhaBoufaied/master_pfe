import 'package:flutter/material.dart';

import '../../../../controllers/parent_controller.dart';
import '../../../../models/parent.dart';
import '../../../../components/ui_kit.dart';

class ParentsScreen extends StatefulWidget {
  final int divisionId;
  const ParentsScreen({Key? key, required this.divisionId}) : super(key: key);

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  final ParentController _controller = ParentController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.loadAll();
  }

  void _onChanged() => setState(() {});
  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (_controller.error != null)
      return Center(child: Text('Error: ${_controller.error}'));

    final List<Parent> parents = _controller.parents;
    if (parents.isEmpty) return const Center(child: Text('No parents found'));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: parents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final p = parents[i];
        final title = _value(
          p.nom,
          fallback: _value(p.email, fallback: 'Parent profile'),
        );
        final subtitle = [
          _value(p.email),
          _value(p.tel),
          _value(p.address),
        ].where((item) => item.isNotEmpty && item != '-').join(' - ');
        return SoftCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            title: Text(title),
            subtitle: subtitle.isEmpty ? null : Text(subtitle),
            trailing:
                p.tel2 == null || p.tel2!.trim().isEmpty ? null : Text(p.tel2!),
          ),
        );
      },
    );
  }

  String _value(String? value, {String fallback = '-'}) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}


