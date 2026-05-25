import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'components/app_background.dart';
import 'components/role_guard.dart';

import 'controllers/AuthState.dart';
import 'controllers/academy_theme_controller.dart';
import 'controllers/app_settings_controller.dart';
import 'controllers/session_controller.dart';

import 'l10n/app_strings.dart';
import 'models/role.dart';
import 'models/unified_activity.dart';

// Screens
import 'screens/MainPage/MainAppScreen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/SignupScreen.dart';
import 'screens/auth/auth_splash_screen.dart';
import 'screens/auth/password_reset_screens.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/notifications/admin_send_notification_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/AdvancedSearchScreen.dart';
import 'screens/StatisticsScreen.dart';
import 'screens/user/profile_router_screen.dart';
import 'screens/user/user_activities_screen.dart';
import 'screens/user/user_payments_screen.dart';
import 'screens/user/trainer_manage_activities_screen.dart';
import 'screens/user/trainer_player_stats_screen.dart';
import 'screens/user/academy_info_screen.dart';
import 'screens/DataManagement/data_hub_screen.dart';
import 'screens/search/global_search_screen.dart';
import 'screens/scouting/scouting_dashboard_screen.dart';
import 'screens/scouting/scouter_dashboard_screen.dart';
import 'screens/admin/admin_portal_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_web_parity_screen.dart';
import 'screens/super_admin/super_admin_module_screens.dart';

import 'components/academy_admins_access_guard.dart';
import 'theme/app_theme.dart';

// ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ Chat (NONÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œV3)
import 'screens/MainPage/pages/chat/chat_conversations_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await AuthSession.instance.state.tryRestoreSession();
  await AppSession.instance.session.loadFromStorage();
  await AppSettings.instance.controller.load();
  if (AuthSession.instance.state.isAuthenticated.value) {
    await AppAcademyTheme.instance.controller.load(force: true);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthState authState;

  MyApp({super.key, AuthState? authState})
    : authState = authState ?? AuthSession.instance.state;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance.controller;
    final academyTheme = AppAcademyTheme.instance.controller;

    return AnimatedBuilder(
      animation: Listenable.merge([settings, academyTheme]),
      builder: (context, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: authState.isAuthenticated,
          builder: (context, loggedIn, __) {
            return MaterialApp(
              key: ValueKey('${loggedIn}_${settings.locale.languageCode}'),
              debugShowCheckedModeBanner: false,
              title: 'Football Academy Pro',

              themeMode: settings.themeMode,
              theme: AppTheme.light(academyTheme: academyTheme.theme),
              darkTheme: AppTheme.dark(academyTheme: academyTheme.theme),

              locale: settings.locale,
              supportedLocales: AppStrings.supportedLocales,
              localizationsDelegates: const [
                AppStrings.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                return AppBackground(child: child ?? const SizedBox.shrink());
              },

              home:
                  loggedIn
                      ? const MainAppScreen(isFirstLogin: false)
                      : const AuthSplashScreen(),

              routes: {
                '/home': (_) => const MainAppScreen(isFirstLogin: false),
                '/login': (_) => const AuthSplashScreen(),
                '/login/form': (_) => const LoginScreen(),
                '/auth-splash': (_) => const AuthSplashScreen(),
                '/signup': (_) => const SignupScreen(),
                '/forgot-password': (_) => const ForgotPasswordScreen(),
                '/contact-support': (_) => const ContactSupportScreen(),
                '/notifications': (_) => const NotificationsScreen(),
                '/send-notification':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage:
                          'Only admins or super admins can send broadcast notifications.',
                      child: AdminSendNotificationScreen(),
                    ),
                '/chatbot': (_) => const ChatbotScreen(),
                '/advanced-search': (_) => const AdvancedSearchScreen(),
                '/statistics': (_) => const StatisticsScreen(),

                '/profile': (_) => const AccountProfileRouterScreen(),
                '/my-activities': (_) => const UserActivitiesScreen(),
                '/my-matches':
                    (_) => const UserActivitiesScreen(
                      initialFilter: ActivityFilter.matches,
                    ),
                '/my-payments': (_) => const UserPaymentsScreen(),
                '/academy-info': (_) => const AcademyInfoScreen(),
                '/global-search': (_) => const GlobalSearchScreen(),

                '/chat': (_) => const ChatConversationsScreen(),

                // Trainer-only screens
                '/trainer-activities':
                    (_) => const RoleGuard(
                      allow: {Role.trainer},
                      deniedMessage: 'Only trainers can manage activities.',
                      child: TrainerManageActivitiesScreen(),
                    ),
                '/trainer-player-stats':
                    (_) => const RoleGuard(
                      allow: {Role.trainer, Role.admin, Role.superAdmin},
                      deniedMessage:
                          'Only trainers or admins can access this page.',
                      child: TrainerPlayerStatsScreen(),
                    ),
                '/admin/player-development':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: TrainerPlayerStatsScreen(),
                    ),

                '/data-management': (context) {
                  return const RoleGuard(
                    allow: {Role.admin, Role.superAdmin},
                    deniedMessage: 'Admin only (Data Management).',
                    child: DataHubScreen(),
                  );
                },
                '/admin':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: AdminPortalScreen(),
                    ),
                '/admin/dashboard':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: AdminPortalScreen(),
                    ),
                '/admin/users':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 0),
                    ),
                '/admin/divisions':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 1),
                    ),
                '/admin/unassigned':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 2),
                    ),
                '/admin/players':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 3),
                    ),
                '/admin/trainers':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 4),
                    ),
                '/admin/parents':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 5),
                    ),
                '/admin/activities':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 6),
                    ),
                '/admin/matches':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(
                        initialIndex: 6,
                        initialActivityFilter: UnifiedActivityType.match,
                      ),
                    ),
                '/admin/payments':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: DataHubScreen(initialIndex: 7),
                    ),
                '/admin/notifications':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: AdminSendNotificationScreen(),
                    ),
                '/admin/chatbot':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: ChatbotScreen(settingsRoute: '/admin/chatbot-web'),
                    ),
                '/admin/subscription':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: AdminServiceDetailScreen(
                        title: 'Subscription',
                        subtitle:
                            'Review academy offer, billing locks, and premium service access.',
                        icon: Icons.workspace_premium_rounded,
                      ),
                    ),
                '/admin/reports':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: StatisticsScreen(),
                    ),
                '/admin/settings':
                    (_) => const RoleGuard(
                      allow: {Role.admin, Role.superAdmin},
                      deniedMessage: 'Admin only.',
                      child: AcademyInfoScreen(),
                    ),
                '/super-admin':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminPortalScreen(),
                    ),
                '/super-admin/dashboard':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminPortalScreen(),
                    ),
                '/super-admin/academies':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminAcademiesScreen(),
                    ),
                '/super-admin/sports':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminSportsScreen(),
                    ),
                '/super-admin/sport-categories':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminSportsScreen(),
                    ),
                '/super-admin/themes':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminThemesScreen(),
                    ),
                '/super-admin/contact-admins':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminContactsScreen(),
                    ),
                '/super-admin/app-data':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminAppDataScreen(),
                    ),
                '/super-admin/chatbot-global':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminChatbotScreen(),
                    ),
                '/super-admin/webhooks':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminWebhooksScreen(),
                    ),
                '/super-admin/academy-payments':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminAcademyPaymentsScreen(),
                    ),
                '/super-admin/settings':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: SuperAdminSettingsScreen(),
                    ),
                '/admin/web-dashboard':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'dashboard',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/data-management-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'data-management',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/users-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'users',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/divisions-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'divisions',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/matches-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'matches',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/players-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'players',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/trainers-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'trainers',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/parents-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'parents',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/activities-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'activities',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/payments-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'payments',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/notifications-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'notifications',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/chat-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'chat',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/chatbot-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'chatbot',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/profile-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'profile',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/reports-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'reports',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/settings-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'settings',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/subscription-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'subscription',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/admin/contact-web':
                    (_) => const RoleGuard(
                      allow: {Role.admin},
                      deniedMessage: 'Admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'contact',
                        role: AdminWebRole.admin,
                      ),
                    ),
                '/super-admin/web-dashboard':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'dashboard',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/academies-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'academies',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/sports-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'sports',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/sport-categories-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'sport-categories',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/themes-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'themes',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/contact-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'contact',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/app-data-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'app-data',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/chatbot-global-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'chatbot-global',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/webhooks-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'webhooks',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/academy-payments-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'academy-payments',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/super-admin/settings-web':
                    (_) => const RoleGuard(
                      allow: {Role.superAdmin},
                      deniedMessage: 'Super admin only.',
                      child: AdminWebParityScreen(
                        moduleKey: 'settings',
                        role: AdminWebRole.superAdmin,
                      ),
                    ),
                '/admin-users': (context) {
                  return const RoleGuard(
                    allow: {Role.admin, Role.superAdmin},
                    deniedMessage:
                        'Only admins or super admins can manage users.',
                    child: AdminUsersScreen(),
                  );
                },
                '/admin/academy-admins': (context) {
                  return const RoleGuard(
                    allow: {Role.admin, Role.superAdmin},
                    deniedMessage: 'Admin only.',
                    child: AcademyAdminsAccessGuard(),
                  );
                },
                '/scouting': (context) {
                  return const RoleGuard(
                    allow: {Role.scouter},
                    deniedMessage: 'Only scouters can access scouting AI.',
                    child: ScoutingDashboardScreen(),
                  );
                },
                '/scouter-dashboard': (context) {
                  return const RoleGuard(
                    allow: {Role.scouter},
                    deniedMessage:
                        'Only scouters can access the scouter dashboard.',
                    child: ScouterDashboardScreen(),
                  );
                },
              },
            );
          },
        );
      },
    );
  }
}
