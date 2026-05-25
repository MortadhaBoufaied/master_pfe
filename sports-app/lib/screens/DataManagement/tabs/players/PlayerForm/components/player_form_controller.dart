import 'package:flutter/material.dart';

class PlayerFormController {
  // Existing controllers
  final TextEditingController nomController = TextEditingController();
  final TextEditingController dateNaissanceController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController nationaliteController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? position;
  int? number;
  String? imageUrl;

  void dispose() {
    nomController.dispose();
    dateNaissanceController.dispose();
    telController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nationaliteController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
  }

  // If you still use toMap(...) anywhere, keep it; otherwise not required for the new create flow.
  Map<String, dynamic> toMap(int divisionId) {
    return {
      'nom': nomController.text.trim(),
      'dateNaissance': dateNaissanceController.text.trim(),
      'tel': telController.text.trim(),
      'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      'nationalite': nationaliteController.text.trim().isEmpty ? null : nationaliteController.text.trim(),
      'age': int.tryParse(ageController.text.trim()),
      'position': position,
      'number': number,
      'height': double.tryParse(heightController.text.trim()),
      'weight': double.tryParse(weightController.text.trim()),
      'divisionId': divisionId,
      'imageUrl': imageUrl,
    };
  }
}


