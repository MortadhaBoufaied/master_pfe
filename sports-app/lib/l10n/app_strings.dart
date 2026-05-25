import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;

  const AppStrings(this.locale);

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  static AppStrings of(BuildContext context) {
    final t = Localizations.of<AppStrings>(context, AppStrings);
    return t ?? const AppStrings(Locale('en'));
  }

  // ---------------------------------------------------------------------------
  // Translation values (UTF-8)
  // NOTE: Keep brand/product names and technical terms in English where needed.
  // ---------------------------------------------------------------------------
  static const Map<String, Map<String, String>> _values = {
    'en': {
      // ---- General / Common UI ----
      'app_name': 'Sports Academy Pro', // keep as brand
      'home': 'Home',
      'welcome': 'Welcome',
      'profile': 'Profile',
      'settings': 'Settings',
      'account': 'Account',
      'appearance': 'Appearance',
      'language': 'Language',
      'navigation': 'Navigation',
      'contact': 'Contact',
      'email': 'Email',
      'phone': 'Phone',
      'address': 'Address',
      'description': 'Description',
      'date': 'Date',
      'location': 'Location',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'ok': 'OK',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',

      // ---- Auth ----
      'login': 'Login',
      'signup': 'Sign up',
      'logout': 'Logout',
      'forgot_password': 'Forgot password?',
      'remember_me': 'Remember me',
      'password': 'Password',
      'confirm_password': 'Confirm password',
      'create_account': 'Create account',
      'already_have_account': 'Already have an account?',
      'dont_have_account': "Don't have an account?",
      'required_fields': 'Please fill the required fields.',
      'missing_required_fields': 'Missing required fields',
      'passwords_do_not_match': 'Passwords do not match',
      'login_failed': 'Login failed. Please check your credentials.',
      'signup_failed': 'Signup failed. Please try again.',

      // ---- Roles / Access ----
      'access_denied': 'Access denied',
      'admin_only': 'Admin only.',
      'trainer_or_admin_only_manage_activities': 'Only trainers or admins can manage activities.',
      'trainer_or_admin_only_access_page': 'Only trainers or admins can access this page.',
      'admin_only_data_management': 'Admin only (Data Management).',

      // ---- Admin / Data hub ----
      'admin_dashboard': 'Admin dashboard',
      'data_management': 'Data management',
      'data_management_subtitle': 'Manage academy data',
      'statistics': 'Statistics',
      'overview': 'Overview',

      // ---- Entities ----
      'players': 'Players',
      'player': 'Player',
      'trainers': 'Trainers',
      'trainer': 'Trainer',
      'parents': 'Parents',
      'parent': 'Parent',
      'admins': 'Admins',
      'admin': 'Admin',
      'division': 'Division',
      'divisions': 'Divisions',
      'unassigned': 'Unassigned',

      // ---- Profile info labels ----
      'trainer_info': 'Trainer information',
      'parent_info': 'Parent information',
      'admin_info': 'Admin information',
      'speciality': 'Speciality',
      'experience': 'Experience',
      'license': 'License',
      'my_children': 'My children',

      // ---- Empty states ----
      'no_data': 'No data available',
      'empty': 'No data found',

      // ---- Actions / CRUD ----
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'create': 'Create',
      'update': 'Update',
      'confirm_delete': 'Confirm delete',
      'open_details': 'Open details',

      // ---- Notifications ----
      'notifications': 'Notifications',
      'mark_read': 'Mark as read',
      'mark_all_read': 'Mark all as read',
      'no_notifications': 'No notifications',

      // ---- Chat / Chatbot ----
      'chat': 'Chat',
      'conversations': 'Conversations',
      'new_message': 'New message',
      'type_message': 'Type a message',
      'send': 'Send',

      'chatbot': 'Chatbot', // keep term
      'chatbot_welcome':
      "Hello! I'm your academy assistant. Ask me about registration, fees, schedules, policies, and contact.",
      'chatbot_welcome_short': "Hello! I'm your academy assistant. How can I help?",
      'chatbot_unreachable':
      "Sorry, I couldn't reach the chatbot server. Please try again later.",

      // ---- Search ----
      'global_search': 'Global search',
      'advanced_search': 'Advanced search',
      'no_results': 'No results',

      // ---- Academy info ----
      'academy_info': 'Academy info',
      'academy_address': 'Address',
      'academy_phone': 'Phone',

      // ---- Activities / Matches ----
      'activities': 'Activities',
      'activity': 'Activity',
      'matches': 'Matches',
      'match': 'Match',
      'training': 'Training',
      'manage_activities': 'Manage Activities',
      'current_week': 'Current week',
      'day_details': 'Day details',
      'no_activities_day': 'No activities for this day',
      'vs_opponent': 'vs {opponent}',

      // Match results labels (UI)
      'result_win': 'Win',
      'result_loss': 'Loss',
      'result_draw': 'Draw',
      'result_unknown': 'Unknown',

      // ---- Statistics (age groups) ----
      'age_under_18': 'Under 18',
      'age_18_21': '18-21',
      'age_22_25': '22-25',
      'age_26_30': '26-30',
      'age_over_30': 'Over 30',

      // ---- Misc dynamic ----
      'section_content': 'Section {index} Content',

      // Theme options
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',

      // Payments
      'payments': 'Payments',
      'paid': 'Paid',
      'unpaid': 'Unpaid',
      'pending': 'Pending',
      'mark_paid': 'Mark as paid',
      'pay_now': 'Pay now',
      'all': 'All',
      'filtered': 'Filtered',
      'total': 'Total',

      // Trainer form messages (from controller)
      'trainer_updated': 'Trainer updated successfully.',
      'trainer_update_failed': 'Failed to update trainer.',
      'trainer_created': 'Trainer created successfully.',
      'trainer_create_failed': 'Failed to create trainer.',
      'trainer_user_create_failed': 'Failed to create user account for trainer.',
      'error_with_details': 'Error: {error}',
    },

    'fr': {
      'app_name': 'Sports Academy Pro',
    },
    'ar': {      'app_name': 'Sports Academy Pro',
    },
  };

  /// Translate a key.
  ///
  /// Supports:
  /// - key normalization (e.g. "Activities" -> "activities")
  /// - simple params replacement: "{name}" style placeholders
  String tr(String key, {Map<String, String>? params}) {
    final rawKey = key.trim();
    final canonical = _canonicalKey(rawKey);

    String? value =
        _values[locale.languageCode]?[rawKey] ??
            _values['en']?[rawKey] ??
            _values[locale.languageCode]?[canonical] ??
            _values['en']?[canonical];

    value ??= rawKey;

    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) {
        value = value!.replaceAll('{$k}', v);
      });
    }

    return value!;
  }

  /// Convert keys like "Activities", "my-children", "My Children" => "activities", "my_children"
  static String _canonicalKey(String key) {
    var k = key.trim();
    k = k.replaceAll('-', '_');
    k = k.replaceAll(RegExp(r'\s+'), '_');
    k = k.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}');
    return k.toLowerCase();
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    return AppStrings(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}


