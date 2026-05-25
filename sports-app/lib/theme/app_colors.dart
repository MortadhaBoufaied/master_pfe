import 'package:flutter/material.dart';

/// 
/// ╔════════════════════════════════════════════════════════════════════════════╗
/// ║                      CENTRALIZED APP COLOR PALETTE                        ║
/// ║                   Single Source of Truth for All Colors                    ║
/// ╚════════════════════════════════════════════════════════════════════════════╝
/// 
/// This file contains all colors used across the entire sports academy app.
/// Every screen imports colors from this file to ensure consistency and easy theme changes.
/// 
/// Structure:
/// 1. PRIMARY PALETTE - Core brand colors
/// 2. SEMANTIC COLORS - Status, feedback, warnings
/// 3. BACKGROUND & SURFACE - Light/dark mode surfaces
/// 4. TEXT COLORS - Typography hierarchy
/// 5. COMPONENT COLORS - Specific UI component colors
/// 6. SCREEN-SPECIFIC THEMES - Colors for each major screen
///

class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. PRIMARY PALETTE - Core Brand Colors
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Main brand color - Navy Blue (Baseball)
  static const Color primaryTeal = Color(0xFF002D72);
  static const Color primaryTealDark = Color(0xFF00205E);
  static const Color primaryTealLight = Color(0xFF3D5A80);
  
  /// Secondary brand colors - Red and White (Baseball)
  static const Color secondaryOrange = Color(0xFFCE1141);
  static const Color secondaryViolet = Color(0xFFFFFFFF);
  static const Color secondaryElectricBlue = Color(0xFFBD3039);
  
  /// Accent colors for visual interest - Gold/Yellow (Baseball)
  static const Color accentPitch = Color(0xFF006B42);
  static const Color accentLime = Color(0xFFFFB81C);
  static const Color accentGreen = Color(0xFF27AE60);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 2. SEMANTIC COLORS - Status & Feedback
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Success state
  static const Color successGreen = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  
  /// Warning state
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  
  /// Error state
  static const Color errorRed = Color(0xFFFF6B6B);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  /// Info state
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  /// Pending/Neutral
  static const Color pendingGray = Color(0xFF6B7280);
  static const Color pendingLight = Color(0xFFF3F4F6);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 3. BACKGROUND & SURFACE - Light & Dark Mode
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Light mode backgrounds
  static const Color bgLight = Color(0xFFF4F7FA);
  static const Color bgLightPure = Color(0xFFFFFFFF);
  static const Color bgLightSecondary = Color(0xFFFBFDFD);
  static const Color bgLightTertiary = Color(0xFFF0F5F4);
  
  /// Dark mode backgrounds
  static const Color bgDark = Color(0xFF070A18);
  static const Color bgDarkSecondary = Color(0xFF0F1419);
  static const Color bgDarkTertiary = Color(0xFF141D2C);
  static const Color bgDarkCard = Color(0xFF1A2335);
  
  /// Surface colors
  static const Color surfaceLight = Color(0xFFFBFDFD);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceDarkContainer = Color(0xFF25304A);
  static const Color surfaceDarkContainerHigh = Color(0xFF1B2538);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 4. TEXT COLORS - Typography Hierarchy
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Light mode text
  static const Color textDark = Color(0xFF152724);
  static const Color textDarkSecondary = Color(0xFF536B74);
  static const Color textDarkTertiary = Color(0xFF536B74);
  
  /// Dark mode text
  static const Color textLight = Color(0xFFF6F8FB);
  static const Color textLightSecondary = Color(0xFFBAC4D5);
  static const Color textLightTertiary = Color(0xFF99A9BC);
  
  /// Disabled text
  static const Color textDisabled = Color(0xFFAEB8C0);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 5. COMPONENT COLORS - UI Elements
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Border & Divider colors
  static const Color borderLight = Color(0xFFD5E0E3);
  static const Color borderDark = Color(0xFF2D3A50);
  static const Color borderOutline = Color(0xFF8AA0A7);
  static const Color borderOutlineVariant = Color(0xFF59667A);
  
  /// Icon colors
  static const Color iconLight = Color(0xFF152724);
  static const Color iconDark = Color(0xFFF6F8FB);
  static const Color iconDisabled = Color(0xFFAEB8C0);
  
  /// Overlay & Shadow
  static const Color overlayLight = Color(0x0A000000);
  static const Color overlayDark = Color(0x40000000);
  static const Color shadowBlack = Color(0xFF000000);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 6. SCREEN-SPECIFIC THEMES - Color Schemes for Each Screen/Page
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// HOME / DASHBOARD SCREEN
  /// Primary: Navy Blue | Secondary: Red | Accent: Gold
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color homePrimary = Color(0xFF002D72);
  static const Color homeSecondary = Color(0xFFCE1141);
  static const Color homeAccent = Color(0xFFFFB81C);
  static const Color homeCardBg = Color(0xFFF5F5F5);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// PLAYER MANAGEMENT SCREEN
  /// Primary: Navy Blue | Secondary: Red | Accent: Gold
  /// - Displays player cards with stats
  /// - Color-coded by position or level
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color playerPrimary = Color(0xFF002D72);
  static const Color playerSecondary = Color(0xFFCE1141);
  static const Color playerAccent = Color(0xFFFFB81C);
  static const Color playerCardBg = Color(0xFFF0F0F0);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// SCOUTING REPORTS SCREEN
  /// Primary: Navy Blue | Secondary: Red | Accent: Gold
  /// - Used for displaying detailed evaluation scores
  /// - Talent assessment visualizations
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color scoutingPrimary = Color(0xFF002D72);
  static const Color scoutingSecondary = Color(0xFFCE1141);
  static const Color scoutingAccent = Color(0xFFFFB81C);
  static const Color scoutingCardBg = Color(0xFFE8E8E8);
  static const Color scoutingExcellent = Color(0xFF1CAF43);
  static const Color scoutingGood = Color(0xFF1E90FF);
  static const Color scoutingAverage = Color(0xFFFFA500);
  static const Color scoutingPoor = Color(0xFFDC143C);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// TRAINING SESSIONS SCREEN
  /// Primary: Green (Field) | Secondary: Red | Accent: Gold
  /// - Training activity tracking
  /// - Session scheduling and history
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color trainingPrimary = Color(0xFF006B42);
  static const Color trainingSecondary = Color(0xFFCE1141);
  static const Color trainingAccent = Color(0xFFFFB81C);
  static const Color trainingCardBg = Color(0xFFE8F5E9);
  static const Color trainingActive = Color(0xFF228B22);
  static const Color trainingScheduled = Color(0xFF1E90FF);
  static const Color trainingCompleted = Color(0xFF3CB371);
  static const Color trainingCancelled = Color(0xFFDC143C);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// MATCHES SCREEN
  /// Primary: Red | Secondary: Navy Blue | Accent: Gold
  /// - Match schedules and results
  /// - Performance statistics
  /// - Venue information
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color matchPrimary = Color(0xFFCE1141);
  static const Color matchSecondary = Color(0xFF002D72);
  static const Color matchAccent = Color(0xFFFFB81C);
  static const Color matchCardBg = Color(0xFFFFF5E1);
  static const Color matchUpcoming = Color(0xFF1E90FF);
  static const Color matchLive = Color(0xFFFF4500);
  static const Color matchCompleted = Color(0xFF228B22);
  static const Color matchCancelled = Color(0xFF808080);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// PAYMENTS SCREEN
  /// Primary: Green | Secondary: Red | Accent: Gold
  /// - Payment status and invoices
  /// - Financial transactions
  /// - Subscription management
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color paymentPrimary = Color(0xFF228B22);
  static const Color paymentSecondary = Color(0xFFCE1141);
  static const Color paymentAccent = Color(0xFFFFB81C);
  static const Color paymentCardBg = Color(0xFFF0FFF0);
  static const Color paymentPaid = Color(0xFF228B22);
  static const Color paymentPending = Color(0xFFFFA500);
  static const Color paymentFailed = Color(0xFFDC143C);
  static const Color paymentDue = Color(0xFFFFA500);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// ADMIN PANEL SCREEN
  /// Primary: Navy Blue | Secondary: Red | Accent: Gold
  /// - System management
  /// - User administration
  /// - Analytics and reports
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color adminPrimary = Color(0xFF002D72);
  static const Color adminSecondary = Color(0xFFCE1141);
  static const Color adminAccent = Color(0xFFFFB81C);
  
  /// Dashboard stats colors
  static const Color adminStatPlayers = Color(0xFF002D72);
  static const Color adminStatDivisions = Color(0xFFFFB81C);
  static const Color adminStatActivities = Color(0xFFCE1141);
  static const Color adminStatPayments = Color(0xFF228B22);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// PROFILE SCREEN
  /// Primary: Navy Blue | Secondary: White | Accent: Red
  /// - User profile information
  /// - Account settings
  /// - Personal statistics
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color profilePrimary = Color(0xFF002D72);
  static const Color profileSecondary = Color(0xFFFFFFFF);
  static const Color profileAccent = Color(0xFFCE1141);
  static const Color profileCardBg = Color(0xFFF5F5F5);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// NOTIFICATIONS SCREEN
  /// Uses semantic colors based on notification type
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color notificationSuccess = successGreen;
  static const Color notificationWarning = warningAmber;
  static const Color notificationError = errorRed;
  static const Color notificationInfo = infoBlue;
  static const Color notificationGeneral = pendingGray;
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// CHAT / MESSAGING SCREEN
  /// Primary: Navy Blue | Secondary: White | Accent: Red
  /// - Real-time messaging
  /// - Chat bubbles
  /// - Notification badges
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color chatPrimary = Color(0xFF002D72);
  static const Color chatSecondary = Color(0xFFFFFFFF);
  static const Color chatAccent = Color(0xFFCE1141);
  static const Color chatBubbleReceived = Color(0xFFF0F0F0);
  static const Color chatBubbleSent = Color(0xFF002D72);
  static const Color chatBubbleText = Color(0xFF333333);
  static const Color chatBubbleSentText = Color(0xFFFFFFFF);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// FORM & INPUT ELEMENTS
  /// Consistent colors for input fields across all screens
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color inputBorderActive = Color(0xFF002D72);
  static const Color inputBorderInactive = Color(0xFFCCCCCC);
  static const Color inputBorderError = Color(0xFFDC143C);
  static const Color inputBorderFocused = Color(0xFF00205E);
  static const Color inputFillLight = Color(0xFFFAFAFA);
  static const Color inputFillDark = Color(0xFF2A2A2A);
  static const Color inputPlaceholder = Color(0xFF999999);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// BUTTON COLORS
  /// Standard button styling across the app
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color buttonPrimary = Color(0xFF002D72);
  static const Color buttonPrimaryHover = Color(0xFF00205E);
  static const Color buttonSecondary = Color(0xFFCE1141);
  static const Color buttonSecondaryHover = Color(0xFFB50D2E);
  static const Color buttonDanger = Color(0xFFDC143C);
  static const Color buttonDangerHover = Color(0xFFBF1129);
  static const Color buttonDisabled = Color(0xFF999999);
  static const Color buttonText = Color(0xFFFFFFFF);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// CHART & DATA VISUALIZATION
  /// For graphs, charts, and data representations
  /// ─────────────────────────────────────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF002D72), // Navy Blue
    Color(0xFFCE1141), // Red
    Color(0xFFFFB81C), // Gold
    Color(0xFF006B42), // Green (Field)
    Color(0xFF228B22), // Forest Green
    Color(0xFFFFA500), // Orange
  ];
  
  static const Color chartGradientStart = Color(0xFF002D72);
  static const Color chartGradientEnd = Color(0xFFCE1141);
  
  /// ─────────────────────────────────────────────────────────────────────────
  /// BADGE & TAG COLORS
  /// For status badges, tags, labels across the app
  /// ─────────────────────────────────────────────────────────────────────────
  static const Color badgeSuccess = Color(0xFF228B22);
  static const Color badgeWarning = Color(0xFFFFB81C);
  static const Color badgeError = Color(0xFFDC143C);
  static const Color badgeInfo = Color(0xFF002D72);
  static const Color badgePending = Color(0xFF999999);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // Helper Methods for Dynamic Color Adjustments
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get background color based on theme brightness
  static Color getBackgroundColor({required bool isDark}) {
    return isDark ? bgDark : bgLight;
  }
  
  /// Get text color based on theme brightness
  static Color getTextColor({required bool isDark}) {
    return isDark ? textLight : textDark;
  }
  
  /// Get secondary text color based on theme brightness
  static Color getSecondaryTextColor({required bool isDark}) {
    return isDark ? textLightSecondary : textDarkSecondary;
  }
  
  /// Get surface color based on theme brightness
  static Color getSurfaceColor({required bool isDark}) {
    return isDark ? surfaceDark : surfaceLight;
  }
  
  /// Get border color based on theme brightness
  static Color getBorderColor({required bool isDark}) {
    return isDark ? borderDark : borderLight;
  }
}
