import '../models/rate_change.dart';

/// Stateless singleton service that tracks tax rate and duty changes
/// introduced by Finance Acts, CBDT/CBIC notifications, and SEBI circulars.
class RateChangeTrackerService {
  RateChangeTrackerService._();

  /// Singleton instance.
  static final RateChangeTrackerService instance =
      RateChangeTrackerService._();

  // ---------------------------------------------------------------------------
  // Mock data — Finance Act 2024 and key FY 2024-25 rate changes
  // ---------------------------------------------------------------------------
  static final List<RateChange> _mockChanges = [
    // STCG Sec 111A: 15% → 20%
    RateChange(
      effectiveDate: DateTime.utc(2024, 7, 23),
      category: RateCategory.incomeTax,
      description:
          'STCG on listed equity shares and equity-oriented mutual funds '
          '(Section 111A) increased from 15% to 20%.',
      oldValue: '15%',
      newValue: '20%',
      circularReference: 'Finance Act 2024',
      affectedAssessees: const [
        'Individual',
        'HUF',
        'Firm',
        'Company',
        'NRI',
        'Equity Investor',
        'Mutual Fund Holder',
      ],
    ),

    // LTCG Sec 112A: 10% → 12.5%, exemption ₹1L → ₹1.25L
    RateChange(
      effectiveDate: DateTime.utc(2024, 7, 23),
      category: RateCategory.incomeTax,
      description:
          'LTCG on listed equity shares and equity-oriented mutual funds '
          '(Section 112A) increased from 10% to 12.5%. Annual exemption '
          'limit raised from ₹1,00,000 to ₹1,25,000.',
      oldValue: '10% (₹1L exemption)',
      newValue: '12.5% (₹1.25L exemption)',
      circularReference: 'Finance Act 2024',
      affectedAssessees: const [
        'Individual',
        'HUF',
        'Firm',
        'Company',
        'NRI',
        'Equity Investor',
        'Mutual Fund Holder',
      ],
    ),

    // STT on F&O: increased rates
    RateChange(
      effectiveDate: DateTime.utc(2024, 10, 1),
      category: RateCategory.incomeTax,
      description:
          'Securities Transaction Tax (STT) on futures increased from '
          '0.0125% to 0.02%, and on options from 0.0625% to 0.1%.',
      oldValue: '0.0125% (futures); 0.0625% (options)',
      newValue: '0.02% (futures); 0.1% (options)',
      circularReference: 'Finance Act 2024',
      affectedAssessees: const ['F&O Trader', 'Investor', 'Proprietary Firm'],
    ),

    // TDS Sec 194T: New at 10%
    RateChange(
      effectiveDate: DateTime.utc(2025, 4, 1),
      category: RateCategory.tds,
      description:
          'New Section 194T inserted by Finance Act 2024: 10% TDS on '
          'salary, remuneration, bonus, commission, and interest paid '
          'to partners by a partnership firm, where aggregate exceeds '
          '₹20,000 per year.',
      oldValue: 'Nil (no TDS)',
      newValue: '10% (threshold ₹20,000)',
      circularReference: 'Finance Act 2024 — Section 194T',
      affectedAssessees: const ['Partnership Firm', 'LLP', 'Partner'],
    ),

    // GST on term insurance: nil
    RateChange(
      effectiveDate: DateTime.utc(2025, 4, 1),
      category: RateCategory.gst,
      description:
          'GST Council recommends nil GST rate on term life insurance '
          'premiums. Implementation subject to official CBIC notification.',
      oldValue: '18%',
      newValue: 'Nil (proposed)',
      circularReference: 'GST Council 53rd Meeting — June 2024',
      affectedAssessees: const ['Individual', 'HUF', 'Insurance Policy Holder'],
    ),

    // TDS on buyback: 20% → capital gains
    RateChange(
      effectiveDate: DateTime.utc(2024, 10, 1),
      category: RateCategory.tds,
      description:
          'Taxation of share buyback proceeds shifted from company-level '
          'tax (20%) to recipient shareholder level as capital gains / '
          'dividend income. Section 115QA repealed.',
      oldValue: '20% tax in hands of company (Section 115QA)',
      newValue: 'Capital gains / dividend in hands of shareholder',
      circularReference: 'Finance Act 2024',
      affectedAssessees: const ['Company', 'Shareholder', 'Individual'],
    ),

    // Customs duty on mobile phones reduced
    RateChange(
      effectiveDate: DateTime.utc(2024, 7, 23),
      category: RateCategory.customs,
      description:
          'Basic Customs Duty (BCD) on mobile phones and printed circuit '
          'boards reduced from 20% to 15% to boost domestic electronics '
          'manufacturing.',
      oldValue: '20%',
      newValue: '15%',
      circularReference: 'Finance Act 2024 — Customs Tariff',
      affectedAssessees: const ['Importer', 'Electronics Manufacturer'],
    ),

    // TCS on foreign remittance under LRS: threshold raised
    RateChange(
      effectiveDate: DateTime.utc(2024, 10, 1),
      category: RateCategory.tcs,
      description:
          'TCS threshold for Liberalised Remittance Scheme (LRS) raised '
          'from ₹7 lakh to ₹10 lakh per financial year. Remittances below '
          'threshold now exempt from TCS.',
      oldValue: '5% TCS above ₹7 lakh (non-education/medical)',
      newValue: '20% TCS above ₹10 lakh (non-education/medical)',
      circularReference: 'Finance Act 2024',
      affectedAssessees: const ['Individual', 'NRI', 'Student'],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the most recent [limit] rate changes.
  List<RateChange> getRecentChanges({int limit = 10}) {
    final count = limit < _mockChanges.length ? limit : _mockChanges.length;
    return List.unmodifiable(_mockChanges.take(count).toList());
  }

  /// Returns all rate changes whose [effectiveDate] is strictly after [date].
  List<RateChange> getChangesEffectiveAfter(DateTime date) {
    return _mockChanges.where((c) => c.effectiveDate.isAfter(date)).toList();
  }

  /// Returns all rate changes belonging to [category].
  List<RateChange> getChangesForCategory(RateCategory category) {
    return _mockChanges.where((c) => c.category == category).toList();
  }
}
