import 'package:flutter/material.dart';
import '../../../../../../controllers/TrainerFormController.dart';

class PersonalInfoStep extends StatelessWidget {
  final TrainerFormController controller;

  const PersonalInfoStep({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Column(
        children: [
          _buildTextField(controller.nameController, ' *'),
          _buildDateField(context),
          _buildTextField(controller.phoneNumberController, '  *'),
          _buildTextField(controller.regionController, '  '),
          _buildTextField(controller.experienceController, '  '),
          _buildTextField(controller.licenseController, '   / '),
          _buildSpecialtyDropdown(context),
          _buildTextField(controller.notesController, '  '),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false}) {
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

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime selectedDate = DateTime.now();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          controller.dobController.text = "${picked.toLocal()}".split(' ')[0];
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller.dobController,
          decoration: const InputDecoration(
            labelText: '    *',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.selectedSpecialty,
      items: controller.specialties.map((s) {
        return DropdownMenuItem<String>(
          value: s,
          child: Text(s),
        );
      }).toList(),
      onChanged: (value) {
        controller.selectedSpecialty = value!;
      },
      decoration: InputDecoration(
        labelText: ' *',
        border: const OutlineInputBorder(),
      ),
    );
  }
}


