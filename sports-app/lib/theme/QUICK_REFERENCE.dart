/// QUICK COLOR REFERENCE CARD
/// Copy this to your clipboard or print it!
/// ════════════════════════════════════════════════════════════════════════════

/*

╔════════════════════════════════════════════════════════════════════════════╗
║               SPORTS APP - CENTRALIZED THEME QUICK REFERENCE              ║
╚════════════════════════════════════════════════════════════════════════════╝

📍 IMPORT REQUIRED:
   import 'package:your_app/theme/app_colors.dart';

═══════════════════════════════════════════════════════════════════════════════

🏠 HOME / DASHBOARD
   ├─ Primary:   AppColors.homePrimary    (Teal    #009688)
   ├─ Secondary: AppColors.homeSecondary  (Orange  #FF9800)
   └─ Accent:    AppColors.homeAccent     (Lime    #63E6A6)

👥 PLAYER MANAGEMENT
   ├─ Primary:   AppColors.playerPrimary    (Teal   #009688)
   ├─ Secondary: AppColors.playerSecondary  (Blue   #2563EB)
   └─ Accent:    AppColors.playerAccent     (Green  #27AE60)

🔍 SCOUTING REPORTS
   ├─ Primary:     AppColors.scoutingPrimary    (Violet       #7C3AED)
   ├─ Secondary:   AppColors.scoutingSecondary  (Blue         #2563EB)
   ├─ Accent:      AppColors.scoutingAccent     (Lime         #63E6A6)
   ├─ Excellent:   AppColors.scoutingExcellent  (Green        #22C55E)
   ├─ Good:        AppColors.scoutingGood       (Blue         #3B82F6)
   ├─ Average:     AppColors.scoutingAverage    (Orange       #F59E0B)
   └─ Poor:        AppColors.scoutingPoor       (Red          #FF6B6B)

🏋️ TRAINING SESSIONS
   ├─ Primary:     AppColors.trainingPrimary    (Pitch Green  #0E7C66)
   ├─ Secondary:   AppColors.trainingSecondary  (Orange       #FF9800)
   ├─ Accent:      AppColors.trainingAccent     (Lime         #63E6A6)
   ├─ Active:      AppColors.trainingActive     (Green        #22C55E)
   ├─ Scheduled:   AppColors.trainingScheduled  (Blue         #3B82F6)
   ├─ Completed:   AppColors.trainingCompleted  (Teal Light   #4DB6AC)
   └─ Cancelled:   AppColors.trainingCancelled  (Red          #FF6B6B)

⚽ MATCHES
   ├─ Primary:     AppColors.matchPrimary    (Orange      #FF9800)
   ├─ Secondary:   AppColors.matchSecondary  (Teal        #009688)
   ├─ Accent:      AppColors.matchAccent     (Blue        #2563EB)
   ├─ Upcoming:    AppColors.matchUpcoming   (Blue        #3B82F6)
   ├─ Live:        AppColors.matchLive       (Red         #FF6B6B)
   ├─ Completed:   AppColors.matchCompleted  (Green       #22C55E)
   └─ Cancelled:   AppColors.matchCancelled  (Gray        #6B7280)

💰 PAYMENTS
   ├─ Primary:     AppColors.paymentPrimary    (Green        #22C55E)
   ├─ Secondary:   AppColors.paymentSecondary  (Orange       #FF9800)
   ├─ Accent:      AppColors.paymentAccent     (Blue         #2563EB)
   ├─ Paid:        AppColors.paymentPaid       (Green        #22C55E)
   ├─ Pending:     AppColors.paymentPending    (Orange       #F59E0B)
   ├─ Failed:      AppColors.paymentFailed     (Red          #FF6B6B)
   └─ Due:         AppColors.paymentDue        (Orange       #F59E0B)

⚙️ ADMIN PANEL
   ├─ Primary:     AppColors.adminPrimary    (Teal         #009688)
   ├─ Secondary:   AppColors.adminSecondary  (Blue         #2563EB)
   ├─ Accent:      AppColors.adminAccent     (Violet       #7C3AED)
   ├─ Players:     AppColors.adminStatPlayers (Teal        #14B8A6)
   ├─ Divisions:   AppColors.adminStatDivisions (Orange    #F59E0B)
   ├─ Activities:  AppColors.adminStatActivities (Blue     #3B82F6)
   └─ Payments:    AppColors.adminStatPayments (Green      #22C55E)

👤 PROFILE
   ├─ Primary:   AppColors.profilePrimary    (Teal     #009688)
   ├─ Secondary: AppColors.profileSecondary  (Violet   #7C3AED)
   └─ Accent:    AppColors.profileAccent     (Orange   #FF9800)

💬 CHAT / MESSAGING
   ├─ Primary:     AppColors.chatPrimary       (Teal          #009688)
   ├─ Secondary:   AppColors.chatSecondary     (Violet        #7C3AED)
   ├─ Accent:      AppColors.chatAccent        (Blue          #2563EB)
   ├─ Sent Bubble: AppColors.chatBubbleSent    (Teal          #009688)
   └─ Received:    AppColors.chatBubbleReceived (Light Gray    #F0F5F4)

═══════════════════════════════════════════════════════════════════════════════

🎨 SEMANTIC COLORS (Use for status/feedback across any screen):

   ✅ SUCCESS:  AppColors.successGreen      (#22C55E)
   ⚠️  WARNING:  AppColors.warningAmber      (#F59E0B)
   ❌ ERROR:    AppColors.errorRed          (#FF6B6B)
   ℹ️  INFO:     AppColors.infoBlue          (#3B82F6)
   ⏳ PENDING:   AppColors.pendingGray       (#6B7280)

═══════════════════════════════════════════════════════════════════════════════

🌓 DARK MODE HELPERS (Always use for theme-aware colors):

   Background:  AppColors.getBackgroundColor(isDark: isDark)
   Text:        AppColors.getTextColor(isDark: isDark)
   Text2:       AppColors.getSecondaryTextColor(isDark: isDark)
   Surface:     AppColors.getSurfaceColor(isDark: isDark)
   Border:      AppColors.getBorderColor(isDark: isDark)

═══════════════════════════════════════════════════════════════════════════════

🎯 USAGE EXAMPLE:

   ✅ RIGHT:
   ─────────────────────────────────────────────────────────────────────────
   class PlayerCard extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Container(
         color: AppColors.playerCardBg,
         child: Text(
           'Player Name',
           style: TextStyle(color: AppColors.playerPrimary),
         ),
       );
     }
   }

   ❌ WRONG:
   ─────────────────────────────────────────────────────────────────────────
   class PlayerCard extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Container(
         color: Color(0xFFE8F5F3),          // Hardcoded!
         child: Text(
           'Player Name',
           style: TextStyle(color: Color(0xFF009688)),  // Hardcoded!
         ),
       );
     }
   }

═══════════════════════════════════════════════════════════════════════════════

📋 CHECKLIST:

   ☐ Import AppColors in every screen file
   ☐ Use AppColors.screenName* for all colors
   ☐ Comment your screen's theme at the top
   ☐ No hardcoded Color(0xFF...) values
   ☐ Use semantic colors for status
   ☐ Use helper methods for dark mode
   ☐ Test both light and dark themes

═══════════════════════════════════════════════════════════════════════════════

📚 REFERENCE FILES:

   lib/theme/app_colors.dart      ← All color definitions (EDIT HERE)
   lib/theme/app_theme.dart       ← Material theme config
   lib/theme/THEME_USAGE_GUIDE.dart ← Code examples
   THEME_DOCUMENTATION.md         ← Full documentation

═══════════════════════════════════════════════════════════════════════════════

💡 QUICK TIPS:

   1. All screens have a primary + secondary + accent theme
   2. Status colors are consistent across the app
   3. Use getBackgroundColor() for theme-aware backgrounds
   4. Chart colors are pre-defined in AppColors.chartColors
   5. Badge colors match semantic colors (success, warning, error, info)

═══════════════════════════════════════════════════════════════════════════════

*/

import 'package:flutter/material.dart';
import 'app_colors.dart';

// This file is for reference - copy the colors you need to your screens!
// Always import AppColors and use AppColors.* instead of Color(0xFF...)

class QuickReferenceExample {
  
  /// Example: How to use the theme in a real screen
  static Widget buildExampleCard() {
    return Card(
      color: AppColors.playerCardBg,  // ✅ Using theme
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Player Information',
              style: TextStyle(
                color: AppColors.playerPrimary,  // ✅ Primary color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Status: Active',
              style: TextStyle(
                color: AppColors.trainingActive,  // ✅ Semantic color
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example: How to show status with the right color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.paymentPaid;  // ✅ Semantic green
      case 'pending':
        return AppColors.paymentPending;  // ✅ Semantic orange
      case 'failed':
        return AppColors.paymentFailed;  // ✅ Semantic red
      default:
        return AppColors.pendingGray;  // ✅ Default neutral
    }
  }

  /// Example: How to support dark mode
  static Color getDarkModeAwareColor(bool isDark) {
    return AppColors.getSurfaceColor(isDark: isDark);  // ✅ Auto theme
  }
}
