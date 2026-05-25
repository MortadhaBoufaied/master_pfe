import 'package:flutter/material.dart';

import '../../models/admin/admin_module.dart';
import 'admin_module_screen.dart';

export '../../models/admin/admin_module.dart' show AdminWebRole;

/// Compatibility wrapper kept for existing routes/imports.
/// The heavy generated registry was removed and split into:
/// - models/admin/admin_module.dart
/// - data/admin/admin_module_catalog.dart
/// - screens/admin/admin_module_screen.dart
/// - screens/admin/widgets/admin_module_widgets.dart
class AdminWebParityScreen extends AdminModuleScreen {
  const AdminWebParityScreen({
    super.key,
    required String moduleKey,
    required AdminWebRole role,
    bool embedded = false,
  }) : super(moduleKey: moduleKey, role: role, embedded: embedded);
}


