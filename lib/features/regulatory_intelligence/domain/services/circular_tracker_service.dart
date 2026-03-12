import '../models/regulatory_update.dart';

/// Stateless singleton service for tracking CBDT/CBIC/MCA/SEBI circulars
/// and regulatory updates.
class CircularTrackerService {
  CircularTrackerService._();

  /// Singleton instance.
  static final CircularTrackerService instance = CircularTrackerService._();

  // ---------------------------------------------------------------------------
  // Mock data — 10+ regulatory updates covering FY 2024-25
  // ---------------------------------------------------------------------------
  static final List<RegulatoryUpdate> _mockUpdates = [
    RegulatoryUpdate(
      updateId: 'reg-001',
      title: 'Finance Act 2024: STCG Rate Hiked to 20% (Section 111A)',
      summary:
          'Short-term capital gains on equity shares and equity-oriented '
          'mutual funds taxable at 20% (up from 15%) for transactions on or '
          'after July 23, 2024.',
      source: RegSource.cbdt,
      category: UpdateCategory.amendment,
      publicationDate: DateTime.utc(2024, 7, 23),
      effectiveDate: DateTime.utc(2024, 7, 23),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['111A', 'Schedule III'],
      url: 'https://incometaxindia.gov.in/communications/act/finance-act-2024.pdf',
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-002',
      title: 'Finance Act 2024: LTCG Rate Increased to 12.5% (Section 112A)',
      summary:
          'Long-term capital gains on listed equity and equity-oriented funds '
          'now taxed at 12.5% (up from 10%). Exemption limit raised to '
          '₹1,25,000 per annum.',
      source: RegSource.cbdt,
      category: UpdateCategory.amendment,
      publicationDate: DateTime.utc(2024, 7, 23),
      effectiveDate: DateTime.utc(2024, 7, 23),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['112A', '10(38)'],
      url: 'https://incometaxindia.gov.in/communications/act/finance-act-2024.pdf',
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-003',
      title: 'New TDS Section 194T: Partner Salary / Remuneration',
      summary:
          'Finance Act 2024 inserts Section 194T requiring 10% TDS on salary, '
          'remuneration, commission, bonus, and interest paid to partners '
          'exceeding ₹20,000. Effective April 1, 2025.',
      source: RegSource.cbdt,
      category: UpdateCategory.amendment,
      publicationDate: DateTime.utc(2024, 7, 23),
      effectiveDate: DateTime.utc(2025, 4, 1),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['194T', '40(b)'],
      url: null,
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-004',
      title: 'Section 43B(h): MSME Payment Within 45 Days',
      summary:
          'Payments to MSMEs must be made within 45 days (or the agreed '
          'period under MSMED Act) to claim deduction. Amounts outstanding '
          'beyond this will be disallowed and taxed in the year of payment.',
      source: RegSource.cbdt,
      category: UpdateCategory.clarification,
      publicationDate: DateTime.utc(2024, 4, 1),
      effectiveDate: DateTime.utc(2024, 4, 1),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['43B(h)', 'MSMED Act'],
      url: null,
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-005',
      title: 'CBDT Circular 6/2024: TDS on Salary — New Regime Default',
      summary:
          'Clarifies that the new tax regime (Section 115BAC) is the default '
          'regime from FY 2024-25 for employees who do not opt out. Employers '
          'must deduct TDS accordingly.',
      source: RegSource.cbdt,
      category: UpdateCategory.circular,
      publicationDate: DateTime.utc(2024, 4, 5),
      effectiveDate: DateTime.utc(2024, 4, 1),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['115BAC', '192'],
      url: 'https://incometaxindia.gov.in/communications/circular/circular62024.pdf',
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-006',
      title: 'GST Council 53rd Meeting: GST on Insurance Premiums Reduced',
      summary:
          'GST Council recommends nil GST on term life insurance premiums '
          'and reducing GST on health insurance. Final notification pending '
          'from CBIC.',
      source: RegSource.cbic,
      category: UpdateCategory.pressRelease,
      publicationDate: DateTime.utc(2024, 6, 22),
      effectiveDate: null,
      impactLevel: ImpactLevel.medium,
      affectedSections: const ['9(1)', 'Schedule I'],
      url: null,
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-007',
      title: 'MCA: Annual General Meeting via Video Conferencing Extended',
      summary:
          'MCA extends the facility for companies to hold Annual General '
          'Meetings (AGMs) through Video Conferencing (VC) or Other Audio '
          'Visual Means (OAVM) till December 31, 2024.',
      source: RegSource.mca,
      category: UpdateCategory.circular,
      publicationDate: DateTime.utc(2024, 9, 27),
      effectiveDate: DateTime.utc(2024, 9, 27),
      impactLevel: ImpactLevel.medium,
      affectedSections: const ['96', '101'],
      url: null,
      isRead: true,
    ),
    RegulatoryUpdate(
      updateId: 'reg-008',
      title: 'SEBI Circular: F&O Position Limits Revised',
      summary:
          'SEBI revises position limits for stock derivatives after STT on '
          'F&O was increased in the Finance Act 2024. New limits effective '
          'November 2024.',
      source: RegSource.sebi,
      category: UpdateCategory.circular,
      publicationDate: DateTime.utc(2024, 10, 1),
      effectiveDate: DateTime.utc(2024, 11, 1),
      impactLevel: ImpactLevel.medium,
      affectedSections: const ['F&O', 'STT'],
      url: null,
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-009',
      title: 'CBDT: Revised Income Tax Return Forms for AY 2025-26',
      summary:
          'Income Tax Department notifies revised ITR forms (ITR-1 to ITR-7) '
          'for Assessment Year 2025-26 incorporating Finance Act 2024 changes '
          'including new capital gains schedules.',
      source: RegSource.cbdt,
      category: UpdateCategory.notification,
      publicationDate: DateTime.utc(2025, 1, 31),
      effectiveDate: DateTime.utc(2025, 4, 1),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['ITR-1', 'ITR-2', 'ITR-3', 'Schedule CG'],
      url: null,
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'reg-010',
      title: 'RBI: Repo Rate Held at 6.5% — Impact on TDS Certificates',
      summary:
          'RBI Monetary Policy Committee holds repo rate at 6.5% for FY '
          '2024-25. CAs should reassess TDS certificates issued under Section '
          '197 for interest income.',
      source: RegSource.rbi,
      category: UpdateCategory.pressRelease,
      publicationDate: DateTime.utc(2024, 12, 6),
      effectiveDate: null,
      impactLevel: ImpactLevel.low,
      affectedSections: const ['194A', '197'],
      url: null,
      isRead: true,
    ),
    RegulatoryUpdate(
      updateId: 'reg-011',
      title: 'CBIC Notification 12/2024: E-Invoicing Threshold Reduced to ₹5 Cr',
      summary:
          'Mandatory e-invoicing extended to taxpayers with aggregate turnover '
          'exceeding ₹5 crore from April 1, 2024.',
      source: RegSource.cbic,
      category: UpdateCategory.notification,
      publicationDate: DateTime.utc(2024, 3, 1),
      effectiveDate: DateTime.utc(2024, 4, 1),
      impactLevel: ImpactLevel.medium,
      affectedSections: const ['31A', 'Rule 48(4)'],
      url: null,
      isRead: true,
    ),
    RegulatoryUpdate(
      updateId: 'reg-012',
      title: 'ITAT Ruling: No Section 36(1)(va) Disallowance for Belated PF/ESI',
      summary:
          'ITAT Mumbai holds that employee contribution to PF/ESI deposited '
          'before ITR filing due date cannot be disallowed under Section '
          '36(1)(va) as amended, in line with SC ruling in Checkmate Services.',
      source: RegSource.itat,
      category: UpdateCategory.caseLaw,
      publicationDate: DateTime.utc(2024, 8, 15),
      effectiveDate: null,
      impactLevel: ImpactLevel.medium,
      affectedSections: const ['36(1)(va)', '43B'],
      url: null,
      isRead: false,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the most recent [limit] regulatory updates.
  List<RegulatoryUpdate> getLatestUpdates({int limit = 20}) {
    final count = limit < _mockUpdates.length ? limit : _mockUpdates.length;
    return List.unmodifiable(_mockUpdates.take(count).toList());
  }

  /// Searches updates whose [title], [summary], or [affectedSections] contain
  /// [query] (case-insensitive).
  List<RegulatoryUpdate> searchUpdates(String query) {
    final q = query.toLowerCase();
    return _mockUpdates.where((u) {
      final haystack =
          '${u.title} ${u.summary} ${u.affectedSections.join(' ')}'
              .toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  /// Filters [updates] to those matching [source].
  List<RegulatoryUpdate> filterBySource(
    List<RegulatoryUpdate> updates,
    RegSource source,
  ) {
    return updates.where((u) => u.source == source).toList();
  }

  /// Filters [updates] to those at or above [minLevel] in severity.
  ///
  /// Ordering: high > medium > low.
  List<RegulatoryUpdate> filterByImpact(
    List<RegulatoryUpdate> updates,
    ImpactLevel minLevel,
  ) {
    return updates.where((u) => _impactOrdinal(u.impactLevel) >= _impactOrdinal(minLevel)).toList();
  }

  /// Returns a new [RegulatoryUpdate] with [isRead] set to `true`.
  /// Never mutates the original.
  RegulatoryUpdate markAsRead(RegulatoryUpdate update) {
    return update.copyWith(isRead: true);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _impactOrdinal(ImpactLevel level) {
    switch (level) {
      case ImpactLevel.low:
        return 0;
      case ImpactLevel.medium:
        return 1;
      case ImpactLevel.high:
        return 2;
    }
  }
}
