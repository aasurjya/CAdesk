import 'package:ca_app/features/audit/domain/models/form3cd.dart';
import 'package:ca_app/features/audit/domain/models/form3cd_clause.dart';

/// Method of accounting used by the business.
enum AccountingMethod {
  mercantile(label: 'Mercantile'),
  cash(label: 'Cash');

  const AccountingMethod({required this.label});

  final String label;
}

/// Method used for inventory valuation.
enum InventoryValuationMethod {
  fifo(label: 'FIFO'),
  lifo(label: 'LIFO'),
  weightedAverage(label: 'Weighted Average'),
  specific(label: 'Specific Identification');

  const InventoryValuationMethod({required this.label});

  final String label;
}

/// A payment made to a related party subject to scrutiny under Sec 40A(2).
///
/// All amounts in paise.
class RelatedPartyPayment {
  const RelatedPartyPayment({
    required this.partyName,
    required this.relationship,
    required this.amountPaidPaise,
    required this.fairMarketValuePaise,
    required this.excessPaymentPaise,
  });

  final String partyName;
  final String relationship;
  final int amountPaidPaise;
  final int fairMarketValuePaise;

  /// Amount paid in excess of fair market value (paise).
  final int excessPaymentPaise;
}

/// An MSME payment delayed beyond 45 days, triggering disallowance under
/// Sec 43B(h).
///
/// All amounts in paise.
class MsmePayment {
  const MsmePayment({
    required this.supplierName,
    required this.amountPaise,
    required this.dueDateExceededBy,
  });

  final String supplierName;
  final int amountPaise;

  /// Number of days beyond the 45-day limit.
  final int dueDateExceededBy;
}

/// A cash loan receipt or repayment transaction for Sec 269SS / 269T checks.
///
/// Amount is in paise.
class CashLoanTransaction {
  const CashLoanTransaction({
    required this.partyName,
    required this.amountPaise,
    required this.transactionDate,
  });

  final String partyName;
  final int amountPaise;
  final DateTime transactionDate;
}

/// A depreciation entry for Form 3CD clause 19 disclosure.
class DepreciationDisclosure {
  const DepreciationDisclosure({
    required this.assetName,
    required this.openingWdvPaise,
    required this.additionsPaise,
    required this.disposalsPaise,
    required this.depreciationPaise,
    required this.closingWdvPaise,
  });

  final String assetName;
  final int openingWdvPaise;
  final int additionsPaise;
  final int disposalsPaise;
  final int depreciationPaise;
  final int closingWdvPaise;
}

/// All business data needed to generate Form 3CD.
class BusinessData {
  const BusinessData({
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.financialYear,
    required this.businessNature,
    required this.accountingMethod,
    required this.totalTurnover,
    required this.relatedPartyPayments,
    required this.msmePaymentsBeyond45Days,
    required this.cashLoanReceipts,
    required this.cashLoanRepayments,
    required this.depreciationEntries,
    required this.valuationMethod,
  });

  final String clientName;
  final String pan;
  final String assessmentYear;
  final int financialYear;
  final String businessNature;
  final AccountingMethod accountingMethod;

  /// Total turnover / gross receipts in paise.
  final int totalTurnover;

  final List<RelatedPartyPayment> relatedPartyPayments;
  final List<MsmePayment> msmePaymentsBeyond45Days;
  final List<CashLoanTransaction> cashLoanReceipts;
  final List<CashLoanTransaction> cashLoanRepayments;
  final List<DepreciationDisclosure> depreciationEntries;
  final InventoryValuationMethod valuationMethod;
}

/// Stateless service that generates a complete [Form3CD] from [BusinessData].
///
/// Covers all 44 clauses with computed responses and disclosures for the
/// key regulatory clauses.
class Form3CDGenerationService {
  Form3CDGenerationService._();

  /// Cash transaction limit under Sec 269SS / 269T (in paise = Rs 20,000).
  static const int _cashTransactionLimitPaise = 2000000;

  /// Generates all 44 clauses of Form 3CD from the given [data].
  static Form3CD generateForm3CD({required BusinessData data}) {
    final clauses = <Form3CDClause>[
      _clause01(data),
      _clause02(data),
      _clause03(data),
      _clause04(data),
      _clause05(data),
      _clause06(data),
      _clause07(data),
      _clause08(data),
      _clause09(data),
      _clause10(data),
      _clause11(data),
      _clause12(data),
      _clause13(data),
      _clause14(data),
      _clause15(data),
      _clause16(data),
      _clause17(data),
      _clause18(data),
      _clause19(data),
      _clause20(data),
      _clause21(data),
      _clause22(data),
      _clause23(data),
      _clause24(data),
      _clause25(data),
      _clause26(data),
      _clause27(data),
      _clause28(data),
      _clause29(data),
      _clause30(data),
      _clause31(data),
      _clause32(data),
      _clause33(data),
      _clause34(data),
      _clause35(data),
      _clause36(data),
      _clause37(data),
      _clause38(data),
      _clause39(data),
      _clause40(data),
      _clause41(data),
      _clause42(data),
      _clause43(data),
      _clause44(data),
    ];

    return Form3CD(
      clientName: data.clientName,
      pan: data.pan,
      assessmentYear: data.assessmentYear,
      financialYear: data.financialYear,
      businessNature: data.businessNature,
      clauses: List<Form3CDClause>.unmodifiable(clauses),
    );
  }

  // ── Clauses 1–12: Basic details ──────────────────────────────────────────

  static Form3CDClause _clause01(BusinessData d) => Form3CDClause(
    clauseNumber: 1,
    description: 'Name of the assessee',
    response: d.clientName,
    disclosures: const [],
  );

  static Form3CDClause _clause02(BusinessData d) => const Form3CDClause(
    clauseNumber: 2,
    description: 'Address of the assessee',
    response: 'As per records',
    disclosures: [],
  );

  static Form3CDClause _clause03(BusinessData d) => Form3CDClause(
    clauseNumber: 3,
    description: 'Permanent Account Number (PAN)',
    response: d.pan,
    disclosures: const [],
  );

  static Form3CDClause _clause04(BusinessData d) => const Form3CDClause(
    clauseNumber: 4,
    description: 'Whether the assessee is liable to pay indirect tax',
    response: 'Yes',
    disclosures: [],
  );

  static Form3CDClause _clause05(BusinessData d) => Form3CDClause(
    clauseNumber: 5,
    description: 'Nature of business or profession',
    response: d.businessNature,
    disclosures: const [],
  );

  static Form3CDClause _clause06(BusinessData d) => const Form3CDClause(
    clauseNumber: 6,
    description: 'Books of account and documents examined',
    response: 'Cash book, ledger, journal, bills, vouchers, bank statements',
    disclosures: [],
  );

  static Form3CDClause _clause07(BusinessData d) => const Form3CDClause(
    clauseNumber: 7,
    description:
        'Whether the profit and loss account includes any profit or loss from speculation',
    response: 'No',
    disclosures: [],
  );

  static Form3CDClause _clause08(BusinessData d) => Form3CDClause(
    clauseNumber: 8,
    description:
        'Relevant clause of Section 44AB under which audit is conducted',
    response: _auditClause(d.totalTurnover),
    disclosures: const [],
  );

  static Form3CDClause _clause09(BusinessData d) => Form3CDClause(
    clauseNumber: 9,
    description: 'Turnover / gross receipts',
    response: _formatPaise(d.totalTurnover),
    disclosures: const [],
  );

  static Form3CDClause _clause10(BusinessData d) => const Form3CDClause(
    clauseNumber: 10,
    description:
        'Whether the assessee maintains books of account prescribed under Sec 44AA',
    response: 'Yes',
    disclosures: [],
  );

  static Form3CDClause _clause11(BusinessData d) => const Form3CDClause(
    clauseNumber: 11,
    description: 'List of books of account maintained and address where kept',
    response: 'All prescribed books maintained at principal place of business',
    disclosures: [],
  );

  static Form3CDClause _clause12(BusinessData d) => const Form3CDClause(
    clauseNumber: 12,
    description:
        'Whether the profit and loss account is prepared on the basis of same method of accounting as in the preceding year',
    response: 'Yes',
    disclosures: [],
  );

  // ── Clause 13: Accounting method ─────────────────────────────────────────

  static Form3CDClause _clause13(BusinessData d) => Form3CDClause(
    clauseNumber: 13,
    description:
        'Method of accounting employed in the previous year and whether there was any change during the previous year',
    response: d.accountingMethod.label,
    disclosures: const [],
  );

  // ── Clauses 14–15: Valuation ──────────────────────────────────────────────

  static Form3CDClause _clause14(BusinessData d) => Form3CDClause(
    clauseNumber: 14,
    description:
        'Method of valuation of closing stock employed in the previous year',
    response: d.valuationMethod.label,
    disclosures: const [],
  );

  static Form3CDClause _clause15(BusinessData d) => const Form3CDClause(
    clauseNumber: 15,
    description:
        'Give the following particulars of the capital asset converted into stock-in-trade',
    response: 'N/A',
    disclosures: [],
  );

  // ── Clauses 16–18: Loans & advances ──────────────────────────────────────

  static Form3CDClause _clause16(BusinessData d) => const Form3CDClause(
    clauseNumber: 16,
    description:
        'Amounts not credited to the profit and loss account, being: (a) items falling within the scope of Section 28',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause17(BusinessData d) => const Form3CDClause(
    clauseNumber: 17,
    description:
        'Where any land or building or both is transferred during the previous year — circle rate vs actual consideration',
    response: 'N/A',
    disclosures: [],
  );

  static Form3CDClause _clause18(BusinessData d) => const Form3CDClause(
    clauseNumber: 18,
    description:
        'Particulars of depreciation allowable as per the Income Tax Act, 1961',
    response: 'As per books and IT computation',
    disclosures: [],
  );

  // ── Clause 19: Depreciation disclosures ──────────────────────────────────

  static Form3CDClause _clause19(BusinessData d) {
    final disclosures = d.depreciationEntries
        .map(
          (e) =>
              '${e.assetName}: Opening WDV ${_formatPaise(e.openingWdvPaise)}, '
              'Additions ${_formatPaise(e.additionsPaise)}, '
              'Disposals ${_formatPaise(e.disposalsPaise)}, '
              'Depreciation ${_formatPaise(e.depreciationPaise)}, '
              'Closing WDV ${_formatPaise(e.closingWdvPaise)}',
        )
        .toList();
    return Form3CDClause(
      clauseNumber: 19,
      description:
          'Amount of depreciation claimed in the books and as per IT Act',
      response: disclosures.isEmpty ? 'Nil' : 'See disclosures',
      disclosures: disclosures,
    );
  }

  // ── Clauses 20–25: Miscellaneous disallowances ────────────────────────────

  static Form3CDClause _clause20(BusinessData d) => const Form3CDClause(
    clauseNumber: 20,
    description:
        'Amounts admissible under sections 33AB, 33ABA, 35, 35ABB, 35AC, 35CCA, 35CCB, 35D, 35DD, 35DDA, 35E',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause21(BusinessData d) => const Form3CDClause(
    clauseNumber: 21,
    description:
        'Amount of interest inadmissible under section 23 of MSME Act 2006',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause22(BusinessData d) => Form3CDClause(
    clauseNumber: 22,
    description:
        'Particulars of payments made to persons specified under section 40A(2)(b)',
    response: d.relatedPartyPayments.isEmpty ? 'Nil' : 'See Clause 26',
    disclosures: const [],
  );

  static Form3CDClause _clause23(BusinessData d) => const Form3CDClause(
    clauseNumber: 23,
    description:
        'Amounts deemed to be profits and gains under section 32AC, 32AD, 33AB or 33ABA',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause24(BusinessData d) => const Form3CDClause(
    clauseNumber: 24,
    description: 'Any amount of profit chargeable to tax under section 41',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause25(BusinessData d) => const Form3CDClause(
    clauseNumber: 25,
    description:
        'Details of any amount borrowed on hundi or any amount due on hundi repaid',
    response: 'Nil',
    disclosures: [],
  );

  // ── Clause 26: Related party payments — Sec 40A(2) ───────────────────────

  static Form3CDClause _clause26(BusinessData d) {
    if (d.relatedPartyPayments.isEmpty) {
      return const Form3CDClause(
        clauseNumber: 26,
        description:
            'Particulars of any payment made to a person specified under section 40A(2)(b)',
        response: 'No related party payments',
        disclosures: [],
      );
    }

    final disclosures = d.relatedPartyPayments.map((p) {
      final excess = p.excessPaymentPaise > 0
          ? ' Excess over FMV: ${_formatPaise(p.excessPaymentPaise)} — '
                'disallowable under Sec 40A(2)'
          : ' Within FMV — no disallowance';
      return '${p.partyName} (${p.relationship}): '
          'Paid ${_formatPaise(p.amountPaidPaise)}, '
          'FMV ${_formatPaise(p.fairMarketValuePaise)}.$excess';
    }).toList();

    return Form3CDClause(
      clauseNumber: 26,
      description:
          'Particulars of any payment made to a person specified under section 40A(2)(b)',
      response: 'Related party payments exist — see disclosures',
      disclosures: disclosures,
    );
  }

  // ── Clauses 27–35: Various disallowances ─────────────────────────────────

  static Form3CDClause _clause27(BusinessData d) => const Form3CDClause(
    clauseNumber: 27,
    description:
        'Amounts deemed to be income under section 32AC, 32AD, 33AB, 33ABA',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause28(BusinessData d) => const Form3CDClause(
    clauseNumber: 28,
    description:
        'Whether the assessee has given or taken on hire any goods carriage',
    response: 'No',
    disclosures: [],
  );

  static Form3CDClause _clause29(BusinessData d) => const Form3CDClause(
    clauseNumber: 29,
    description: 'Whether any deduction is admissible under section 32AC',
    response: 'N/A',
    disclosures: [],
  );

  static Form3CDClause _clause30(BusinessData d) => const Form3CDClause(
    clauseNumber: 30,
    description:
        'Amount of income or expenditure of prior period credited or debited to P&L',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause31(BusinessData d) => const Form3CDClause(
    clauseNumber: 31,
    description: 'Details of any amount borrowed in cash or on demand drafts',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause32(BusinessData d) => const Form3CDClause(
    clauseNumber: 32,
    description: 'Details of brought forward losses or depreciation',
    response: 'As per IT computation',
    disclosures: [],
  );

  static Form3CDClause _clause33(BusinessData d) => const Form3CDClause(
    clauseNumber: 33,
    description: 'Section 80-IB / 80-IC deductions claimed',
    response: 'Nil',
    disclosures: [],
  );

  static Form3CDClause _clause34(BusinessData d) => const Form3CDClause(
    clauseNumber: 34,
    description: 'Whether the assessee has complied with TDS provisions',
    response: 'Yes, TDS complied with',
    disclosures: [],
  );

  static Form3CDClause _clause35(BusinessData d) => const Form3CDClause(
    clauseNumber: 35,
    description:
        'Quantitative details of principal item of goods manufactured / traded',
    response: 'Refer books of account',
    disclosures: [],
  );

  // ── Clause 36: MSME payments — Sec 43B(h) ────────────────────────────────

  static Form3CDClause _clause36(BusinessData d) {
    if (d.msmePaymentsBeyond45Days.isEmpty) {
      return const Form3CDClause(
        clauseNumber: 36,
        description:
            'Payments to MSME suppliers beyond the time limit under MSME Act — Sec 43B(h)',
        response: 'No MSME payments beyond 45 days',
        disclosures: [],
      );
    }

    final disclosures = d.msmePaymentsBeyond45Days
        .map(
          (p) =>
              '${p.supplierName}: ${_formatPaise(p.amountPaise)} delayed by '
              '${p.dueDateExceededBy} days beyond 45-day limit — '
              'disallowable under Sec 43B(h)',
        )
        .toList();

    return Form3CDClause(
      clauseNumber: 36,
      description:
          'Payments to MSME suppliers beyond the time limit under MSME Act — Sec 43B(h)',
      response: 'MSME payments delayed beyond 45 days — see disclosures',
      disclosures: disclosures,
    );
  }

  // ── Clauses 37–39: Inventory / misc ──────────────────────────────────────

  static Form3CDClause _clause37(BusinessData d) => const Form3CDClause(
    clauseNumber: 37,
    description:
        'In the case of a domestic company — details of tax on distributed profits',
    response: 'N/A',
    disclosures: [],
  );

  static Form3CDClause _clause38(BusinessData d) => const Form3CDClause(
    clauseNumber: 38,
    description:
        'Whether the assessee is required to furnish statement under section 206C',
    response: 'N/A',
    disclosures: [],
  );

  static Form3CDClause _clause39(BusinessData d) => const Form3CDClause(
    clauseNumber: 39,
    description:
        'Where the assessee is a company — details of shares bought back',
    response: 'N/A',
    disclosures: [],
  );

  // ── Clause 40: Sec 269SS — cash loan receipts ────────────────────────────

  static Form3CDClause _clause40(BusinessData d) {
    final violations = d.cashLoanReceipts
        .where((t) => t.amountPaise > _cashTransactionLimitPaise)
        .toList();

    if (violations.isEmpty) {
      return const Form3CDClause(
        clauseNumber: 40,
        description:
            'Particulars of any loan or deposit taken or accepted in contravention of the provisions of section 269SS',
        response: 'No violations of Sec 269SS',
        disclosures: [],
      );
    }

    final disclosures = violations
        .map(
          (t) =>
              '${t.partyName}: Cash receipt of ${_formatPaise(t.amountPaise)} '
              'on ${_formatDate(t.transactionDate)} — '
              'contravenes Sec 269SS (limit Rs 20,000)',
        )
        .toList();

    return Form3CDClause(
      clauseNumber: 40,
      description:
          'Particulars of any loan or deposit taken or accepted in contravention of the provisions of section 269SS',
      response:
          'Cash loan receipts exceeding Rs 20,000 detected — see disclosures',
      disclosures: disclosures,
    );
  }

  // ── Clause 41: Sec 269T — cash loan repayments ───────────────────────────

  static Form3CDClause _clause41(BusinessData d) {
    final violations = d.cashLoanRepayments
        .where((t) => t.amountPaise > _cashTransactionLimitPaise)
        .toList();

    if (violations.isEmpty) {
      return const Form3CDClause(
        clauseNumber: 41,
        description:
            'Particulars of any repayment of loan or deposit in contravention of the provisions of section 269T',
        response: 'No violations of Sec 269T',
        disclosures: [],
      );
    }

    final disclosures = violations
        .map(
          (t) =>
              '${t.partyName}: Cash repayment of ${_formatPaise(t.amountPaise)} '
              'on ${_formatDate(t.transactionDate)} — '
              'contravenes Sec 269T (limit Rs 20,000)',
        )
        .toList();

    return Form3CDClause(
      clauseNumber: 41,
      description:
          'Particulars of any repayment of loan or deposit in contravention of the provisions of section 269T',
      response:
          'Cash loan repayments exceeding Rs 20,000 detected — see disclosures',
      disclosures: disclosures,
    );
  }

  // ── Clauses 42–44: GAAR / general reporting ──────────────────────────────

  static Form3CDClause _clause42(BusinessData d) => const Form3CDClause(
    clauseNumber: 42,
    description: 'Details of brought forward loss or depreciation allowance',
    response: 'As per IT records',
    disclosures: [],
  );

  static Form3CDClause _clause43(BusinessData d) => const Form3CDClause(
    clauseNumber: 43,
    description: 'Details of deductions under section 80P',
    response: 'N/A',
    disclosures: [],
  );

  static Form3CDClause _clause44(BusinessData d) => const Form3CDClause(
    clauseNumber: 44,
    description:
        'Breakup of total expenditure into expenditure on entities registered and not registered under GST',
    response: 'Refer GST reconciliation statement',
    disclosures: [],
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Formats a paise integer as a human-readable rupee string.
  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    final paiseRemainder = paise % 100;
    if (paiseRemainder == 0) return 'Rs $rupees';
    return 'Rs $rupees.${paiseRemainder.toString().padLeft(2, '0')}';
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// Returns the Sec 44AB clause string based on turnover thresholds.
  /// 10 crore threshold for business; 50 lakh for profession (in paise).
  static String _auditClause(int turnonverPaise) {
    const businessThreshold = 100000000000; // 10 crore in paise
    const professionThreshold = 5000000000; // 50 lakh in paise
    if (turnonverPaise > businessThreshold) {
      return 'Section 44AB(a) — business turnover exceeds Rs 10 crore';
    }
    if (turnonverPaise > professionThreshold) {
      return 'Section 44AB(b) — professional receipts exceed Rs 50 lakh';
    }
    return 'Section 44AB — applicable';
  }
}
