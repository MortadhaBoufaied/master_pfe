import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/trainer_service.dart';

class TrainerFormController {
  String? error;
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordVerifyController = TextEditingController();

  // Dropdown
  List<String> specialties = [
    'Training General',
    'Youth Coach',
    'Fitness Coach',
    'Tactics Coach',
    'Goalkeeping Coach'
  ];
  String? selectedSpecialty;

  // Images (list of fileIds or urls)
  List<String> images = [];

  // Stepper
  int currentStep = 0;
  final int totalSteps = 3;

  // Services
  final AuthService authService;
  final TrainerService trainerService;
  final String divisionId;

  TrainerFormController(this.divisionId, {required this.authService, required this.trainerService});

  void nextStep() {
    if (currentStep < totalSteps - 1) currentStep++;
  }

  void previousStep() {
    if (currentStep > 0) currentStep--;
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Submit form for create or update.
  Future<void> submitForm(BuildContext context, bool isFormValid, bool isEditing, int? trainerId) async {
    if (!isFormValid) {
      showError(context, 'Please fill the required fields.');
      return;
    }

    final Map<String, dynamic> trainerData = {
      // Backend expects e.g. 'speciality' but trainer_service will normalize
      'name': nameController.text.trim(),
      'dob': dobController.text.trim(),
      'phone': phoneNumberController.text.trim(),
      'region': regionController.text.trim(),
      'experience': experienceController.text.trim(),
      'license': licenseController.text.trim(),
      'specialty': selectedSpecialty ?? specialties.first,
      'notes': notesController.text.trim(),
      'email': emailController.text.trim(),
      'divisionId': divisionId.isEmpty ? null : int.tryParse(divisionId),
      'images': images,
    };

    try {
      if (isEditing && trainerId != null) {
        final ok = await trainerService.updateTrainer(trainerId, trainerData);
        if (ok != null) {
          showError(context, 'Trainer updated successfully.');
          Navigator.of(context).pop(true);
        } else {
          showError(context, 'Failed to update trainer.');
        }
      } else {
        // Optionally create a backend user for the trainer if email/password provided
        if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
          final signed = await authService.signup(
            nom: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            mainRole: 'TRAINER',
          );
          if (!signed) {
            showError(context, 'Failed to create user account for trainer.');
            return;
          }
        }

        final created = await trainerService.createTrainer(trainerData);
        if (created != null) {
          showError(context, 'Trainer created successfully.');
          Navigator.of(context).pop(true);
        } else {
          showError(context, 'Failed to create trainer.');
        }
      }
    } catch (e) {
      showError(context, 'Error: ${e.toString()}');
    }
  }

  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneNumberController.dispose();
    regionController.dispose();
    experienceController.dispose();
    licenseController.dispose();
    notesController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordVerifyController.dispose();
  }
  Future<bool> submit() async {
    error = null;
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passwordController.text;
    final pass2 = passwordVerifyController.text;
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      error = 'Missing required fields';
      return false;
    }
    if (pass != pass2) {
      error = 'Passwords do not match';
      return false;
    }
    try {
      final auth = AuthService();
      final ok = await auth.signup(
        nom: name,
        email: email,
        password: pass,
        extra: {
          'role': 'TRAINER',
          'phoneNumber': phoneNumberController.text.trim(),
        },
      );
      if (!ok) {
        error = 'Signup failed';
        return false;
      }
      final service = TrainerService();
      await service.createTrainer({
        'name': name,
        'dob': dobController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),
        'region': regionController.text.trim(),
        'experience': experienceController.text.trim(),
        'license': licenseController.text.trim(),
        'specialty': selectedSpecialty ?? '',
        'notes': notesController.text.trim(),
        'images': images,
        'email': email,
      });
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

}


