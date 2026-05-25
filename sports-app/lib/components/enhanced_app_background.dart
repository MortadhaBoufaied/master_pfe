import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/academy_theme_controller.dart';
import '../utils/backend_url.dart';
import 'modern_design_system.dart';

/// Enhanced app background with decorative circles inspired by HomeSection
/// Features:
/// - Background image with gradient overlay
/// - Decorative gradient circles (green and blue)
/// - Soft gradient base
/// - Optional blur effect
class EnhancedAppBackground extends StatelessWidget {
  final Widget child;
  final bool blur;
  final bool includeDecorativeCircles;
  final bool includeStadiumLines;

  const EnhancedAppBackground({
    super.key,
    required this.child,
    this.blur = true,
    this.includeDecorativeCircles = true,
    this.includeStadiumLines = true,
  });

  static bool _hasAncestorBackground(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_EnhancedAppBackgroundScope>() !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    // Avoid stacking the same background multiple times
    if (_hasAncestorBackground(context)) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final academyTheme = AppAcademyTheme.instance.controller.theme;
    final bannerUrl = BackendUrl.resolve(academyTheme.homeBannerUrl);
    final cs = Theme.of(context).colorScheme;

    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
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
      colors: isDark
          ? [
              const Color(0xFF060817).withOpacity(0.84),
              const Color(0xFF071828).withOpacity(0.72),
              const Color(0xFF060817).withOpacity(0.88),
            ]
          : [
              cs.surface.withOpacity(0.94),
              cs.surface.withOpacity(0.90),
              cs.surface.withOpacity(0.96),
            ],
    );

    return _EnhancedAppBackgroundScope(
      child: Stack(
        children: [
          // Base gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: baseGradient),
            ),
          ),

          // Background image
          Positioned.fill(
            child: bannerUrl == null
                ? Image.asset(
                    'assets/background-image.png',
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
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

          // Blur effect
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

          // Decorative circles (like in HomeSection)
          if (includeDecorativeCircles) ...[
            DecorativeCircle(
              size: 180,
              top: -40,
              right: -40,
              color: Colors.green.shade100,
              opacity: 0.35,
            ),
            DecorativeCircle(
              size: 220,
              top: MediaQuery.of(context).size.height * 0.3,
              left: -60,
              color: Colors.blue.shade100,
              opacity: 0.25,
              right: 0,
            ),
          ],

          // Stadium lines pattern (optional)
          if (includeStadiumLines)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StadiumLinesPainter(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : cs.primary.withOpacity(0.045),
                  ),
                ),
              ),
            ),

          // Content
          child,
        ],
      ),
    );
  }
}

class _EnhancedAppBackgroundScope extends InheritedWidget {
  const _EnhancedAppBackgroundScope({required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldDelegate) => false;
}

class _StadiumLinesPainter extends CustomPainter {
  final Color color;

  const _StadiumLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final pitch = RRect.fromRectAndRadius(
      Rect.fromLTWH(22, size.height * 0.10, size.width - 44, size.height * 0.76),
      const Radius.circular(40),
    );

    canvas.drawRRect(pitch, paint);

    final midLine = size.height * 0.48;
    canvas.drawLine(Offset(22, midLine), Offset(size.width - 22, midLine), paint);

    final centerCircleRadius = 30.0;
    canvas.drawCircle(
      Offset(size.width / 2, midLine),
      centerCircleRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, midLine),
      3,
      paint,
    );

    final goalBoxWidth = 100.0;
    final goalBoxHeight = 150.0;
    final topGoalBox = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - goalBoxWidth) / 2,
        size.height * 0.10,
        goalBoxWidth,
        goalBoxHeight,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(topGoalBox, paint);

    final bottomGoalBox = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - goalBoxWidth) / 2,
        size.height * 0.76,
        goalBoxWidth,
        goalBoxHeight,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(bottomGoalBox, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wrapper to apply enhanced background globally while maintaining backward compatibility
class EnhancedAppBackgroundWrapper extends StatelessWidget {
  final Widget child;
  final bool blur;
  final bool includeDecorativeCircles;
  final bool includeStadiumLines;

  const EnhancedAppBackgroundWrapper({
    super.key,
    required this.child,
    this.blur = true,
    this.includeDecorativeCircles = true,
    this.includeStadiumLines = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedAppBackground(
      blur: blur,
      includeDecorativeCircles: includeDecorativeCircles,
      includeStadiumLines: includeStadiumLines,
      child: child,
    );
  }
}


