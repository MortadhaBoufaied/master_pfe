import 'package:flutter/material.dart';

import '../../../../../controllers/TrainerFormController.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../services/trainer_service.dart';

class TrainerFormScreen extends StatefulWidget {
  final bool isEditing;
  final int? trainerId;
  final String divisionId;

  const TrainerFormScreen({
    Key? key,
    required this.divisionId,
    this.isEditing = false,
    this.trainerId,
  }) : super(key: key);

  @override
  State<TrainerFormScreen> createState() => _TrainerFormScreenState();
}

class _TrainerFormScreenState extends State<TrainerFormScreen> {
  late TrainerFormController _formController;
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _formController = TrainerFormController(
      widget.divisionId,
      authService: AuthService(),
      trainerService: TrainerService(),
    );

    // if editing, you could load trainer data and populate controllers
    if (widget.isEditing && widget.trainerId != null) {
      _loadExisting(widget.trainerId!);
    }
  }

  Future<void> _loadExisting(int trainerId) async {
    final svc = TrainerService();
    try {
      final t = await svc.getTrainerById(trainerId);
      if (t != null) {
        _formController.nameController.text = t.name ?? '';
        _formController.emailController.text = t.email ?? '';
        _formController.phoneNumberController.text = t.phone ?? '';
        _formController.dobController.text = t.dob ?? '';
        _formController.regionController.text = t.region ?? '';
        _formController.experienceController.text = t.experience ?? '';
        _formController.licenseController.text = t.license ?? '';
        _formController.notesController.text = t.notes ?? '';
        _formController.selectedSpecialty = t.specialty ?? _formController.specialties.first;
        if (t.images != null) _formController.images = List<String>.from(t.images!);
      }
    } catch (e) {
      debugPrint('Failed to load trainer for editing: $e');
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Personal Info"),
        isActive: _formController.currentStep >= 0,
        content: Column(
          children: [
            TextFormField(
              controller: _formController.nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),
            TextFormField(
              controller: _formController.dobController,
              decoration: const InputDecoration(labelText: "Date of Birth"),
            ),
            TextFormField(
              controller: _formController.phoneNumberController,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            TextFormField(
              controller: _formController.regionController,
              decoration: const InputDecoration(labelText: "Region"),
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Professional Info"),
        isActive: _formController.currentStep >= 1,
        content: Column(
          children: [
            TextFormField(
              controller: _formController.experienceController,
              decoration: const InputDecoration(labelText: "Experience (years)"),
            ),
            TextFormField(
              controller: _formController.licenseController,
              decoration: const InputDecoration(labelText: "Coaching License"),
            ),
            DropdownButtonFormField<String>(
              value: _formController.selectedSpecialty ?? _formController.specialties.first,
              decoration: const InputDecoration(labelText: "Specialty"),
              items: _formController.specialties
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() => _formController.selectedSpecialty = val);
              },
            ),
            TextFormField(
              controller: _formController.notesController,
              decoration: const InputDecoration(labelText: "Notes"),
              maxLines: 3,
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Account Info"),
        isActive: _formController.currentStep >= 2,
        content: Column(
          children: [
            TextFormField(
              controller: _formController.emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),
            if (!widget.isEditing) ...[
              TextFormField(
                controller: _formController.passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _formController.passwordVerifyController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm Password"),
                validator: (v) {
                  if (v != _formController.passwordController.text) {
                    return "Passwords don't match";
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Future<void> _onStepContinue() async {
    if (_formController.currentStep < _formController.totalSteps - 1) {
      setState(() => _formController.currentStep++);
      return;
    }

    // final submission
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill the required fields.')),
      );
      return;
    }
    setState(() => _submitting = true);
    await _formController.submitForm(context, valid, widget.isEditing, widget.trainerId);
    if (mounted) setState(() => _submitting = false);
  }

  void _onStepCancel() {
    if (_formController.currentStep > 0) {
      setState(() => _formController.currentStep--);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    elevation: 0,
        title: Text(widget.isEditing ? 'Edit Trainer' : 'Add New Trainer'),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _formController.currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (i) => setState(() => _formController.currentStep = i),
          steps: _buildSteps(),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _submitting ? null : details.onStepContinue,
                    child: _submitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_formController.currentStep == _formController.totalSteps - 1 ? 'Add' : 'Next'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(onPressed: details.onStepCancel, child: const Text('Cancel')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


