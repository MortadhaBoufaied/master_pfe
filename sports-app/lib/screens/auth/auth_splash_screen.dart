import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthSplashScreen extends StatefulWidget {
  final String nextRoute;

  const AuthSplashScreen({super.key, this.nextRoute = '/login/form'});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacementNamed(widget.nextRoute);
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF041412) : const Color(0xFFF6FFFB),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = _controller.value;
          final eased = Curves.easeOutCubic.transform(value);
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isDark
                              ? [
                                const Color(0xFF041412),
                                const Color(0xFF063C36),
                                const Color(0xFF091B2F),
                              ]
                              : [
                                const Color(0xFFEFFFF8),
                                const Color(0xFFF9FFFD),
                                const Color(0xFFE7F2FF),
                              ],
                    ),
                    image: DecorationImage(
                      image: const AssetImage('assets/auth/auth-logo-small.png'),
                      fit: BoxFit.cover,
                      opacity: isDark ? 0.16 : 0.28,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _SplashPitchPainter(
                    progress: value,
                    color: cs.primary.withValues(alpha: isDark ? 0.20 : 0.13),
                  ),
                ),
              ),
              Positioned(
                top: -76 + 20 * eased,
                left: -42,
                child: _SplashBlob(
                  size: 178,
                  color: cs.primary.withValues(alpha: isDark ? 0.26 : 0.16),
                ),
              ),
              Positioned(
                right: -72,
                bottom: 92 - 18 * eased,
                child: _SplashBlob(
                  size: 210,
                  color: cs.secondary.withValues(alpha: isDark ? 0.22 : 0.14),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      Transform.scale(
                        scale: 0.84 + 0.16 * eased,
                        child: Transform.rotate(
                          angle: math.sin(value * math.pi * 2) * 0.025,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 188 + 16 * math.sin(value * math.pi),
                                height: 188 + 16 * math.sin(value * math.pi),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.12),
                                    width: 2,
                                  ),
                                ),
                              ),
                              Container(
                                width: 150,
                                height: 150,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(42),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.22),
                                      blurRadius: 42,
                                      offset: const Offset(0, 24),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/auth/auth-logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Opacity(
                        opacity: eased,
                        child: Column(
                          children: [
                            Text(
                              'Academy OS',
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF071A2F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Preparing your sport workspace',
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    isDark
                                        ? Colors.white70
                                        : cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: value,
                          backgroundColor: cs.primary.withValues(alpha: 0.12),
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Players • Scouting • Training • Admin',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _SplashBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
    );
  }
}

class _SplashPitchPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _SplashPitchPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
    final inset = 32.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        size.height * 0.16,
        size.width - inset * 2,
        size.height * 0.58,
      ),
      const Radius.circular(34),
    );
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
    final center = Offset(size.width / 2, size.height * 0.45);
    canvas.drawCircle(center, 58 * progress, paint);
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.16),
      Offset(size.width / 2, size.height * (0.16 + 0.58 * progress)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashPitchPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
