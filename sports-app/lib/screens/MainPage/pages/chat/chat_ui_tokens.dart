import 'package:flutter/material.dart';

class AcademyChatUi {
  // Brand accents
  static const Color primary = Color(0xFF006860);
  static const Color primary2 = Color(0xFF20C4B0);
  static const Color gold = Color(0xFFF8C000);

  // Light chat accent inspired by the image, but softer
  static const Color lime = Color(0xFFDDF86B);

  // Text
  static const Color text = Color(0xFF0E1B1A);
  static const Color muted = Color(0xFF6D7A7A);

  // Radii
  static BorderRadius r12 = BorderRadius.circular(12);
  static BorderRadius r16 = BorderRadius.circular(16);
  static BorderRadius r18 = BorderRadius.circular(18);
  static BorderRadius r20 = BorderRadius.circular(20);
  static BorderRadius r24 = BorderRadius.circular(24);
  static BorderRadius r28 = BorderRadius.circular(28);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color pageBg(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFF101817) : const Color(0xFFF6FAF8);
  }

  static Color pageBg2(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFF172321) : const Color(0xFFEFF8F5);
  }

  static Color surface(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = isDark(context);
    return dark ? cs.surface.withOpacity(0.92) : Colors.white.withOpacity(0.94);
  }

  static Color softSurface(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFF21302E) : const Color(0xFFFFFFFF);
  }

  static Color inputSurface(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFF263634) : const Color(0xFFF0F5F3);
  }

  static Color receivedBubble(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFF263634) : Colors.white;
  }

  static Color sentBubble(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFFBFEF6A) : const Color(0xFFDDF86B);
  }

  static Color titleText(BuildContext context) {
    final dark = isDark(context);
    return dark ? Colors.white : const Color(0xFF0E1B1A);
  }

  static Color bodyText(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFFEAF2F0) : const Color(0xFF0E1B1A);
  }

  static Color secondaryText(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFFAAB8B5) : const Color(0xFF6D7A7A);
  }

  static Color divider(BuildContext context) {
    final dark = isDark(context);
    return dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.07);
  }

  static Color avatarBg(BuildContext context) {
    final dark = isDark(context);
    return dark ? const Color(0xFF2F4742) : const Color(0xFFE1F3EF);
  }

  static Color shadow(BuildContext context) {
    final dark = isDark(context);
    return Colors.black.withOpacity(dark ? 0.28 : 0.08);
  }

  static LinearGradient backgroundGradient(BuildContext context) {
    final dark = isDark(context);

    return LinearGradient(
      colors: dark
          ? const [
        Color(0xFF101817),
        Color(0xFF172321),
        Color(0xFF101817),
      ]
          : const [
        Color(0xFFF8FCFA),
        Color(0xFFEFF8F5),
        Color(0xFFF9FBF8),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static List<BoxShadow> softShadow(BuildContext context) {
    return [
      BoxShadow(
        color: shadow(context),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
