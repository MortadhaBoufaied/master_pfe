import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import 'backend_url.dart';

/// A robust image widget that understands absolute URLs, backend relative paths,
/// and base64 data URIs. It also attaches the Authorization: Bearer <token>
/// header when loading from your secured backend.
class BackendAvatar extends StatelessWidget {
  final String? pathOrUrl;
  final double radius;
  final String? initials;
  final BoxFit fit;

  const BackendAvatar({
    Key? key,
    required this.pathOrUrl,
    this.radius = 20,
    this.initials,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  bool _isDataUri(String s) => s.startsWith('data:image/');

  Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;
    return {'Authorization': 'Bearer ' + token};
  }

  @override
  Widget build(BuildContext context) {
    final raw = pathOrUrl?.trim();
    final displayInitials = initials ?? _fallbackInitialsFromContext(context);

    if (raw == null || raw.isEmpty) {
      return _fallback(displayInitials);
    }

    if (_isDataUri(raw)) {
      try {
        final comma = raw.indexOf(',');
        final b64 = comma >= 0 ? raw.substring(comma + 1) : raw;
        final bytes = base64Decode(b64);
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {
        return _fallback(displayInitials);
      }
    }

    final url = BackendUrl.resolve(raw);
    if (url == null) return _fallback(displayInitials);

    return FutureBuilder<Map<String, String>?>(
      future: _authHeaders(),
      builder: (context, snap) {
        final headers = snap.data;
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: Image.network(
              url,
              headers: headers,
              width: radius * 2,
              height: radius * 2,
              fit: fit,
              errorBuilder: (c, e, s) => _fallback(displayInitials),
              loadingBuilder: (c, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: radius * 2,
                  height: radius * 2,
                  child: Center(
                    child: SizedBox(
                      width: radius,
                      height: radius,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _fallback(String? initials) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.teal.shade100,
      child: Text(
        (initials ?? '?').toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade900,
        ),
      ),
    );
  }

  String? _fallbackInitialsFromContext(BuildContext context) {
    // Best-effort: try to infer a display name from inherited session controller if available later.
    return null;
  }
}


