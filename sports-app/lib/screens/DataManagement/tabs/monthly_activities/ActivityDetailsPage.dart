import 'package:flutter/material.dart';
import 'package:moez_project/components/NavigationLink.dart';
import '../../../../models/activity.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsPage({Key? key, required this.activity}) : super(key: key);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(activity.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            if (activity.date.isNotEmpty) Chip(label: Text('  ${activity.date}')),
            const SizedBox(width: 8),
            if (activity.lieu != null && activity.lieu!.isNotEmpty) Chip(label: Text(': ${activity.lieu}')),
          ]),
          const SizedBox(height: 16),
          Text('', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
          const SizedBox(height: 8),
          Text(activity.description ?? '-'),
        ]),
      ),
    );
  }
}


