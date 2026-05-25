// lib/utils/url_resolver.dart
import '../config/api_config.dart';

/// Resolve any backend-returned path into an absolute HTTP(S) URL
/// understood by Flutter's Image.network / NetworkImage.
///
/// Rules:
/// - http(s)://...               => return as-is
/// - file:///uploads/...         => convert to <filesBaseUrl>/uploads/...
/// - /uploads/** | /images/**    => prefix with filesBaseUrl
/// - /api/**                     => prefix with publicBaseUrl
/// - other relative paths        => prefix with publicBaseUrl
String resolvePublicUrl(String? path) {
  // Fallback to a known default player avatar on the server
  const String defaultAvatarPath = '/uploads/defaults/player.jpg';

  if (path == null || path.trim().isEmpty) {
    return '${ApiConfig.filesBaseUrl}$defaultAvatarPath';
  }

  final p = path.trim();

  // Already absolute (http/https)
  if (p.startsWith('http://') || p.startsWith('https://')) return p;

  // Normalize accidental file:// URLs
  if (p.startsWith('file:///')) {
    final noScheme = p.substring('file://'.length); // \/uploads\/...
    if (noScheme.startsWith('/uploads/') ||
        noScheme.startsWith('/images/') ||
        noScheme.startsWith('/static/')) {
      return '${ApiConfig.filesBaseUrl}$noScheme';
    }
    return '${ApiConfig.publicBaseUrl}$noScheme';
  }

  // Public file buckets
  if (p.startsWith('/uploads/') || p.startsWith('/images/') || p.startsWith('/static/')) {
    return '${ApiConfig.filesBaseUrl}$p';
  }

  // API routes
  if (p.startsWith('/api/')) {
    return '${ApiConfig.publicBaseUrl}$p';
  }

  // Relative paths
  if (!p.startsWith('/')) {
    return '${ApiConfig.publicBaseUrl}/$p';
  }
  return '${ApiConfig.publicBaseUrl}$p';
}


