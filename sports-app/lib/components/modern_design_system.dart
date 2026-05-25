import 'dart:ui';
import 'package:flutter/material.dart';

/// ============================================================================
/// MODERN DESIGN SYSTEM - Inspired by HomeSection
/// Provides reusable components for a cohesive, modern UI across all pages
/// ============================================================================

// ============================================================================
// 1. CORNER BORDER PAINTER - Decorative corner borders
// ============================================================================
class CornerBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double length;

  CornerBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.length = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(Offset(0, 0), Offset(length, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, length), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - length, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height - length), Offset(0, size.height), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - length, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - length), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 2. MODERN CARD - Reusable card with corner borders
// ============================================================================
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final bool withCornerBorder;
  final Color? cornerBorderColor;
  final double cornerBorderLength;
  final BoxShadow? customShadow;
  final double borderRadius;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.backgroundColor,
    this.withCornerBorder = false,
    this.cornerBorderColor,
    this.cornerBorderLength = 20,
    this.customShadow,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = Colors.white.withOpacity(0.5);
    final bgColor = backgroundColor ?? defaultBgColor;
    final shadow = customShadow ??
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: const Offset(0, 3),
        );

    if (withCornerBorder) {
      return Container(
        margin: margin,
        padding: const EdgeInsets.all(0),
        child: CustomPaint(
          painter: CornerBorderPainter(
            color: cornerBorderColor ?? Colors.teal,
            strokeWidth: 2,
            length: cornerBorderLength,
          ),
          child: Container(
            margin: const EdgeInsets.all(0),
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [shadow],
            ),
            child: child,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [shadow],
      ),
      child: child,
    );
  }
}

// ============================================================================
// 3. QUICK ACCESS BUTTON - For quick navigation
// ============================================================================
class QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAccessButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. SECTION TITLE - Styled section titles
// ============================================================================
class SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  final TextAlign textAlign;
  final double fontSize;

  const SectionTitle({
    Key? key,
    required this.title,
    this.color = Colors.teal,
    this.textAlign = TextAlign.start,
    this.fontSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

// ============================================================================
// 5. CONTACT ITEM - For displaying contact information
// ============================================================================
class ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const ContactItem({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade600,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. EXPANDABLE SECTION - With "Show More/Less" functionality
// ============================================================================
class ExpandableSection extends StatefulWidget {
  final String title;
  final String description;
  final Widget? titleIcon;
  final int maxLinesCollapsed;
  final Color? titleColor;
  final bool showCornerBorder;

  const ExpandableSection({
    Key? key,
    required this.title,
    required this.description,
    this.titleIcon,
    this.maxLinesCollapsed = 3,
    this.titleColor,
    this.showCornerBorder = false,
  }) : super(key: key);

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      withCornerBorder: widget.showCornerBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.titleColor ?? Colors.teal.shade700,
                ),
              ),
              if (widget.titleIcon != null) ...[
                const SizedBox(width: 5),
                widget.titleIcon!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            maxLines: _isExpanded ? null : widget.maxLinesCollapsed,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isExpanded ? 'Show Less' : 'Show More',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 7. MODERN HEADER CARD - For top section headers
// ============================================================================
class ModernHeaderCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;

  const ModernHeaderCard({
    Key? key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SectionTitle(title: title),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 8. INFO BADGE - Small badges for displaying stats
// ============================================================================
class InfoBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const InfoBadge({
    Key? key,
    required this.text,
    this.backgroundColor = Colors.teal,
    this.textColor = Colors.white,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: backgroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: backgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 9. MODERN CONTAINER WITH BACKDROP BLUR - For overlay effects
// ============================================================================
class ModernBlurContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double blurSigma;
  final EdgeInsets padding;
  final double borderRadius;

  const ModernBlurContainer({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.blurSigma = 6,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// 10. DECORATIVE BACKGROUND SHAPES - Gradient circles
// ============================================================================
class DecorativeCircle extends StatelessWidget {
  final double size;
  final double top;
  final double right;
  final double? bottom;
  final double? left;
  final Color color;
  final double opacity;

  const DecorativeCircle({
    Key? key,
    required this.size,
    required this.top,
    required this.right,
    this.bottom,
    this.left,
    required this.color,
    this.opacity = 0.25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 11. MODERN TEXT FIELD - Styled input field
// ============================================================================
class ModernTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final IconData? icon;
  final Color? accentColor;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const ModernTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.icon,
    this.accentColor,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? Colors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          onChanged: widget.onChanged,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            filled: true,
            fillColor: Colors.grey.shade100.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 12. MODERN BUTTON - Styled action button
// ============================================================================
class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isLoading;
  final double fontSize;

  const ModernButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.teal,
    this.textColor = Colors.white,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.isLoading = false,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 13. STATUS INDICATOR - For showing status badges
// ============================================================================
class StatusIndicator extends StatelessWidget {
  final String status;
  final Color? statusColor;
  final bool withDot;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.statusColor,
    this.withDot = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = statusColor ?? Colors.green;

    return Row(
      children: [
        if (withDot)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}


