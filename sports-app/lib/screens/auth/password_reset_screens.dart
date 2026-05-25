import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'auth_shell.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _service = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.forgotPassword(_email.text.trim());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResetCodeVerificationScreen(email: _email.text.trim()),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthFlowScaffold(
      title: 'Forgot password',
      subtitle: 'Enter your email and we will send an 8-digit reset code.',
      icon: Icons.lock_reset_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          if (_error != null) _errorText(context, _error!),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            loading: _loading,
            onPressed: _send,
            label: 'Send reset code',
            icon: Icons.send_rounded,
          ),
          TextButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContactSupportScreen(),
                  ),
                ),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}

class ResetCodeVerificationScreen extends StatefulWidget {
  final String email;

  const ResetCodeVerificationScreen({super.key, required this.email});

  @override
  State<ResetCodeVerificationScreen> createState() =>
      _ResetCodeVerificationScreenState();
}

class _ResetCodeVerificationScreenState
    extends State<ResetCodeVerificationScreen> {
  final _code = TextEditingController();
  final _service = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _service.verifyResetCode(
        email: widget.email,
        code: _code.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UpdatePasswordScreen(resetToken: token),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    await _service.forgotPassword(widget.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('If this email exists, a new code has been sent.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AuthFlowScaffold(
      title: 'Verify code',
      subtitle: 'Enter the 8-digit code sent to ${widget.email}.',
      icon: Icons.pin_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _code,
            maxLength: 8,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '8-digit code',
              prefixIcon: Icon(Icons.pin_rounded),
            ),
          ),
          if (_error != null) _errorText(context, _error!),
          const SizedBox(height: 12),
          AuthPrimaryButton(
            loading: _loading,
            onPressed: _verify,
            label: 'Verify code',
            icon: Icons.verified_rounded,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: _resend, child: const Text('Resend Code')),
              TextButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactSupportScreen(),
                      ),
                    ),
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UpdatePasswordScreen extends StatefulWidget {
  final String resetToken;

  const UpdatePasswordScreen({super.key, required this.resetToken});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _service = AuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.resetPassword(
        resetToken: widget.resetToken,
        newPassword: _newPassword.text,
        confirmPassword: _confirmPassword.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthFlowScaffold(
      title: 'Update password',
      subtitle:
          'Use a strong password with uppercase, lowercase, number, and symbol.',
      icon: Icons.password_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _newPassword,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPassword,
            obscureText: _obscure,
            decoration: const InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: Icon(Icons.lock_reset_rounded),
            ),
          ),
          if (_error != null) _errorText(context, _error!),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            loading: _loading,
            onPressed: _reset,
            label: 'Update password',
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }
}

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController(
    text: 'Password Reset Support Request',
  );
  final _message = TextEditingController();
  final _service = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.contactSupport(
        name: _name.text.trim(),
        email: _email.text.trim(),
        subject: _subject.text.trim(),
        message: _message.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your support request has been sent successfully. We will contact you as soon as possible.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthFlowScaffold(
      title: 'Contact support',
      subtitle: 'Tell us what happened and we will help you recover access.',
      icon: Icons.support_agent_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'Email if known',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _subject,
            decoration: const InputDecoration(
              labelText: 'Subject',
              prefixIcon: Icon(Icons.topic_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _message,
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.message_outlined),
            ),
          ),
          if (_error != null) _errorText(context, _error!),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            loading: _loading,
            onPressed: _send,
            label: 'Send support request',
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }
}

class _AuthFlowScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _AuthFlowScaffold({
    required this.title,
    required this.subtitle,
    this.icon = Icons.lock_reset_rounded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: title,
      subtitle: subtitle,
      icon: icon,
      topAction:
          Navigator.canPop(context)
              ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              )
              : null,
      footer: TextButton.icon(
        onPressed:
            () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (_) => false,
            ),
        icon: const Icon(Icons.login_rounded, size: 18),
        label: const Text('Back to sign in'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthImageBanner(
            eyebrow: 'SECURE RECOVERY',
            title: 'Recover access without leaving the academy flow',
            description:
                'Reset codes, password updates, and support requests stay inside a protected identity journey.',
            icon: icon,
            chips: const ['Reset code', 'Verified email', 'Support'],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

Widget _errorText(BuildContext context, String message) {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: AuthErrorBanner(message: message),
  );
}
