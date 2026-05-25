import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Lightweight on-device translation helper.
///
/// IMPORTANT:
/// - Use ONLY for generic text (descriptions, addresses, notes).
/// - Do NOT translate emails, URLs, file paths, IDs, or person names.
/// - Caches results in memory to avoid repeated translation calls.
class ContentTranslationService {
  ContentTranslationService._();
  static final ContentTranslationService instance = ContentTranslationService._();

  final _cache = HashMap<String, String>();
  final _modelManager = OnDeviceTranslatorModelManager();

  bool _shouldSkip(String text) {
    final t = text.trim();
    if (t.isEmpty) return true;
    // skip emails
    if (RegExp(r"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}", caseSensitive: false).hasMatch(t)) return true;
    // skip urls
    if (RegExp(r"https?://", caseSensitive: false).hasMatch(t)) return true;
    // skip asset or file paths
    if (t.contains('assets/') || t.contains('\\') || t.contains('/')) {
      // allow normal addresses with '/', but skip obvious paths
      if (t.contains('assets/') || t.contains('.png') || t.contains('.jpg') || t.contains('.dart')) return true;
    }
    return false;
  }

  TranslateLanguage _toLang(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return TranslateLanguage.french;
      case 'ar':
        return TranslateLanguage.arabic;
      default:
        return TranslateLanguage.english;
    }
  }

  /// Translates [text] from English to [targetLocale].
  ///
  /// If [targetLocale] is English or the text looks like an email/url/path, it returns the original text.
  Future<String> translateBasic(String text, Locale targetLocale) async {
    if (_shouldSkip(text)) return text;
    if (targetLocale.languageCode == 'en') return text;

    final key = '${targetLocale.languageCode}::${text.trim()}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final source = TranslateLanguage.english;
    final target = _toLang(targetLocale);

    // Ensure models are available
    await _modelManager.downloadModel(source.bcpCode);
    await _modelManager.downloadModel(target.bcpCode);

    final translator = OnDeviceTranslator(sourceLanguage: source, targetLanguage: target);
    try {
      final out = await translator.translateText(text);
      _cache[key] = out;
      return out;
    } finally {
      translator.close();
    }
  }
}


