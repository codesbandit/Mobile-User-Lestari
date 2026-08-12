import 'package:flutter/foundation.dart';
import 'package:lestar_user/util/app_constants.dart';

class ImageUrlHelper {
  static String resolve(String url) {
    if (!kIsWeb || url.isEmpty) {
      return url;
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return url;
    }

    if (uri.scheme == 'data' || uri.scheme == 'blob') {
      return url;
    }

    if (uri.path == '/image-proxy') {
      return url;
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return url;
    }

    return '${AppConstants.baseUrl}/image-proxy?url=${Uri.encodeComponent(url)}';
  }
}
