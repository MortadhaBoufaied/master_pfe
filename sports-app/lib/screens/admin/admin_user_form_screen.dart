import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/admin_user.dart';
import '../../services/admin_users_service.dart';

class AdminUserFormScreen extends StatefulWidget {
  final AdminUser? existing;
  const AdminUserFormScreen({super.key, this.existing});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  static const double _radius = 18;
  static const double _cardPad = 14;

  final _service = AdminUsersService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _email;
  final TextEditingController _password = TextEditingController();
  String _role = 'PLAYER';
  bool _saving = false;
  bool _showPassword = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.nom ?? '');
    _email = TextEditingController(text: widget.existing?.email ?? '');
    _role = widget.existing?.mainRole?.toUpperCase() ?? 'PLAYER';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (isEdit) {
        final u = AdminUser(
          id: widget.existing!.id,
          nom: _name.text.trim(),
          email: _email.text.trim(),
          mainRole: _role,
        );
        final ok = await _service.updateUser(u);
        if (!ok) throw Exception('Update failed');
      } else {
        final ok = await _service.createUser(
          nom: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          role: _role,
        );
        if (ok == null) throw Exception('Create failed');
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        _buildBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(isEdit ? 'Edit User' : 'Create New User'),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informational card with glass effect
                      _glassCard(
                        padding: const EdgeInsets.all(_cardPad),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF14B8A6,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info,
                                color: Color(0xFF14B8A6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isEdit
                                    ? 'Update admin user details'
                                    : 'Create a new admin user account',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Form Fields Card with soft effect
                      _softCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Full Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _name,
                              decoration: InputDecoration(
                                hintText: 'Enter full name',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.person, size: 20),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF14B8A6),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Please enter a name'
                                          : null,
                            ),

                            const SizedBox(height: 16),

                            // Email field
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'user@example.com',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.email, size: 20),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF14B8A6),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!v.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Role field
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'User Role',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _role,
                              decoration: InputDecoration(
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.security, size: 20),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF14B8A6),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'PLAYER',
                                  child: Text('Player'),
                                ),
                                DropdownMenuItem(
                                  value: 'PARENT',
                                  child: Text('Parent'),
                                ),
                                DropdownMenuItem(
                                  value: 'TRAINER',
                                  child: Text('Trainer'),
                                ),
                                DropdownMenuItem(
                                  value: 'SCOUTER',
                                  child: Text('Scouter'),
                                ),
                                DropdownMenuItem(
                                  value: 'ADMIN',
                                  child: Text('Admin'),
                                ),
                              ],
                              onChanged:
                                  (v) => setState(() => _role = v ?? 'PLAYER'),
                            ),

                            if (!isEdit) ...[
                              const SizedBox(height: 16),

                              // Password field
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _password,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  hintText: 'Minimum 6 characters',
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(Icons.lock, size: 20),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: IconButton(
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 18,
                                      ),
                                      onPressed:
                                          () => setState(
                                            () =>
                                                _showPassword = !_showPassword,
                                          ),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.06),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF14B8A6),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (v.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _saving ? null : () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.withOpacity(0.3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF14B8A6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: const Color(
                                  0xFF14B8A6,
                                ).withOpacity(0.5),
                              ),
                              icon:
                                  _saving
                                      ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white.withOpacity(0.7),
                                              ),
                                        ),
                                      )
                                      : const Icon(Icons.save, size: 18),
                              label: Text(
                                _saving
                                    ? (isEdit ? 'Updating' : 'Creating')
                                    : (isEdit ? 'Update' : 'Create'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [
                    const Color(0xFF012D1D).withValues(alpha: 0.32),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.88),
                  ]
                  : [
                    const Color(0xFFE7F4ED),
                    Theme.of(context).colorScheme.surface,
                  ],
        ),
      ),
    );
  }

  Widget _softCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surface.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.72 : 0.94,
        ),
        border: Border.all(color: cs.outline.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: isDark ? 0.76 : 0.94),
              border: Border.all(color: cs.outline.withOpacity(0.15), width: 1),
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}


