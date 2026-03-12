import 'package:ca_app/features/gst/domain/models/hsn_sac_code.dart';
import 'package:ca_app/features/gst/domain/services/hsn_sac_data.dart';

/// Static service for HSN/SAC code lookup, search, and validation.
///
/// Uses a built-in master database of 80+ HSN and SAC codes covering
/// common Indian GST goods and services.
class HsnSacService {
  HsnSacService._();

  /// Valid HSN/SAC code lengths (2, 4, 6, or 8 digits).
  static const _validLengths = {2, 4, 6, 8};

  /// Searches codes by prefix match on the code field.
  ///
  /// Returns all codes whose code starts with [query].
  /// An empty [query] returns all codes.
  static List<HsnSacCode> searchByCode(String query) {
    if (query.isEmpty) {
      return List.unmodifiable(hsnSacMasterDatabase);
    }
    return hsnSacMasterDatabase
        .where((entry) => entry.code.startsWith(query))
        .toList();
  }

  /// Searches codes by case-insensitive substring match on description.
  ///
  /// Returns all codes whose description contains [query] (case-insensitive).
  static List<HsnSacCode> searchByDescription(String query) {
    final lowerQuery = query.toLowerCase();
    return hsnSacMasterDatabase
        .where((entry) => entry.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Returns the code entry with an exact match on [code], or null.
  static HsnSacCode? getByCode(String code) {
    for (final entry in hsnSacMasterDatabase) {
      if (entry.code == code) {
        return entry;
      }
    }
    return null;
  }

  /// Returns the GST rate for the given [code], or null if not found.
  static double? getGstRate(String code) {
    return getByCode(code)?.gstRate;
  }

  /// Validates whether [code] is a well-formed HSN/SAC code.
  ///
  /// A valid code is 2, 4, 6, or 8 digits (numeric only).
  static bool validateCode(String code) {
    if (code.isEmpty) {
      return false;
    }
    if (!_validLengths.contains(code.length)) {
      return false;
    }
    return RegExp(r'^\d+$').hasMatch(code);
  }

  /// Returns all codes belonging to the given [chapter] (1–99).
  static List<HsnSacCode> getChapterCodes(int chapter) {
    return hsnSacMasterDatabase
        .where((entry) => entry.chapter == chapter)
        .toList();
  }
}
