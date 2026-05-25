import 'package:flutter/material.dart';

/// Shared popup dialog with a consistent design.
///
/// Hotfix: accepts an optional [accent] color to stay compatible with older calls
/// that used `accent: Colors.teal`.
class PopupDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;

  /// Optional accent override (defaults to Theme.primary).
  final Color? accent;

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData icon;

  const PopupDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.accent,
    this.primaryLabel = 'OK',
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color acc = accent ?? cs.primary;
    final bg = isDark ? cs.surface : Colors.white;
    final border = cs.outline.withOpacity(isDark ? 0.25 : 0.18);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: acc.withOpacity(isDark ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: acc),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(Icons.close, color: cs.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (message != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.78),
                      height: 1.35,
                    ),
                  ),
                ),
              if (content != null) ...[
                const SizedBox(height: 10),
                content!,
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  if (secondaryLabel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSecondary ?? () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(secondaryLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  if (secondaryLabel != null) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimary ?? () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acc,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(primaryLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


