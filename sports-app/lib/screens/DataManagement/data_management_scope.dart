// lib/screens/DataManagement/data_management_scope.dart
import 'package:flutter/material.dart';
import '../../controllers/dataManagementController.dart';

/// Inherited scope for Data Management.
/// Exposes a [DataManagementController] and notifies dependents on changes.
class DataManagementScope extends InheritedNotifier<DataManagementController> {
  const DataManagementScope({
    Key? key,
    required DataManagementController controller,
    required Widget child,
  }) : super(key: key, notifier: controller, child: child);

  /// Safe lookup (returns null when the scope is absent).
  static DataManagementController? maybeOf(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<DataManagementScope>();
    return scope?.notifier;
  }

  /// Strict lookup (throws a friendly assertion when absent).
  static DataManagementController of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<DataManagementScope>();
    assert(
    scope != null,
    'DataManagementScope not found in widget tree. '
        'Wrap your screen with DataManagementScope or navigate via the '
        '"/data-management" route that already installs the scope.',
    );
    return scope!.notifier!;
  }
}


