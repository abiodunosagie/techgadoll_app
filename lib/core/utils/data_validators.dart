import 'dart:developer' as developer;

class DataValidators {
  DataValidators._();

  static double? safePrice(dynamic value) {
    if (value == null) {
      developer.log('Missing price value', name: 'DataValidators');
      return null;
    }
    final price = (value is num) ? value.toDouble() : double.tryParse(value.toString());
    if (price == null || price < 0) {
      developer.log('Invalid price value: $value', name: 'DataValidators', level: 1000);
      return null;
    }
    return price;
  }

  static String? safeImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      developer.log('Missing image URL', name: 'DataValidators');
      return null;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      developer.log('Invalid image URL: $url', name: 'DataValidators');
      return null;
    }
    return url;
  }

  static double safeRating(dynamic value) {
    if (value == null) return 0.0;
    final rating = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;
    return rating.clamp(0.0, 5.0);
  }

  static String safeString(String? value, String defaultValue) {
    if (value == null || value.trim().isEmpty) return defaultValue;
    return value;
  }
}
