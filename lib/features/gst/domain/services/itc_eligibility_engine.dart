/// Immutable result of an ITC eligibility check under Section 17(5).
class ItcEligibilityResult {
  const ItcEligibilityResult({
    required this.isEligible,
    required this.section17_5Category,
    required this.reason,
  });

  /// Whether ITC is eligible for claim.
  final bool isEligible;

  /// Section 17(5) category name if blocked (null when eligible).
  final String? section17_5Category;

  /// Human-readable explanation of the eligibility determination.
  final String reason;

  // Sentinel used to distinguish "not provided" from "explicitly null".
  static const Object _absent = Object();

  ItcEligibilityResult copyWith({
    bool? isEligible,
    Object? section17_5Category = _absent,
    String? reason,
  }) {
    return ItcEligibilityResult(
      isEligible: isEligible ?? this.isEligible,
      section17_5Category: identical(section17_5Category, _absent)
          ? this.section17_5Category
          : section17_5Category as String?,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItcEligibilityResult &&
          runtimeType == other.runtimeType &&
          isEligible == other.isEligible &&
          section17_5Category == other.section17_5Category &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(isEligible, section17_5Category, reason);
}

/// A blocked ITC category under Section 17(5) CGST Act.
class _BlockedCategory {
  const _BlockedCategory({
    required this.sacPrefixes,
    required this.category,
    required this.description,
  });

  /// SAC/HSN code prefixes that trigger this block.
  final List<String> sacPrefixes;

  /// Short category label.
  final String category;

  /// Explanation of why ITC is blocked.
  final String description;
}

/// Static service that determines ITC eligibility under Section 17(5)
/// of the CGST Act, 2017.
///
/// Section 17(5) lists specific categories of expenses for which ITC
/// is NOT available (blocked credits), regardless of business use.
class ItcEligibilityEngine {
  ItcEligibilityEngine._();

  /// Blocked ITC categories under Section 17(5) CGST Act.
  static const List<_BlockedCategory> _blockedCategories = [
    _BlockedCategory(
      sacPrefixes: ['9601', '8703', '8704', '8705', '8706', '8711'],
      category: 'Motor vehicles',
      description:
          'Motor vehicles for transportation of fewer than 13 persons — '
          'blocked under Section 17(5)(a)',
    ),
    _BlockedCategory(
      sacPrefixes: ['9963', '9961'],
      category: 'Food and beverages',
      description:
          'Food and beverages, outdoor catering, beauty treatment — '
          'blocked under Section 17(5)(b)',
    ),
    _BlockedCategory(
      sacPrefixes: ['9997'],
      category: 'Beauty treatment',
      description:
          'Beauty treatment, health services, cosmetic surgery — '
          'blocked under Section 17(5)(b)',
    ),
    _BlockedCategory(
      sacPrefixes: ['9993'],
      category: 'Health and fitness services',
      description:
          'Human health and social care services including health club, '
          'fitness centre — blocked under Section 17(5)(b)',
    ),
    _BlockedCategory(
      sacPrefixes: ['9995'],
      category: 'Club membership',
      description:
          'Membership of a club, health, fitness centre — '
          'blocked under Section 17(5)(b)',
    ),
    _BlockedCategory(
      sacPrefixes: ['9964'],
      category: 'Travel benefits',
      description:
          'Travel benefits extended to employees on vacation — '
          'blocked under Section 17(5)(b)',
    ),
    _BlockedCategory(
      sacPrefixes: ['9954'],
      category: 'Works contract — immovable property',
      description:
          'Works contract services for construction of an immovable property '
          '(other than plant and machinery) — blocked under Section 17(5)(c)',
    ),
    _BlockedCategory(
      sacPrefixes: ['9983', '9985'],
      category: 'Personal consumption',
      description:
          'Goods or services used for personal consumption — '
          'blocked under Section 17(5)(g)',
    ),
  ];

  /// Checks whether ITC is eligible for a given [sacHsnCode] and [description].
  ///
  /// Returns an [ItcEligibilityResult] indicating eligibility and reason.
  static ItcEligibilityResult check({
    required String sacHsnCode,
    required String description,
  }) {
    for (final blocked in _blockedCategories) {
      for (final prefix in blocked.sacPrefixes) {
        if (sacHsnCode.startsWith(prefix) || sacHsnCode == prefix) {
          return ItcEligibilityResult(
            isEligible: false,
            section17_5Category: blocked.category,
            reason: blocked.description,
          );
        }
      }
    }

    return const ItcEligibilityResult(
      isEligible: true,
      section17_5Category: null,
      reason: 'ITC eligible — not blocked under Section 17(5) CGST Act',
    );
  }

  /// Checks ITC eligibility for a list of (sacHsnCode, description) pairs.
  ///
  /// Returns results in the same order as the input list.
  static List<ItcEligibilityResult> checkAll(List<(String, String)> items) {
    return items
        .map((item) {
          final (code, description) = item;
          return check(sacHsnCode: code, description: description);
        })
        .toList(growable: false);
  }
}
