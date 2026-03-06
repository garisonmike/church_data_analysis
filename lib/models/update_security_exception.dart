/// Exception thrown when update system security requirements are violated
class UpdateSecurityException implements Exception {
  final String message;
  final String? url;
  final String? details;

  UpdateSecurityException(this.message, {this.url, this.details});

  @override
  String toString() {
    final buffer = StringBuffer('UpdateSecurityException: $message');
    if (url != null) {
      buffer.write('\nURL: $url');
    }
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}
