import 'package:flutter/material.dart';

class HtmlText extends StatelessWidget {
  final String html;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  const HtmlText(this.html, {super.key, this.style, this.maxLines, this.overflow = TextOverflow.clip});

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final span = _parse(html, base);
    return RichText(
      text: span,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextSpan _parse(String input, TextStyle base) {
    // Very small parser: tokenizes tags and text.
    final tokens = <_Tok>[];
    final r = RegExp(r'(<[^>]+>|[^<]+)');
    for (final m in r.allMatches(input)) {
      final s = m.group(0) ?? '';
      if (s.startsWith('<')) {
        tokens.add(_Tok.tag(s));
      } else {
        tokens.add(_Tok.text(s));
      }
    }

    final stack = <_StyleFrame>[ _StyleFrame(base) ];
    final children = <InlineSpan>[];

    void pushStyle(TextStyle st) => stack.add(_StyleFrame(st));
    void popStyle() { if (stack.length > 1) stack.removeLast(); }

    for (final t in tokens) {
      if (!t.isTag) {
        final txt = t.value
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>');
        children.add(TextSpan(text: txt, style: stack.last.style));
        continue;
      }

      final tag = t.value.toLowerCase();
      if (tag.startsWith('<br')) {
        children.add(TextSpan(text: '', style: stack.last.style));
      } else if (tag == '<b>' || tag == '<strong>') {
        pushStyle(stack.last.style.merge(const TextStyle(fontWeight: FontWeight.w700)));
      } else if (tag == '</b>' || tag == '</strong>') {
        popStyle();
      } else if (tag == '<u>') {
        pushStyle(stack.last.style.merge(const TextStyle(decoration: TextDecoration.underline)));
      } else if (tag == '</u>') {
        popStyle();
      } else if (tag.startsWith('<span')) {
        // parse color
        final c = _extractColor(tag);
        if (c != null) {
          pushStyle(stack.last.style.merge(TextStyle(color: c)));
        } else {
          pushStyle(stack.last.style);
        }
      } else if (tag == '</span>') {
        popStyle();
      } else if (tag.startsWith('<p')) {
        // paragraph start -> add newline if not empty
        if (children.isNotEmpty) children.add(TextSpan(text: '', style: stack.last.style));
      } else if (tag == '</p>') {
        children.add(TextSpan(text: '', style: stack.last.style));
      }
    }
    return TextSpan(style: base, children: children);
  }

  Color? _extractColor(String tag) {
    final m = RegExp(r'color\s*:\s*(#[0-9a-f]{6})').firstMatch(tag);
    if (m == null) return null;
    final hex = m.group(1) ?? '';
    try {
      final v = int.parse(hex.substring(1), radix: 16);
      return Color(0xFF000000 | v);
    } catch (_) {
      return null;
    }
  }
}

class _Tok {
  final bool isTag;
  final String value;
  _Tok.tag(this.value) : isTag = true;
  _Tok.text(this.value) : isTag = false;
}

class _StyleFrame {
  final TextStyle style;
  _StyleFrame(this.style);
}


