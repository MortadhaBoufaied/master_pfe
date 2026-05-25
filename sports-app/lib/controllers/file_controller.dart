import 'dart:io';
import 'package:flutter/material.dart';
import '../models/file_data.dart';
import '../services/file_service.dart';

class FileController extends ChangeNotifier {
  final FileService _service = FileService();

  FileData? uploadedFile;
  bool isLoading = false;
  String? error;

  Future<bool> upload(File file, {String? folder}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      uploadedFile = await _service.uploadFile(file, folder: folder);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<int>> download(String fileId) async {
    try {
      return await _service.downloadFile(fileId);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> delete(String fileId) async {
    try {
      final ok = await _service.deleteFile(fileId);
      if (ok) {
        uploadedFile = null;
        notifyListeners();
      }
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}


