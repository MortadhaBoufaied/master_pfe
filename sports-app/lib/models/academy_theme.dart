import 'package:flutter/material.dart';

class AcademyTheme {
  final int? academyId;
  final int? sportId;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color accentColor;
  final Color textColor;
  final String? logoUrl;
  final String? homeBannerUrl;
  final String? splashImageUrl;
  final String? defaultPlayerImageUrl;
  final String? defaultTrainerImageUrl;
  final String? defaultParentImageUrl;
  final String? defaultAdminImageUrl;
  final String cardStyle;
  final String fontFamily;
  final String buttonStyle;
  final String iconStyle;
  final int version;

  const AcademyTheme({
    this.academyId,
    this.sportId,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.textColor,
    this.logoUrl,
    this.homeBannerUrl,
    this.splashImageUrl,
    this.defaultPlayerImageUrl,
    this.defaultTrainerImageUrl,
    this.defaultParentImageUrl,
    this.defaultAdminImageUrl,
    required this.cardStyle,
    required this.fontFamily,
    required this.buttonStyle,
    required this.iconStyle,
    required this.version,
  });

  static const fallback = AcademyTheme(
    primaryColor: Color(0xFF0F766E),
    secondaryColor: Color(0xFF0369A1),
    backgroundColor: Color(0xFFF8FAFC),
    accentColor: Color(0xFFF59E0B),
    textColor: Color(0xFF0F172A),
    cardStyle: 'compact',
    fontFamily: 'Public Sans',
    buttonStyle: 'solid',
    iconStyle: 'rounded',
    version: 1,
  );

  factory AcademyTheme.fromJson(Map<String, dynamic> json) {
    return AcademyTheme(
      academyId: _toInt(json['academyId']),
      sportId: _toInt(json['sportId']),
      primaryColor: _parseColor(json['primaryColor'], fallback.primaryColor),
      secondaryColor: _parseColor(
        json['secondaryColor'],
        fallback.secondaryColor,
      ),
      backgroundColor: _parseColor(
        json['backgroundColor'],
        fallback.backgroundColor,
      ),
      accentColor: _parseColor(json['accentColor'], fallback.accentColor),
      textColor: _parseColor(json['textColor'], fallback.textColor),
      logoUrl: _text(json['logoUrl']),
      homeBannerUrl: _text(json['homeBannerUrl']),
      splashImageUrl: _text(json['splashImageUrl']),
      defaultPlayerImageUrl: _text(json['defaultPlayerImageUrl']),
      defaultTrainerImageUrl: _text(json['defaultTrainerImageUrl']),
      defaultParentImageUrl: _text(json['defaultParentImageUrl']),
      defaultAdminImageUrl: _text(json['defaultAdminImageUrl']),
      cardStyle: _text(json['cardStyle']) ?? fallback.cardStyle,
      fontFamily: _text(json['fontFamily']) ?? fallback.fontFamily,
      buttonStyle: _text(json['buttonStyle']) ?? fallback.buttonStyle,
      iconStyle: _text(json['iconStyle']) ?? fallback.iconStyle,
      version: _toInt(json['version']) ?? fallback.version,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String? _text(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static Color _parseColor(dynamic value, Color fallback) {
    var raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return fallback;
    if (raw.startsWith('#')) raw = raw.substring(1);
    if (raw.length == 3) {
      raw = raw.split('').map((char) => '$char$char').join();
    }
    if (raw.length == 6) raw = 'FF$raw';
    if (raw.length != 8) return fallback;
    final parsed = int.tryParse(raw, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }
}


