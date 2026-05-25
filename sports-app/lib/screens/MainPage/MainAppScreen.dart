import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moez_project/screens/MainPage/pages/chat/chat_conversations_screen.dart';
import 'package:moez_project/screens/MainPage/pages/settings_page.dart';
import 'package:moez_project/screens/chatbot/chatbot_screen.dart';

import '../../components/NavigationLink.dart';
import '../../controllers/session_controller.dart';
import '../../models/role.dart';
import '../../services/chat_service.dart';
import 'pages/role_home_dashboard.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_portal_screen.dart';
import '../admin/admin_web_parity_screen.dart';
import '../super_admin/super_admin_home_screen.dart';
import '../super_admin/super_admin_dashboard.dart';
import '../user/profile_router_screen.dart';

class MainAppScreen extends StatefulWidget {
  final bool isFirstLogin;

  const MainAppScreen({
    super.key,
    required this.isFirstLogin,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentSection = 0;

  Role get _role => AppSession.instance.session.role;
  final ChatService _chatService = ChatService();

  bool get _isSuperAdmin => _role == Role.superAdmin;

  bool get _isAdminLike => _role == Role.admin || _role == Role.superAdmin;

  List<String> get _sectionTitles {
    if (_isSuperAdmin) {
      return const [
        'Command Center',
        'Platform Analytics',
        'Admin Comms',
        'Platform Settings',
      ];
    }

    if (_role == Role.admin) {
      return const [
        'Admin Command',
        'Web Pages',
        'Messages',
        'Settings',
      ];
    }

    return const [
      'Home',
      'Messages',
      'Profile',
      'Settings',
    ];
  }

  String get _appBarSubtitle {
    if (_isSuperAdmin) {
      switch (_currentSection) {
        case 0:
          return 'Fast links and grouped super-admin services';
        case 1:
          return 'Platform analytics and super admin dashboard';
        case 2:
          return 'Admin communications and platform messages';
        case 3:
        default:
          return 'Profile, settings, themes, and global configuration';
      }
    }

    if (_role == Role.admin) {
      switch (_currentSection) {
        case 0:
          return 'Academy operations and admin command panel';
        case 1:
          return 'Academy web pages and management modules';
        case 2:
          return 'Academy conversations and messages';
        case 3:
        default:
          return 'Academy profile, settings, and preferences';
      }
    }

    switch (_currentSection) {
      case 0:
        return 'Home page';
      case 1:
        return 'Messages and conversations';
      case 2:
        return 'Your profile and academy identity';
      case 3:
      default:
        return 'Settings and preferences';
    }
  }

  List<NavigationItem> get _bottomNavItems {
    if (_isSuperAdmin) {
      return const [
        NavigationItem(Icons.dashboard_customize_rounded, 'Command'),
        NavigationItem(Icons.analytics_rounded, 'Analytics'),
        NavigationItem(Icons.forum_rounded, 'Comms'),
        NavigationItem(Icons.tune_rounded, 'Settings'),
      ];
    }

    if (_role == Role.admin) {
      return const [
        NavigationItem(Icons.admin_panel_settings_rounded, 'Portal'),
        NavigationItem(Icons.web_asset_rounded, 'Web'),
        NavigationItem(Icons.forum_rounded, 'Chat'),
        NavigationItem(Icons.settings_rounded, 'Settings'),
      ];
    }

    return const [
      NavigationItem(Icons.home_rounded, 'Home'),
      NavigationItem(Icons.chat_bubble_outline_rounded, 'Chat'),
      NavigationItem(Icons.person_rounded, 'Profile'),
      NavigationItem(Icons.settings_rounded, 'Settings'),
    ];
  }

  @override
  void initState() {
    super.initState();

    if (widget.isFirstLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    }
  }

  void _showWelcomeDialog() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_soccer_rounded,
              color: cs.primary,
              size: 30,
            ),
          ),
          title: const Text(
            'Welcome back',
            textAlign: TextAlign.center,
          ),
          content: Text(
            _isAdminLike
                ? 'Your web-parity admin workspace is ready.'
                : 'Your academy workspace is ready.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _openAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatbotScreen(),
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatConversationsScreen(),
      ),
    );
  }

  Future<void> _contactAdmin() async {
    try {
      final conversationId = await _chatService.contactAdmin();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationsScreen(
            initialConversationId: conversationId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to contact admin: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _topAction({
    required IconData icon,
    required String tooltip,
    required String moduleKey,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminWebParityScreen(
              moduleKey: moduleKey,
              role: AdminWebRole.superAdmin,
            ),
          ),
        ),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.16),
            ),
          ),
          child: Icon(
            icon,
            color: cs.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> _appBarActions() {
    return [
      Tooltip(
        message: 'Contact Admin',
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _contactAdmin,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: cs.surface,
        appBar: TopNavigationBar(
          title: _sectionTitles[_currentSection],
          subtitle: _appBarSubtitle,
          extraActions: _appBarActions(),
          onSearchTap: () => Navigator.pushNamed(context, '/global-search'),
          onNotificationTap: () => Navigator.pushNamed(context, '/notifications'),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Padding(
                  key: ValueKey(_currentSection),
                  padding: const EdgeInsets.only(bottom: 92),
                  child: _buildCurrentSection(),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SectionNavigation(
                currentSection: _currentSection,
                items: _bottomNavItems,
                onSectionSelected: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentSection = index);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: (!_isAdminLike && _currentSection == 0)
            ? Padding(
          padding: const EdgeInsets.only(bottom: 82),
          child: FloatingActionButton(
            tooltip: 'Assistant',
            onPressed: _openAssistant,
            child: const Icon(Icons.auto_awesome_rounded),
          ),
        )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildCurrentSection() {
    if (_isSuperAdmin) {
      switch (_currentSection) {
        case 0:
          return const SuperAdminHomeScreen();
        case 1:
          return const SuperAdminDashboard(embedded: true);
        case 2:
          return const ChatConversationsScreen();
        case 3:
        default:
          return const SettingsSection();
      }
    }

    if (_role == Role.admin) {
      switch (_currentSection) {
        case 0:
          return const AdminPortalScreen(embedded: true);
        case 1:
          return const AdminWebParityScreen(
            moduleKey: 'data-management',
            role: AdminWebRole.admin,
            embedded: true,
          );
        case 2:
          return const ChatConversationsScreen();
        case 3:
        default:
          return const SettingsSection();
      }
    }

    switch (_currentSection) {
      case 0:
        return RoleHomeDashboard(
          onContactPressed: _openChat,
        );
      case 1:
        return const ChatConversationsScreen();
      case 2:
        return const AccountProfileRouterScreen();
      case 3:
      default:
        return const SettingsSection();
    }
  }
}

