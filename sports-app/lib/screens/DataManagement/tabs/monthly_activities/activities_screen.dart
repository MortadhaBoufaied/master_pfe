import 'package:flutter/material.dart';
import 'package:moez_project/components/NavigationLink.dart';
import '../../../../controllers/ActivitiesController.dart';
import '../../../../models/activity.dart';
import '../../../../components/ui_kit.dart';
import 'components/ActivityFormDialog.dart';
import 'components/ActivityTable.dart';
import 'ActivityDetailsPage.dart';

class ActivitiesScreen extends StatefulWidget {
  // Keep divisionId on widget for navigation compatibility, but not used in backend calls.
  final String? divisionId;

  const ActivitiesScreen({Key? key, this.divisionId}) : super(key: key);

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final ActivitiesController _controller = ActivitiesController();
  final Map<String, String> _monthNames = {
    '01': '  ',
    '02': '  ',
    '03': '',
    '04': '',
    '05': '',
    '06': '',
    '07': '  ',
    '08': '',
    '09': '',
    '10': '',
    '11': '',
    '12': '',
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            _buildCurrentPlanTab(),
            _buildHistoryTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
            showDialog(
              context: context,
              builder: (context) => ActivityFormDialog(
                onSave: (activity) async {
                  await _controller.addActivity(activity: activity);
                  setState(() {});
                },
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildCurrentPlanTab() {
    final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
    return FutureBuilder<List<Activity>>(
      future: _controller.getActivitiesForMonth(currentMonth),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          final parts = currentMonth.split('-');
          final monthNum = parts.length > 1 ? parts[1] : '01';
          final monthName = _monthNames[monthNum] ?? '  ';
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                Text(
                  '       $monthName ${parts[0]}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ActivityTable(
          controller: _controller,
          activities: activities,
          deleteActivity: (activityId) async {
            await _controller.deleteActivity(activityId: activityId);
            setState(() {});
          },
          monthYear: currentMonth,
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<String>>(
      future: _controller.getMonthlyPlanDates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final months = snapshot.data ?? [];
        if (months.isEmpty) {
          return const Center(
            child: Text('       ', style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: months.length,
          itemBuilder: (context, index) {
            final parts = months[index].split('-');
            final year = parts[0];
            final month = parts.length > 1 ? parts[1] : '01';
            final monthName = _monthNames[month] ?? '  ';

            return SoftCard(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                  child: Text(month, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                ),
                title: Text('$monthName $year', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text('    ', style: TextStyle()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyPlanScreen(
                        month: months[index],
                        controller: _controller,
                        monthNames: _monthNames,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class MonthlyPlanScreen extends StatelessWidget {
  final String month;
  final ActivitiesController controller;
  final Map<String, String> monthNames;

  const MonthlyPlanScreen({
    Key? key,
    required this.month,
    required this.controller,
    required this.monthNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parts = month.split('-');
    final year = parts[0];
    final monthNum = parts.length > 1 ? parts[1] : '01';
    final monthName = monthNames[monthNum] ?? '  ';

    return Scaffold(
    backgroundColor: Colors.transparent,
      appBar: TopNavigationBar(
        onSearchTap: () => Navigator.pushNamed(context, '/global-search'),
        title: '',
        showLogo: true,
        onNotificationTap: () => Navigator.pushNamed(context, '/notifications'), // <-- add this

      ),
      body: FutureBuilder<List<Activity>>(
        future: controller.getActivitiesForMonth(month),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final activities = snapshot.data ?? [];
          if (activities.isEmpty) {
            return Center(child: Text('     $monthName $year', style: const TextStyle()));
          }

          return ActivityTable(
            controller: controller,
            activities: activities,
            deleteActivity: (activityId) async {
              await controller.deleteActivity(activityId: activityId);
            },
            monthYear: month,
          );
        },
      ),
    );
  }
}


