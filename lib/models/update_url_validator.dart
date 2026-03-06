import 'update_security_exception.dart';

/// Validates URLs for the update system to ensure security requirements are met
class UpdateUrlValidator {
  /// Validates that a URL uses HTTPS scheme
  ///
  /// Throws [UpdateSecurityException] if:
  /// - The URL is malformed
  /// - The URL does not use https:// scheme
  /// - The URL does not have a valid host
  ///
  /// Returns the validated URL if successful
  ///
  /// Example:
  /// ```dart
  /// final url = UpdateUrlValidator.validateHttpsUrl(
  ///   'https://github.com/repo/update.json'
  /// ); // Returns the URL
  ///
  /// UpdateUrlValidator.validateHttpsUrl('http://example.com/update.json');
  /// // Throws UpdateSecurityException
  /// ```
  static String validateHttpsUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      throw UpdateSecurityException(
        'Invalid URL format',
        url: url,
        details: 'The URL could not be parsed',
      );
    }

    if (uri.scheme != 'https') {
      throw UpdateSecurityException(
        'Update URLs must use HTTPS',
        url: url,
        details:
            'Got scheme: ${uri.scheme}. Only https:// is allowed for security.',
      );
    }

    if (uri.host.isEmpty) {
      throw UpdateSecurityException(
        'Invalid URL format',
        url: url,
        details: 'The URL does not have a valid host',
      );
    }

    return url;
  }

  /// Validates a list of URLs, ensuring all use HTTPS
  ///
  /// Throws [UpdateSecurityException] on the first invalid URL
  /// Returns the list if all URLs are valid
  static List<String> validateHttpsUrls(List<String> urls) {
    for (final url in urls) {
      validateHttpsUrl(url);
    }
    return urls;
  }

  /// Checks if a URL uses HTTPS without throwing
  ///
  /// Returns true if the URL is valid and uses HTTPS
  /// Returns false otherwise
  static bool isHttpsUrl(String url) {
    try {
      validateHttpsUrl(url);
      return true;
    } on UpdateSecurityException {
      return false;
    }
  }
}
