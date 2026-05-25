import '../components/Constants.dart';
import '../config/api_config.dart';

class BackendUrl {
  const BackendUrl._();

  static String? resolve(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('data:image/')) return value;

    var path = value;
    if (path.startsWith('file://')) {
      path = path.replaceFirst(RegExp(r'^file://+'), '/');
    }
    if (!path.startsWith('/')) path = '/$path';

    if (path.startsWith('/uploads/') ||
        path.startsWith('/images/') ||
        path.startsWith('/static/')) {
      return '${ApiConfig.filesBaseUrl}$path';
    }

    if (path.startsWith('/api/')) {
      return '${ApiConfig.publicBaseUrl}$path';
    }

    var base = API_BASE_URL;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base$path';
  }
}


