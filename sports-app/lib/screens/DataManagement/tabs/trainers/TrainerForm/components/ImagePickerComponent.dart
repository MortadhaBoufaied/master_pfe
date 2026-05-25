import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImagePickerComponent extends StatefulWidget {
  final String label;
  final String? initialImageUrl;
  final String fileKey; // key used in SharedPreferences

  const ImagePickerComponent({
    Key? key,
    required this.label,
    this.initialImageUrl,
    required this.fileKey,
  }) : super(key: key);

  @override
  _ImagePickerComponentState createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(widget.fileKey);
    if (savedPath != null && savedPath.isNotEmpty) {
      setState(() {
        _selectedImage = File(savedPath);
      });
    }
  }

  Future<void> _saveImagePath(String filePath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.fileKey, filePath);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploading = true;
      });

      await _saveImagePath(pickedFile.path);

      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isUploading
                ? const Center(child: CircularProgressIndicator())
                : _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
                : widget.initialImageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.initialImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
                : const Center(
              child: Icon(Icons.add_a_photo,
                  color: Colors.grey, size: 40),
            ),
          ),
        ),
      ],
    );
  }
}


