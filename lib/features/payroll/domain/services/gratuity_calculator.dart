/// Stateless service for computing gratuity under the Payment of Gratuity
/// Act, 1972.
///
/// ## Eligibility
/// An employee must complete at least 5 continuous years of service.
///
/// ## Formula
/// Gratuity = (Basic + DA) × (15/26) × completed years of service
///
/// ## Tax exemption cap
/// Maximum gratuity exempt from income tax: ₹20,00,000 (200000000 paise).
/// Amounts above the cap are taxable; this calculator returns the capped value
/// since the statutory maximum follows the same limit for private employees.
class GratuityCalculator {
  GratuityCalculator._();

  /// Minimum years of continuous service required for gratuity eligibility.
  static const int minimumEligibilityYears = 5;

  /// Maximum tax-exempt gratuity amount — ₹20,00,000 in paise.
  static const int maxExemptAmountPaise = 200000000;

  /// Returns `true` if the employee is eligible for gratuity.
  static bool isEligible(int yearsOfService) =>
      yearsOfService >= minimumEligibilityYears;

  /// Computes the gratuity amount in paise.
  ///
  /// Parameters:
  /// - [yearsOfService] — completed years of continuous service (fractions
  ///   are ignored; use integer years as per the Act).
  /// - [lastBasicPaise] — last drawn Basic + DA in paise.
  ///
  /// Returns 0 if:
  /// - [yearsOfService] is less than 5, or
  /// - [lastBasicPaise] is 0 or negative.
  ///
  /// The result is capped at [maxExemptAmountPaise] (₹20 lakh).
  static int compute({
    required int yearsOfService,
    required int lastBasicPaise,
  }) {
    if (!isEligible(yearsOfService)) return 0;
    if (lastBasicPaise <= 0) return 0;

    // Gratuity = basic × 15 × years / 26  (integer arithmetic, truncated)
    final raw = (lastBasicPaise * 15 * yearsOfService) ~/ 26;
    return raw > maxExemptAmountPaise ? maxExemptAmountPaise : raw;
  }
}
