// ignore_for_file: constant_identifier_names

/// Cross-platform filename sanitizer.
///
/// Provides a single [sanitize] method that makes any export filename safe for
/// use on Windows, macOS, Linux, iOS, and Android by applying the following
/// rules in order:
///
///  1. Split the raw name into stem + extension.
///  2. Strip control characters (U+0000–U+001F, U+007F) from both parts.
///  3. Strip characters that are invalid on any common platform:
///       `< > : " / \ | ? *`  (Windows-invalid plus universal path chars).
///  4. Collapse runs of whitespace to a single space; trim.
///  5. Replace every remaining space with an underscore.
///  6. If the stem matches a Windows reserved name (CON, PRN, AUX, NUL,
///     COM1–COM9, LPT1–LPT9), prefix it with `_` to avoid OS hangs.
///  7. Cap the stem to [maxStemLength] characters (default 200); the
///     extension is not truncated.
///  8. If the resulting stem is empty after all transforms, fall back to
///     [fallbackStem] (default `'export'`).
///
/// The extension (if any) is taken as everything from the last `.` in the
/// original name, including the dot, e.g. `'report.pdf'` → extension `'.pdf'`.
/// An extension is only recognised when the original name contains a dot and
/// the part after the last dot is non-empty.
class FilenameSanitizer {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// Maximum number of characters allowed in the filename stem (no extension).
  static const int maxStemLength = 200;

  /// Fallback stem used when sanitization produces an empty stem.
  static const String fallbackStem = 'export';

  /// Characters that are invalid on Windows (and thus on the most restrictive
  /// common platform).  Includes universal path-separator characters so that
  /// callers cannot accidentally embed directory traversal.
  static const String _invalidChars = r'<>:"/\|?*';

  /// Windows reserved device names (case-insensitive).
  static const List<String> reservedNames = [
    'CON',
    'PRN',
    'AUX',
    'NUL',
    'COM1',
    'COM2',
    'COM3',
    'COM4',
    'COM5',
    'COM6',
    'COM7',
    'COM8',
    'COM9',
    'LPT1',
    'LPT2',
    'LPT3',
    'LPT4',
    'LPT5',
    'LPT6',
    'LPT7',
    'LPT8',
    'LPT9',
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Sanitizes [filename] for cross-platform filesystem safety.
  ///
  /// The [maxStemLen] parameter overrides [maxStemLength] (useful for tests).
  ///
  /// Returns a non-empty filename that is safe to pass directly to
  /// [FileService.exportFile] or [FileService.exportFileBytes].
  ///
  /// Examples:
  /// ```dart
  /// FilenameSanitizer.sanitize('My Report.pdf')   // 'My_Report.pdf'
  /// FilenameSanitizer.sanitize('CON.csv')          // '_CON.csv'
  /// FilenameSanitizer.sanitize('a:b<c>d.txt')      // 'abcd.txt'
  /// FilenameSanitizer.sanitize('  spaces  .csv')   // 'spaces.csv'
  /// ```
  static String sanitize(String filename, {int? maxStemLen}) {
    final limit = maxStemLen ?? maxStemLength;

    final (rawStem, ext) = splitExtension(filename);

    // Step 1 — strip control characters from stem.
    var stem = _stripControlChars(rawStem);

    // Step 2 — strip platform-invalid characters from stem.
    stem = _stripInvalidChars(stem);

    // Step 3 — normalise whitespace: collapse runs → single space, then trim.
    stem = stem.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Step 4 — replace spaces with underscores.
    stem = stem.replaceAll(' ', '_');

    // Step 5 — block Windows reserved names.
    if (_isReservedName(stem)) {
      stem = '_$stem';
    }

    // Step 6 — cap length.
    if (stem.length > limit) {
      stem = stem.substring(0, limit);
    }

    // Step 7 — fallback for empty stem.
    if (stem.isEmpty) {
      stem = fallbackStem;
    }

    // Sanitize the extension too (strip invalid chars, keep dot).
    final safeExt = _sanitizeExtension(ext);

    return '$stem$safeExt';
  }

  /// Splits [filename] into a (stem, extension) record.
  ///
  /// The extension includes the leading dot, e.g. `('.pdf')`.
  /// Returns `(filename, '')` when no dot is present or the dot is the
  /// first character (hidden-file convention like `.gitignore`).
  static (String, String) splitExtension(String filename) {
    final lastDot = filename.lastIndexOf('.');
    // No dot, or dot is the very first character → no detectable extension.
    if (lastDot <= 0) return (filename, '');
    return (filename.substring(0, lastDot), filename.substring(lastDot));
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Removes non-whitespace control characters (U+0000–U+0008, U+000E–U+001F,
  /// and U+007F DEL).
  ///
  /// Whitespace control characters (U+0009 HT, U+000A LF, U+000B VT,
  /// U+000C FF, U+000D CR) are intentionally **not** stripped here; they are
  /// handled by the `\s+` whitespace-normalisation step in [sanitize] so that
  /// they are converted to an underscore rather than silently deleted.
  static String _stripControlChars(String s) =>
      s.replaceAll(RegExp(r'[\x00-\x08\x0E-\x1F\x7F]'), '');

  /// Removes characters listed in [_invalidChars].
  static String _stripInvalidChars(String s) {
    // Escape each char for use inside a character class.
    final escaped = _invalidChars.split('').map((c) {
      const needsEscape = r'\^]-';
      return needsEscape.contains(c) ? '\\$c' : c;
    }).join();
    return s.replaceAll(RegExp('[$escaped]'), '');
  }

  /// Returns `true` when [stem] (case-insensitive, ignoring trailing dots
  /// or spaces per Windows behaviour) matches a reserved device name.
  static bool _isReservedName(String stem) {
    // Windows also reserves "CON." or "CON " etc.; strip trailing punctuation.
    final core = stem.replaceAll(RegExp(r'[.\s]+$'), '').toUpperCase();
    return reservedNames.contains(core);
  }

  /// Strips control characters and invalid chars from [ext] (which includes
  /// the leading dot).  If the result is just a dot, returns empty string.
  static String _sanitizeExtension(String ext) {
    if (ext.isEmpty) return '';
    final clean = _stripControlChars(
      ext,
    ).replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
    // If only the dot remains, drop it.
    return clean == '.' ? '' : clean;
  }
}
