// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../components/AuthTextField.dart';
import '../../controllers/AuthState.dart';
import '../../controllers/academy_theme_controller.dart';
import '../../controllers/authController.dart';
import '../../controllers/session_controller.dart';
import '../../models/role.dart';
import 'auth_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();
  final TextEditingController _confirmCtl = TextEditingController();

  final AuthController _authController = AuthController();

  bool _loading = false;
  String? _error;
  String _selectedRole = 'PLAYER';

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  Future<void> _doSignup() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final ok = await _authController.signup(
        nom: _nameCtl.text.trim(),
        email: _emailCtl.text.trim(),
        password: _passwordCtl.text,
        mainRole: _selectedRole,
        extra: {'nom': _nameCtl.text.trim()},
      );

      if (!ok) {
        setState(() => _error = 'Unable to create account. Please try again.');
        return;
      }

      await AppSession.instance.session.loadFromStorage();
      await AppSession.instance.session.refreshFromServer();

      final logged = await AuthSession.instance.state.signIn(
        _emailCtl.text.trim(),
        _passwordCtl.text,
      );

      if (!mounted) return;
      if (logged) {
        await AppAcademyTheme.instance.controller.load(force: true);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() => _error = 'Signup error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Join the academy',
      subtitle:
          'Create your account and connect to the right sport role inside the academy workspace.',
      icon: Icons.person_add_alt_1_rounded,
      topAction: TextButton.icon(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        icon: const Icon(Icons.login_rounded, size: 18),
        label: const Text('Sign in'),
      ),
      footer: TextButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        child: const Text('Already have an account? Sign in'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthImageBanner(
              eyebrow: 'NEW MEMBER SETUP',
              title: 'Choose the role before the journey starts',
              description:
                  'The academy app adapts permissions, dashboards, reports, and scouting views from this first setup.',
              icon: Icons.diversity_3_rounded,
              chips: ['Player', 'Trainer', 'Scouter'],
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _nameCtl,
              label: 'Full name',
              hintText: 'Your name',
              prefixIcon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _emailCtl,
              label: 'Email',
              hintText: 'name@example.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _RoleSelector(
              selectedRole: _selectedRole,
              onChanged: (role) => setState(() => _selectedRole = role),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordCtl,
              label: 'Password',
              hintText: 'At least 4 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 4) {
                  return 'Password must be at least 4 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _confirmCtl,
              label: 'Confirm password',
              hintText: 'Repeat your password',
              prefixIcon: Icons.verified_user_outlined,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordCtl.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AuthErrorBanner(message: _error!),
            ],
            const SizedBox(height: 18),
            AuthPrimaryButton(
              loading: _loading,
              onPressed: _doSignup,
              label: 'Create account',
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleSelector({required this.selectedRole, required this.onChanged});

  static const _roles = [
    _RoleOption('PLAYER', 'Player', Icons.sports_soccer_rounded),
    _RoleOption('PARENT', 'Parent', Icons.family_restroom_rounded),
    _RoleOption('TRAINER', 'Trainer', Icons.sports_rounded),
    _RoleOption('SCOUTER', 'Scouter', Icons.manage_search_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FormField<String>(
      initialValue: selectedRole,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select a role';
        final parsed = RoleParsing.fromString(value);
        if (parsed == Role.unknown) return 'Invalid role';
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _roles.map((option) {
                    final selected = selectedRole == option.value;
                    return InkWell(
                      onTap: () {
                        onChanged(option.value);
                        field.didChange(option.value);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? cs.primary.withValues(alpha: 0.12)
                                  : cs.surfaceContainerHighest.withValues(
                                    alpha: 0.50,
                                  ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                selected
                                    ? cs.primary
                                    : cs.outlineVariant.withValues(alpha: 0.65),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              option.icon,
                              size: 18,
                              color:
                                  selected ? cs.primary : cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              option.label,
                              style: TextStyle(
                                color: selected ? cs.primary : cs.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Text(
                field.errorText!,
                style: TextStyle(
                  color: cs.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RoleOption {
  final String value;
  final String label;
  final IconData icon;

  const _RoleOption(this.value, this.label, this.icon);
}
