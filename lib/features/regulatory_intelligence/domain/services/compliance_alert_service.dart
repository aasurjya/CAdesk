import '../models/compliance_alert.dart';

/// Stateless singleton service that generates and filters [ComplianceAlert]s
/// for a given financial year.
class ComplianceAlertService {
  ComplianceAlertService._();

  /// Singleton instance.
  static final ComplianceAlertService instance = ComplianceAlertService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates all compliance alerts for [financialYear] as of [today].
  ///
  /// [financialYear] is the year in which the FY ends, e.g. 2025 for FY
  /// 2024-25.
  List<ComplianceAlert> generateAlerts(int financialYear, DateTime today) {
    final fy = financialYear;
    final prevYr = fy - 1;

    return [
      // ------------------------------------------------------------------
      // ITR Filing Deadline — July 31
      // ------------------------------------------------------------------
      ComplianceAlert(
        alertId: 'alert-itr-$fy',
        title: 'ITR Filing Deadline – FY $prevYr-${fy % 100}',
        description:
            'Income Tax Returns for individuals, HUFs, and firms not '
            'subject to tax audit must be filed by July 31, $fy. '
            'Late filing attracts penalty under Section 234F.',
        alertType: AlertType.deadlineApproaching,
        dueDate: DateTime.utc(fy, 7, 31),
        daysRemaining: computeDaysRemaining(
          ComplianceAlert(
            alertId: '',
            title: '',
            description: '',
            alertType: AlertType.deadlineApproaching,
            dueDate: DateTime.utc(fy, 7, 31),
            daysRemaining: null,
            applicableTo: [],
            penaltyIfMissed: null,
            priority: AlertPriority.high,
          ),
          today,
        ),
        applicableTo: const ['Individual', 'HUF', 'Firm', 'LLP'],
        penaltyIfMissed: '₹5,000 under Section 234F (₹1,000 if income ≤ ₹5L)',
        priority: AlertPriority.high,
      ),

      // ------------------------------------------------------------------
      // Tax Audit Deadline — September 30
      // ------------------------------------------------------------------
      ComplianceAlert(
        alertId: 'alert-audit-$fy',
        title: 'Tax Audit Report Deadline – FY $prevYr-${fy % 100}',
        description:
            'Tax Audit Report (Form 3CA/3CB + 3CD) for businesses and '
            'professionals subject to audit under Section 44AB must be '
            'filed by September 30, $fy.',
        alertType: AlertType.deadlineApproaching,
        dueDate: DateTime.utc(fy, 9, 30),
        daysRemaining: computeDaysRemaining(
          ComplianceAlert(
            alertId: '',
            title: '',
            description: '',
            alertType: AlertType.deadlineApproaching,
            dueDate: DateTime.utc(fy, 9, 30),
            daysRemaining: null,
            applicableTo: [],
            penaltyIfMissed: null,
            priority: AlertPriority.critical,
          ),
          today,
        ),
        applicableTo: const ['Individual', 'HUF', 'Firm', 'LLP', 'Company'],
        penaltyIfMissed: '0.5% of turnover or ₹1.5 lakh, whichever is lower',
        priority: AlertPriority.critical,
      ),

      // ------------------------------------------------------------------
      // GSTR-9 Annual Return — December 31
      // ------------------------------------------------------------------
      ComplianceAlert(
        alertId: 'alert-gstr9-$fy',
        title: 'GSTR-9 Annual Return Deadline – FY $prevYr-${fy % 100}',
        description:
            'GSTR-9 Annual Return for registered GST taxpayers with '
            'aggregate turnover exceeding ₹2 crore must be filed by '
            'December 31, $fy.',
        alertType: AlertType.deadlineApproaching,
        dueDate: DateTime.utc(fy, 12, 31),
        daysRemaining: computeDaysRemaining(
          ComplianceAlert(
            alertId: '',
            title: '',
            description: '',
            alertType: AlertType.deadlineApproaching,
            dueDate: DateTime.utc(fy, 12, 31),
            daysRemaining: null,
            applicableTo: [],
            penaltyIfMissed: null,
            priority: AlertPriority.high,
          ),
          today,
        ),
        applicableTo: const ['Individual', 'Firm', 'LLP', 'Company'],
        penaltyIfMissed:
            '₹200/day (₹100 CGST + ₹100 SGST), max 0.5% of turnover',
        priority: AlertPriority.high,
      ),

      // ------------------------------------------------------------------
      // DIR-3 KYC — September 30
      // ------------------------------------------------------------------
      ComplianceAlert(
        alertId: 'alert-dir3-$fy',
        title: 'DIR-3 KYC for Directors – Due September 30, $fy',
        description:
            'All directors with a valid DIN must file DIR-3 KYC (web-based '
            'or form-based) annually by September 30 to avoid deactivation '
            'of DIN under the Companies Act, 2013.',
        alertType: AlertType.deadlineApproaching,
        dueDate: DateTime.utc(fy, 9, 30),
        daysRemaining: computeDaysRemaining(
          ComplianceAlert(
            alertId: '',
            title: '',
            description: '',
            alertType: AlertType.deadlineApproaching,
            dueDate: DateTime.utc(fy, 9, 30),
            daysRemaining: null,
            applicableTo: [],
            penaltyIfMissed: null,
            priority: AlertPriority.high,
          ),
          today,
        ),
        applicableTo: const ['Company', 'LLP'],
        penaltyIfMissed: '₹5,000 reactivation fee; DIN deactivated until filed',
        priority: AlertPriority.high,
      ),

      // ------------------------------------------------------------------
      // Section 43B(h) — MSME Payments
      // ------------------------------------------------------------------
      ComplianceAlert(
        alertId: 'alert-43bh-$fy',
        title:
            'Section 43B(h): MSME Payment Compliance – FY $prevYr-${fy % 100}',
        description:
            'Under Section 43B(h), payments to MSME suppliers must be made '
            'within 45 days (15 days where no written agreement) to claim '
            'tax deduction. Outstanding amounts beyond this are disallowed.',
        alertType: AlertType.newCompliance,
        dueDate: null,
        daysRemaining: null,
        applicableTo: const ['Individual', 'HUF', 'Firm', 'LLP', 'Company'],
        penaltyIfMissed:
            'Disallowance of expenditure in current year; '
            'taxed in year of actual payment',
        priority: AlertPriority.high,
      ),

      // ------------------------------------------------------------------
      // Finance Act 2024 — STCG/LTCG Rate Change
      // ------------------------------------------------------------------
      ComplianceAlert(
        alertId: 'alert-cgrates-2024',
        title: 'Finance Act 2024: New STCG (20%) and LTCG (12.5%) Rates',
        description:
            'Short-term capital gains under Section 111A increased from '
            '15% to 20%, and long-term capital gains under Section 112A '
            'increased from 10% to 12.5%, effective July 23, 2024. '
            'Exemption limit raised to ₹1,25,000. Advance tax and '
            'TDS certificates need revision.',
        alertType: AlertType.rateChange,
        dueDate: null,
        daysRemaining: null,
        applicableTo: const [
          'Individual',
          'HUF',
          'Firm',
          'LLP',
          'Company',
          'NRI',
        ],
        penaltyIfMissed:
            'Underpayment of advance tax; interest under 234B/234C',
        priority: AlertPriority.critical,
      ),

      // ------------------------------------------------------------------
      // Section 194T — New TDS on Partner Remuneration
      // ------------------------------------------------------------------
      ComplianceAlert(
        alertId: 'alert-194t-$fy',
        title:
            'New TDS: Section 194T on Partner Salary (Effective Apr 1, 2025)',
        description:
            'Finance Act 2024 inserts Section 194T requiring partnership '
            'firms to deduct 10% TDS on salary, remuneration, bonus, '
            'commission, and interest paid to partners exceeding ₹20,000 '
            'per year, effective April 1, 2025.',
        alertType: AlertType.newCompliance,
        dueDate: DateTime.utc(2025, 4, 1),
        daysRemaining: computeDaysRemaining(
          ComplianceAlert(
            alertId: '',
            title: '',
            description: '',
            alertType: AlertType.deadlineApproaching,
            dueDate: DateTime.utc(2025, 4, 1),
            daysRemaining: null,
            applicableTo: [],
            penaltyIfMissed: null,
            priority: AlertPriority.high,
          ),
          today,
        ),
        applicableTo: const ['Firm', 'LLP'],
        penaltyIfMissed:
            'Interest under 201(1A) and disallowance under 40(a)(ia)',
        priority: AlertPriority.high,
      ),
    ];
  }

  /// Returns only [AlertPriority.critical] and [AlertPriority.high] alerts.
  List<ComplianceAlert> getPriorityAlerts(List<ComplianceAlert> alerts) {
    return alerts
        .where(
          (a) =>
              a.priority == AlertPriority.critical ||
              a.priority == AlertPriority.high,
        )
        .toList();
  }

  /// Returns alerts whose [applicableTo] list contains [entityType].
  List<ComplianceAlert> filterForEntityType(
    List<ComplianceAlert> alerts,
    String entityType,
  ) {
    return alerts.where((a) => a.applicableTo.contains(entityType)).toList();
  }

  /// Computes the number of days remaining until [alert.dueDate] relative to
  /// [today]. Returns `null` when [dueDate] is not set.
  int? computeDaysRemaining(ComplianceAlert alert, DateTime today) {
    final due = alert.dueDate;
    if (due == null) return null;
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final dueNormalized = DateTime(due.year, due.month, due.day);
    return dueNormalized.difference(todayNormalized).inDays;
  }
}
