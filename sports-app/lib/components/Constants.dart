import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const String _apiHostOverride = String.fromEnvironment('API_HOST');
const String _chatbotHostOverride = String.fromEnvironment('CHATBOT_HOST');

// If you set API_HOST at build time, it will override the default.
// Example (local):
//   flutter run --dart-define=API_HOST=localhost:8080
// Example (deployed):
//   flutter run --dart-define=API_HOST=sports-management-project-3pip.onrender.com
String _backendHost() {
  final raw =
      _apiHostOverride.isNotEmpty
          ? _apiHostOverride
          : 'localhost:8080';

  // If someone provided a full URL (e.g. https://example.com), strip scheme + trailing slashes.
  var host = raw.trim();

  if (host.startsWith('http://')) {
    host = host.substring('http://'.length);
  } else if (host.startsWith('https://')) {
    host = host.substring('https://'.length);
  }

  host = host.replaceAll(RegExp(r'/*$'), ''); // trim trailing /

  return host;
}

// REST API BASE
final String API_BASE_URL = 'https://${_backendHost()}/api';

const Duration API_TIMEOUT = Duration(seconds: 30);

// WEBSOCKET BASE
// Use secure websocket on HTTPS deployments
final String API_WS_BASE_URL = 'wss://${_backendHost()}/ws';

// ═══════════════════════════════════════════════════════════════════════════
// TEXT COLORS - Use AppColors centralized palette
// ═══════════════════════════════════════════════════════════════════════════
const kLightTextColor = AppColors.textLight;
const kHardTextColor = AppColors.textDark;

// ═══════════════════════════════════════════════════════════════════════════
// PRIMARY COLORS - Use AppColors centralized palette
// ═══════════════════════════════════════════════════════════════════════════
const kPrimaryDarkColor = AppColors.successGreen;
const kPrimarylightColor = AppColors.accentGreen;
const kBackgroundColor = AppColors.bgLight;

// ═══════════════════════════════════════════════════════════════════════════
// CATEGORY COLORS - For displaying categories/divisions
// ═══════════════════════════════════════════════════════════════════════════
const List<Color> kCategoriesPrimaryColor = [
  AppColors.warningAmber, // Amber with opacity
  AppColors.infoBlue, // Blue with opacity
  AppColors.accentGreen, // Green with opacity
  AppColors.errorRed, // Red with opacity
];

const List<Color> kCategoriesSecondryColor = [
  Color(0xFFF1C40F), // Golden Yellow
  Color(0xFF3498DB), // Sky Blue
  Color(0xFF27AE60), // Forest Green
  Color(0xFFE74C3C), // Coral Red
];

const String? FILES_BASE_URL = null;

// Chatbot pass-through via the same backend deployment
final String CHATBOT_API_BASE_URL =
    _chatbotHostOverride.isNotEmpty
        ? (_chatbotHostOverride.startsWith('http://') ||
                _chatbotHostOverride.startsWith('https://')
            ? _chatbotHostOverride
            : 'https://$_chatbotHostOverride')
        : 'https://${_backendHost()}';

final String CHATBOT_API_CHAT_URL = '$CHATBOT_API_BASE_URL/api/chatbot/ask';
const String? CHATBOT_API_KEY = null;
