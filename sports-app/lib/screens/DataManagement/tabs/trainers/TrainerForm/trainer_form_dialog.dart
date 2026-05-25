import 'package:flutter/material.dart';

import '../../../../../models/trainer.dart';

class TrainerFormDialog extends StatefulWidget {
  final Trainer? trainer;
  final Function(Map<String, dynamic>) onSubmit;

  const TrainerFormDialog({
    Key? key,
    this.trainer,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _TrainerFormDialogState createState() => _TrainerFormDialogState();
}

class _TrainerFormDialogState extends State<TrainerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _licenseController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedSpecialty;
  bool _isLoading = false;

  final List<String> _specialties = [
    'Youth Development',
    'Fitness Coach',
    'Goalkeeping Coach',
    'Tactical Coach',
    'Technical Coach',
    'Head Coach',
    'Assistant Coach',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.trainer != null) {
      _nameController.text = widget.trainer!.name ?? '';
      _emailController.text = widget.trainer!.email ?? '';
      _phoneController.text = widget.trainer!.phone ?? '';
      _specialtyController.text = widget.trainer!.specialty ?? '';
      _experienceController.text = widget.trainer!.experience ?? '';
      _licenseController.text = widget.trainer!.license ?? '';
      _selectedSpecialty = widget.trainer!.specialty;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _licenseController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final trainerData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'specialty': _selectedSpecialty ?? _specialties.first,
      'experience': _experienceController.text.trim(),
      'license': _licenseController.text.trim(),
      'password': _passwordController.text.trim().isEmpty ? 'trainer123' : _passwordController.text.trim(),
    };

    final success = await widget.onSubmit(trainerData);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save trainer')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.92),
        ),
        validator: required
            ? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      widget.trainer == null ? Icons.person_add : Icons.edit,
                      color: Colors.blue,
                      size: 30),
                    const SizedBox(width: 12),
                    Text(
                      widget.trainer == null ? 'Add New Trainer' : 'Edit Trainer',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.trainer == null
                      ? 'Fill in trainer details'
                      : 'Update trainer information',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.surface.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.92),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                _buildTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person,
                ),

                _buildTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),

                // Specialty Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: InputDecoration(
                      labelText: 'Specialty',
                      prefixIcon: const Icon(Icons.work, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.92),
                    ),
                    items: _specialties.map((specialty) {
                      return DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialty = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a specialty';
                      }
                      return null;
                    },
                  ),
                ),

                _buildTextField(
                  label: 'Experience (years)',
                  controller: _experienceController,
                  icon: Icons.timeline,
                  keyboardType: TextInputType.number,
                ),

                _buildTextField(
                  label: 'License/Certification',
                  controller: _licenseController,
                  icon: Icons.card_membership,
                  required: false,
                ),

                if (widget.trainer == null)
                  _buildTextField(
                    label: 'Password (default: trainer123)',
                    controller: _passwordController,
                    icon: Icons.lock,
                    required: false,
                    obscureText: true,
                  ),


                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        )
                            : Text(
                          widget.trainer == null ? 'Add Trainer' : 'Update Trainer',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


