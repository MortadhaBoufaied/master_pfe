import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../components/Constants.dart';
import '../models/file_data.dart';
import 'ApiService.dart';
import 'auth_storage.dart';

class FileService {
  final ApiClient _api = ApiClient();

  // ----------------------------
  // UPLOAD FILE
  // ----------------------------
  Future<FileData?> uploadFile(File file, {String? folder}) async {
    try {
      final token = await AuthStorage.getAccessToken();

      final uri = Uri.parse('$API_BASE_URL/files/upload');

      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      if (folder != null && folder
          .trim()
          .isNotEmpty) {
        request.fields['category'] = folder.trim();
        request.fields['description'] = folder.trim();
      }

      final streamed = await request.send().timeout(API_TIMEOUT);
      final responseBody = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          return FileData.fromJson(decoded);
        }
        // some backends wrap into {data:{...}}
        if (decoded is Map && decoded['data'] is Map<String, dynamic>) {
          return FileData.fromJson(Map<String, dynamic>.from(decoded['data']));
        }
      }

      throw Exception(
          'Upload failed: HTTP ${streamed.statusCode} - $responseBody');
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  // ----------------------------
  // DOWNLOAD FILE
  // ----------------------------
  Future<List<int>> downloadFile(String fileId) async {
    try {
      final response = await _api.get('/files/$fileId');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }

      throw Exception(
          'Download failed: HTTP ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  // ----------------------------
  // DELETE FILE
  // ----------------------------
  Future<bool> deleteFile(String fileId) async {
    try {
      final response = await _api.delete('/files/$fileId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  // ----------------------------
  // GET FILE INFO
  // ----------------------------
  Future<FileData?> getFileInfo(String fileId) async {
    try {
      final response = await _api.get('/files/$fileId');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          return FileData.fromJson(decoded);
        }
        if (decoded is Map && decoded['data'] is Map<String, dynamic>) {
          return FileData.fromJson(Map<String, dynamic>.from(decoded['data']));
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error getting file info: $e');
    }
  }
}


