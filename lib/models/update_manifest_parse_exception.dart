/// Thrown when an `update.json` manifest cannot be parsed because a required
/// field is missing, has the wrong type, or fails validation rules.
///
/// See `docs/update-contract.md` for the full schema specification.
class UpdateManifestParseException implements Exception {
  /// Human-readable description of the parse failure.
  final String message;

  /// The JSON field path that triggered the failure (e.g. `"version"`).
  /// May be `null` for top-level structural errors.
  final String? field;

  /// The raw value that failed validation, if available.
  final Object? invalidValue;

  const UpdateManifestParseException(
    this.message, {
    this.field,
    this.invalidValue,
  });

  @override
  String toString() {
    final parts = <String>['UpdateManifestParseException: $message'];
    if (field != null) parts.add('field: $field');
    if (invalidValue != null) parts.add('invalidValue: $invalidValue');
    return parts.join(', ');
  }
}
