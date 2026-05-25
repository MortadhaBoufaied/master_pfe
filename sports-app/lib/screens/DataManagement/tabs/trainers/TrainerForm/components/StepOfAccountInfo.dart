import 'package:flutter/material.dart';

class TrainerAccountInfoStep extends StatelessWidget {
  final bool isEditing;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordVerifyController;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController verifyNewPasswordController;

  const TrainerAccountInfoStep({
    Key? key,
    required this.isEditing,
    required this.emailController,
    required this.passwordController,
    required this.passwordVerifyController,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.verifyNewPasswordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Column(
        children: [
          _buildTextField(emailController, '   *'),
          if (isEditing) ...[
            _buildTextField(currentPasswordController, '    *', obscureText: true),
            _buildTextField(newPasswordController, '    *', obscureText: true),
            _buildTextField(verifyNewPasswordController, '      *', obscureText: true),
          ] else ...[
            _buildTextField(passwordController, '  *', obscureText: true),
            _buildTextField(passwordVerifyController, '    *', obscureText: true),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}


