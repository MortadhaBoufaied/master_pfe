import '../components/Constants.dart';

/// Central place to derive base URLs.
/// API_BASE_URL usually ends with `/api`.
class ApiConfig {
  /// Example: http://10.0.2.2:8091/api
  static String get apiBaseUrl => API_BASE_URL;

  /// Example: http://10.0.2.2:8091
  static String get publicBaseUrl {
    var b = apiBaseUrl;
    // Strip trailing `/api` or `/api/`
    if (b.endsWith('/api')) return b.substring(0, b.length - 4);
    if (b.endsWith('/api/')) return b.substring(0, b.length - 5);
    return b;
  }

  /// Optional separate base for public files.
  /// If FILES_BASE_URL is set, it will be used; otherwise publicBaseUrl is used.
  static String get filesBaseUrl {
    final fb = FILES_BASE_URL;
    if (fb != null && fb.trim().isNotEmpty) {
      return fb.endsWith('/') ? fb.substring(0, fb.length - 1) : fb;
    }
    return publicBaseUrl;
  }
}


