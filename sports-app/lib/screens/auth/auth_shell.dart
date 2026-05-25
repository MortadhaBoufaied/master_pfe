import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthScreenShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? footer;
  final Widget? topAction;

  const AuthScreenShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.footer,
    this.topAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : const Color(0xFFF6FAF8),
      appBar:
          topAction == null
              ? null
              : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [topAction!],
              ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [const Color(0xFF071311), const Color(0xFF101923)]
                    : [const Color(0xFFF8FCFA), const Color(0xFFE8F4EF)],
          ),
          image: DecorationImage(
            image: const AssetImage('assets/auth/auth-pattern.png'),
            fit: BoxFit.cover,
            opacity: isDark ? 0.12 : 0.28,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -54,
              top: 42,
              child: _SoftShape(
                size: 150,
                color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.11),
              ),
            ),
            Positioned(
              right: -68,
              bottom: 96,
              child: _SoftShape(
                size: 190,
                color: cs.secondary.withValues(alpha: isDark ? 0.14 : 0.10),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 28 : 18,
                        wide ? 24 : 18,
                        wide ? 28 : 18,
                        26,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: wide ? 1040 : 430,
                        ),
                        child:
                            wide
                                ? IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Expanded(child: _AuthVisualPanel()),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: _AuthFormCard(
                                          title: title,
                                          subtitle: subtitle,
                                          icon: icon,
                                          footer: footer,
                                          child: child,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : _AuthFormCard(
                                  title: title,
                                  subtitle: subtitle,
                                  icon: icon,
                                  footer: footer,
                                  child: child,
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthVisualPanel extends StatelessWidget {
  const _AuthVisualPanel();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 680),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(cs.primary, Colors.black, isDark ? 0.35 : 0.16)!,
            Color.lerp(cs.secondary, cs.primary, 0.35)!,
          ],
        ),
        image: const DecorationImage(
          image: AssetImage('assets/auth/auth-bg-field.png'),
          fit: BoxFit.cover,
          opacity: 0.30,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.28 : 0.18),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PitchPainter(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          Positioned(
            right: -26,
            top: 46,
            child: _OrbitIcon(
              icon: Icons.sports_soccer_rounded,
              size: 112,
              color: Colors.white.withValues(alpha: 0.11),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 96,
            child: _FloatingSignal(
              icon: Icons.query_stats_rounded,
              title: 'Scouting signals',
              value: 'Live',
            ),
          ),
          Positioned(
            right: 22,
            bottom: 178,
            child: _FloatingSignal(
              icon: Icons.health_and_safety_rounded,
              title: 'Availability',
              value: 'Tracked',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(
                        'assets/auth/auth-pattern.png',
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.sports_soccer_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sports Academy OS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Football Academy Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Protected academy access',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Run the academy from one secure touchpoint.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  height: 0.98,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Players, trainers, attendance, injuries, scouting reports, payments, chat, and admin services stay connected behind role-aware authentication.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AuthFeaturePill(icon: Icons.groups_rounded, label: 'Teams'),
                  AuthFeaturePill(
                    icon: Icons.event_available_rounded,
                    label: 'Activities',
                  ),
                  AuthFeaturePill(
                    icon: Icons.analytics_rounded,
                    label: 'Scouting',
                  ),
                  AuthFeaturePill(
                    icon: Icons.forum_rounded,
                    label: 'Messaging',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthImageBanner extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<String> chips;

  const AuthImageBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    this.chips = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(cs.primary, Colors.black, isDark ? 0.42 : 0.08)!,
            Color.lerp(cs.secondary, cs.primary, 0.45)!,
          ],
        ),
        image: const DecorationImage(
          image: AssetImage('assets/auth/auth-bg-field.png'),
          fit: BoxFit.cover,
          opacity: 0.20,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.20 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/auth/auth-pattern.png',
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => Icon(icon, color: cs.primary, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                    height: 1.28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        chips
                            .map(
                              (chip) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                  ),
                                ),
                                child: Text(
                                  chip,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
          Icon(icon, color: Colors.white.withValues(alpha: 0.78), size: 26),
        ],
      ),
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? footer;

  const _AuthFormCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      decoration: BoxDecoration(
        color:
            isDark
                ? cs.surfaceContainerHigh.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(38),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.40 : 0.70),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AuthLogoMark(),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.20 : 0.09),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: cs.primary, size: 16),
                  const SizedBox(width: 7),
                  Text(
                    'Academy OS',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.02,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          child,
          if (footer != null) ...[const SizedBox(height: 18), footer!],
        ],
      ),
    );
  }
}

class _SoftShape extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftShape({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
    );
  }
}

class _AuthLogoMark extends StatelessWidget {
  const _AuthLogoMark();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 126,
        height: 126,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
          image: DecorationImage(
            image: const AssetImage('assets/auth/auth-pattern.png'),
            fit: BoxFit.cover,
            opacity: isDark ? 0.08 : 0.16,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.12),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Image.asset(
          'assets/auth/auth-logo.png',
          fit: BoxFit.contain,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.sports_soccer_rounded,
                color: cs.primary,
                size: 48,
              ),
        ),
      ),
    );
  }
}

class AuthFeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const AuthFeaturePill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: cs.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.replaceFirst('Exception: ', ''),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  const AuthPrimaryButton({
    super.key,
    required this.loading,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primary.withValues(alpha: 0.42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
        icon:
            loading
                ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Icon(icon),
        label: Text(loading ? 'Please wait...' : label),
      ),
    );
  }
}

class _FloatingSignal extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _FloatingSignal({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const _OrbitIcon({
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 10,
      child: Icon(icon, size: size, color: color),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final Color color;

  const _PitchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(22, 86, size.width - 44, size.height - 150),
      const Radius.circular(34),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawLine(
      Offset(size.width / 2, 86),
      Offset(size.width / 2, size.height - 64),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.48),
      math.min(size.width, size.height) * 0.14,
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, 86),
          width: size.width * 0.34,
          height: 130,
        ),
        const Radius.circular(18),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - 64),
          width: size.width * 0.34,
          height: 130,
        ),
        const Radius.circular(18),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
