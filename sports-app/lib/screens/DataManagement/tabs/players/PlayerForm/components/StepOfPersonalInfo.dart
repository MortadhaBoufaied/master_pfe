import 'package:flutter/material.dart';
import 'player_form_controller.dart';

class PlayerPersonalInfoStep extends StatelessWidget {
  final PlayerFormController controller;
  final VoidCallback? onDateSelected;

  final bool isCreate;

  const PlayerPersonalInfoStep({
    Key? key,
    required this.controller,
    this.onDateSelected,
    this.isCreate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField(controller.nomController, 'Name', isRequired: true),
          GestureDetector(
            onTap: onDateSelected,
            child: AbsorbPointer(
              child: _buildTextField(controller.dateNaissanceController, 'Date of birth', isRequired: true),
            ),
          ),
          _buildTextField(controller.telController, 'Phone', isRequired: true),
          _buildTextField(controller.emailController, 'Email', keyboardType: TextInputType.emailAddress),

          if (isCreate)
            _buildTextField(controller.passwordController, 'Password',
                isRequired: true, obscureText: true),

          _buildTextField(controller.nationaliteController, 'Nationality'),
          _buildTextField(controller.ageController, 'Age', keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController c,
      String label, {
        bool isRequired = false,
        int maxLines = 1,
        TextInputType? keyboardType,
        bool obscureText = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}


