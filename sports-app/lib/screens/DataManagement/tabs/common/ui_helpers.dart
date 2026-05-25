import 'package:flutter/material.dart';

Future<bool> confirmDelete(
    BuildContext context, {
      required String title,
      required String message,
    }) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return res == true;
}

EdgeInsets bottomSheetPadding(BuildContext context) {
  return EdgeInsets.only(
    left: 16,
    right: 16,
    top: 16,
    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
  );
}

void showSnack(BuildContext context, String msg) {
  // Clear any existing snackbars to avoid stacking
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}


