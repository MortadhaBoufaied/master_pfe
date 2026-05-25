import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/academy_theme_controller.dart';
import '../utils/backend_url.dart';

/// Shared app background with a subtle stadium surface.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool blur;

  const AppBackground({super.key, required this.child, this.blur = true});

  static bool _hasAncestorBackground(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AppBackgroundScope>() !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    // Avoid stacking the same background multiple times.
    if (_hasAncestorBackground(context)) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final academyTheme = AppAcademyTheme.instance.controller.theme;
    final bannerUrl = BackendUrl.resolve(academyTheme.homeBannerUrl);

    final cs = Theme.of(context).colorScheme;

    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          isDark
              ? const [
                Color(0xFF060817),
                Color(0xFF0D1730),
                Color(0xFF0D312A),
              ]
              : const [
                Color(0xFFF7FAFC),
                Color(0xFFEFF6F5),
                Color(0xFFE7F3F1),
              ],
    );

    final imageOverlay = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors:
          isDark
              ? [
                const Color(0xFF060817).withValues(alpha: 0.84),
                const Color(0xFF071828).withValues(alpha: 0.72),
                const Color(0xFF060817).withValues(alpha: 0.88),
              ]
              : [
                cs.surface.withValues(alpha: 0.94),
                cs.surface.withValues(alpha: 0.90),
                cs.surface.withValues(alpha: 0.96),
              ],
    );

    return _AppBackgroundScope(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: baseGradient),
            ),
          ),

          // Background image (works for both modes).
          Positioned.fill(
            child:
                bannerUrl == null
                    ? Image.asset(
                      'assets/background-image.png',
                      fit: BoxFit.cover,
                    )
                    : Image.network(
                      bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Image.asset(
                            'assets/background-image.png',
                            fit: BoxFit.cover,
                          ),
                    ),
          ),

          // Color overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: imageOverlay),
            ),
          ),

          if (blur)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isDark ? 6 : 3,
                  sigmaY: isDark ? 6 : 3,
                ),
                child: const SizedBox.shrink(),
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _StadiumLinesPainter(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : cs.primary.withValues(alpha: 0.045),
                ),
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}

class _AppBackgroundScope extends InheritedWidget {
  const _AppBackgroundScope({required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class _StadiumLinesPainter extends CustomPainter {
  final Color color;

  const _StadiumLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    final pitch = RRect.fromRectAndRadius(
      Rect.fromLTWH(22, size.height * 0.10, size.width - 44, size.height * 0.76),
      const Radius.circular(28),
    );
    canvas.drawRRect(pitch, paint);
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.10),
      Offset(size.width / 2, size.height * 0.86),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.48),
      size.width * 0.18,
      paint,
    );

    final boxWidth = size.width * 0.32;
    final boxHeight = size.height * 0.18;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - boxWidth) / 2,
          size.height * 0.10,
          boxWidth,
          boxHeight,
        ),
        const Radius.circular(16),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - boxWidth) / 2,
          size.height * 0.68,
          boxWidth,
          boxHeight,
        ),
        const Radius.circular(16),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StadiumLinesPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}


