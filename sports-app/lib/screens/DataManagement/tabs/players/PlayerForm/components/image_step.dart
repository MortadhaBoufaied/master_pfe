import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'player_form_controller.dart';

class PlayerImageStep extends StatefulWidget {
  final PlayerFormController controller;
  final String? existingPlayerImageUrl;

  const PlayerImageStep({
    Key? key,
    required this.controller,
    this.existingPlayerImageUrl,
  }) : super(key: key);

  @override
  State<PlayerImageStep> createState() => _PlayerImageStepState();
}

class _PlayerImageStepState extends State<PlayerImageStep> {
  final ImagePicker _picker = ImagePicker();
  File? _playerImageFile;

  Future<void> _pickPlayerImage() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (picked != null) {
      setState(() {
        _playerImageFile = File(picked.path);
      });
      // Keep local path in controller temporarily (optional)
      // Upload happens in player_form.dart (parent)
      widget.controller.imageUrl = picked.path; // temporary placeholder
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existingPlayerImageUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(' ', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickPlayerImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _playerImageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_playerImageFile!, fit: BoxFit.cover),
              )
                  : (existing != null && existing.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(existing, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      );
                    }),
              )
                  : const Center(
                child: Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
              )),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '    ',
            style: TextStyle(),
          ),
        ],
      ),
    );
  }
}


