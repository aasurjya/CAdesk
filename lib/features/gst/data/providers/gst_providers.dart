import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/gst_client.dart';
import '../../domain/models/gst_return.dart';
import '../../domain/models/itc_reconciliation.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final List<GstClient> _mockClients = [
  GstClient(
    id: 'gst-001',
    businessName: 'Reliance Digital Retail Ltd',
    tradeName: 'Reliance Digital',
    gstin: '27AABCR1718E1ZL',
    pan: 'AABCR1718E',
    registrationType: GstRegistrationType.regular,
    state: 'Maharashtra',
    stateCode: '27',
    returnsPending: const ['GSTR-1'],
    lastFiledDate: DateTime(2026, 2, 20),
    complianceScore: 92,
  ),
  GstClient(
    id: 'gst-002',
    businessName: 'Tata Consultancy Services Ltd',
    tradeName: 'TCS',
    gstin: '27AABCT1234F1ZP',
    pan: 'AABCT1234F',
    registrationType: GstRegistrationType.regular,
    state: 'Maharashtra',
    stateCode: '27',
    returnsPending: const [],
    lastFiledDate: DateTime(2026, 3, 5),
    complianceScore: 98,
  ),
  GstClient(
    id: 'gst-003',
    businessName: 'Sharma & Sons Trading Co',
    tradeName: 'Sharma Traders',
    gstin: '09AAFFS5678G1Z3',
    pan: 'AAFFS5678G',
    registrationType: GstRegistrationType.composition,
    state: 'Uttar Pradesh',
    stateCode: '09',
    returnsPending: const ['GSTR-3B', 'GSTR-1'],
    lastFiledDate: DateTime(2026, 1, 15),
    complianceScore: 64,
  ),
  GstClient(
    id: 'gst-004',
    businessName: 'Infosys BPM Limited',
    gstin: '29AABCI5678H1ZK',
    pan: 'AABCI5678H',
    registrationType: GstRegistrationType.sez,
    state: 'Karnataka',
    stateCode: '29',
    returnsPending: const ['GSTR-1'],
    lastFiledDate: DateTime(2026, 2, 28),
    complianceScore: 88,
  ),
  GstClient(
    id: 'gst-005',
    businessName: 'Patel Textiles Private Ltd',
    tradeName: 'Patel Fabrics',
    gstin: '24AABPP9012J1Z7',
    pan: 'AABPP9012J',
    registrationType: GstRegistrationType.regular,
    state: 'Gujarat',
    stateCode: '24',
    returnsPending: const ['GSTR-3B'],
    lastFiledDate: DateTime(2026, 2, 10),
    complianceScore: 76,
  ),
  GstClient(
    id: 'gst-006',
    businessName: 'Chennai Spices Export House',
    gstin: '33AABCC3456K1ZQ',
    pan: 'AABCC3456K',
    registrationType: GstRegistrationType.regular,
    state: 'Tamil Nadu',
    stateCode: '33',
    returnsPending: const ['GSTR-1', 'GSTR-3B', 'GSTR-9'],
    lastFiledDate: DateTime(2025, 12, 20),
    complianceScore: 42,
  ),
  GstClient(
    id: 'gst-007',
    businessName: 'Rajasthan Marble Industries',
    gstin: '08AABCR7890L1Z2',
    pan: 'AABCR7890L',
    registrationType: GstRegistrationType.casual,
    state: 'Rajasthan',
    stateCode: '08',
    returnsPending: const [],
    lastFiledDate: DateTime(2026, 3, 1),
    complianceScore: 85,
  ),
  GstClient(
    id: 'gst-008',
    businessName: 'Delhi Auto Components Pvt Ltd',
    tradeName: 'DAC Parts',
    gstin: '07AABCD4567M1ZX',
    pan: 'AABCD4567M',
    registrationType: GstRegistrationType.regular,
    state: 'Delhi',
    stateCode: '07',
    returnsPending: const ['GSTR-3B'],
    lastFiledDate: DateTime(2026, 2, 18),
    complianceScore: 71,
  ),
];

List<GstReturn> _buildMockReturns() {
  final now = DateTime(2026, 3, 10);
  final returns = <GstReturn>[];
  var seq = 0;

  for (final client in _mockClients) {
    // GSTR-1 for Feb 2026
    final gstr1Due = DateTime(2026, 3, 11);
    final gstr1Filed = client.returnsPending.contains('GSTR-1');
    returns.add(
      GstReturn(
        id: 'ret-${++seq}',
        clientId: client.id,
        gstin: client.gstin,
        returnType: GstReturnType.gstr1,
        periodMonth: 2,
        periodYear: 2026,
        dueDate: gstr1Due,
        status: gstr1Filed ? GstReturnStatus.pending : GstReturnStatus.filed,
        filedDate: gstr1Filed ? null : now.subtract(const Duration(days: 5)),
        taxableValue: 850000 + seq * 120000,
        igst: 42500 + seq * 6000,
        cgst: 21250 + seq * 3000,
        sgst: 21250 + seq * 3000,
        cess: 0,
        itcClaimed: 15000 + seq * 2000,
      ),
    );

    // GSTR-3B for Feb 2026
    final gstr3bDue = DateTime(2026, 3, 20);
    final gstr3bPending = client.returnsPending.contains('GSTR-3B');
    returns.add(
      GstReturn(
        id: 'ret-${++seq}',
        clientId: client.id,
        gstin: client.gstin,
        returnType: GstReturnType.gstr3b,
        periodMonth: 2,
        periodYear: 2026,
        dueDate: gstr3bDue,
        status: gstr3bPending ? GstReturnStatus.pending : GstReturnStatus.filed,
        filedDate: gstr3bPending ? null : now.subtract(const Duration(days: 3)),
        taxableValue: 920000 + seq * 95000,
        igst: 46000 + seq * 4750,
        cgst: 23000 + seq * 2375,
        sgst: 23000 + seq * 2375,
        cess: 500,
        itcClaimed: 18000 + seq * 1500,
      ),
    );

    // GSTR-9 annual (only for some clients)
    if (client.returnsPending.contains('GSTR-9') ||
        client.complianceScore > 80) {
      final gstr9Due = DateTime(2026, 12, 31);
      final gstr9Pending = client.returnsPending.contains('GSTR-9');
      returns.add(
        GstReturn(
          id: 'ret-${++seq}',
          clientId: client.id,
          gstin: client.gstin,
          returnType: GstReturnType.gstr9,
          periodMonth: 3,
          periodYear: 2025,
          dueDate: gstr9Due,
          status: gstr9Pending
              ? GstReturnStatus.pending
              : GstReturnStatus.filed,
          filedDate: gstr9Pending ? null : DateTime(2026, 1, 15),
          taxableValue: 10200000 + seq * 500000,
          igst: 510000 + seq * 25000,
          cgst: 255000 + seq * 12500,
          sgst: 255000 + seq * 12500,
          cess: 5000,
          itcClaimed: 200000 + seq * 10000,
        ),
      );
    }
  }

  // Add a couple of late-filed returns for realism.
  returns.add(
    GstReturn(
      id: 'ret-${++seq}',
      clientId: 'gst-006',
      gstin: '33AABCC3456K1ZQ',
      returnType: GstReturnType.gstr1,
      periodMonth: 1,
      periodYear: 2026,
      dueDate: DateTime(2026, 2, 11),
      filedDate: DateTime(2026, 2, 25),
      status: GstReturnStatus.lateFiled,
      taxableValue: 780000,
      igst: 39000,
      cgst: 19500,
      sgst: 19500,
      cess: 0,
      itcClaimed: 12000,
    ),
  );

  returns.add(
    GstReturn(
      id: 'ret-${++seq}',
      clientId: 'gst-003',
      gstin: '09AAFFS5678G1Z3',
      returnType: GstReturnType.gstr3b,
      periodMonth: 1,
      periodYear: 2026,
      dueDate: DateTime(2026, 2, 20),
      filedDate: DateTime(2026, 3, 2),
      status: GstReturnStatus.lateFiled,
      taxableValue: 540000,
      igst: 27000,
      cgst: 13500,
      sgst: 13500,
      cess: 0,
      itcClaimed: 9500,
    ),
  );

  return List.unmodifiable(returns);
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All GST clients.
final gstClientsProvider = Provider<List<GstClient>>(
  (_) => List.unmodifiable(_mockClients),
);

/// All GST returns.
final gstReturnsProvider = Provider<List<GstReturn>>(
  (_) => _buildMockReturns(),
);

/// Currently selected period (month, year).
final gstSelectedPeriodProvider =
    NotifierProvider<GstSelectedPeriodNotifier, ({int month, int year})>(
      GstSelectedPeriodNotifier.new,
    );

class GstSelectedPeriodNotifier extends Notifier<({int month, int year})> {
  @override
  ({int month, int year}) build() => (month: 2, year: 2026);

  void update(({int month, int year}) value) => state = value;
}

/// Returns filtered by the selected period.
final gstFilteredReturnsProvider = Provider<List<GstReturn>>((ref) {
  final period = ref.watch(gstSelectedPeriodProvider);
  final allReturns = ref.watch(gstReturnsProvider);
  return allReturns
      .where(
        (r) => r.periodMonth == period.month && r.periodYear == period.year,
      )
      .toList();
});

/// Returns filtered by period AND return type.
final gstReturnsByTypeProvider =
    Provider.family<List<GstReturn>, GstReturnType?>((ref, type) {
      final filtered = ref.watch(gstFilteredReturnsProvider);
      if (type == null) return filtered;
      return filtered.where((r) => r.returnType == type).toList();
    });

/// Returns for a specific client in the selected period.
final gstReturnsForClientProvider = Provider.family<List<GstReturn>, String>((
  ref,
  clientId,
) {
  final filtered = ref.watch(gstFilteredReturnsProvider);
  return filtered.where((r) => r.clientId == clientId).toList();
});

/// Summary statistics.
final gstSummaryProvider = Provider<GstSummary>((ref) {
  final clients = ref.watch(gstClientsProvider);
  final returns = ref.watch(gstFilteredReturnsProvider);
  final now = DateTime(2026, 3, 10);

  final totalGstins = clients.length;
  final returnsDue = returns
      .where((r) => r.status == GstReturnStatus.pending)
      .length;
  final filedThisMonth = returns
      .where(
        (r) =>
            r.status == GstReturnStatus.filed &&
            r.filedDate != null &&
            r.filedDate!.month == now.month &&
            r.filedDate!.year == now.year,
      )
      .length;
  final overdue = returns
      .where(
        (r) => r.status == GstReturnStatus.pending && r.dueDate.isBefore(now),
      )
      .length;

  return GstSummary(
    totalGstins: totalGstins,
    returnsDue: returnsDue,
    filedThisMonth: filedThisMonth,
    overdue: overdue,
  );
});

/// Simple immutable summary data class.
class GstSummary {
  const GstSummary({
    required this.totalGstins,
    required this.returnsDue,
    required this.filedThisMonth,
    required this.overdue,
  });

  final int totalGstins;
  final int returnsDue;
  final int filedThisMonth;
  final int overdue;
}

// ---------------------------------------------------------------------------
// ITC Reconciliation mock data
// ---------------------------------------------------------------------------

final List<ItcReconciliation> _mockItcReconciliations = [
  const ItcReconciliation(
    id: 'itc-001',
    clientId: 'gst-001',
    gstin: '27AABCR1718E1ZL',
    period: 'Feb 2026',
    gstr2aItc: 845000,
    booksItc: 862000,
    matchedItc: 830000,
    mismatchedItc: 15000,
    missingInBooks: 0,
    missingIn2A: 17000,
    status: 'In Progress',
  ),
  const ItcReconciliation(
    id: 'itc-002',
    clientId: 'gst-002',
    gstin: '27AABCT1234F1ZP',
    period: 'Feb 2026',
    gstr2aItc: 1230000,
    booksItc: 1228000,
    matchedItc: 1220000,
    mismatchedItc: 8000,
    missingInBooks: 2000,
    missingIn2A: 0,
    status: 'Reconciled',
  ),
  const ItcReconciliation(
    id: 'itc-003',
    clientId: 'gst-003',
    gstin: '09AAFFS5678G1Z3',
    period: 'Feb 2026',
    gstr2aItc: 120000,
    booksItc: 145000,
    matchedItc: 110000,
    mismatchedItc: 25000,
    missingInBooks: 10000,
    missingIn2A: 25000,
    status: 'Escalated',
  ),
  const ItcReconciliation(
    id: 'itc-004',
    clientId: 'gst-004',
    gstin: '29AABCI5678H1ZK',
    period: 'Feb 2026',
    gstr2aItc: 1560000,
    booksItc: 1555000,
    matchedItc: 1548000,
    mismatchedItc: 7000,
    missingInBooks: 5000,
    missingIn2A: 0,
    status: 'Reconciled',
  ),
  const ItcReconciliation(
    id: 'itc-005',
    clientId: 'gst-005',
    gstin: '24AABPP9012J1Z7',
    period: 'Feb 2026',
    gstr2aItc: 340000,
    booksItc: 365000,
    matchedItc: 325000,
    mismatchedItc: 25000,
    missingInBooks: 15000,
    missingIn2A: 25000,
    status: 'Pending',
  ),
  const ItcReconciliation(
    id: 'itc-006',
    clientId: 'gst-006',
    gstin: '33AABCC3456K1ZQ',
    period: 'Feb 2026',
    gstr2aItc: 95000,
    booksItc: 110000,
    matchedItc: 88000,
    mismatchedItc: 12000,
    missingInBooks: 7000,
    missingIn2A: 15000,
    status: 'In Progress',
  ),
  const ItcReconciliation(
    id: 'itc-007',
    clientId: 'gst-007',
    gstin: '08AABCR7890L1Z2',
    period: 'Feb 2026',
    gstr2aItc: 480000,
    booksItc: 482000,
    matchedItc: 478000,
    mismatchedItc: 4000,
    missingInBooks: 2000,
    missingIn2A: 0,
    status: 'Reconciled',
  ),
  const ItcReconciliation(
    id: 'itc-008',
    clientId: 'gst-008',
    gstin: '07AABCD4567M1ZX',
    period: 'Feb 2026',
    gstr2aItc: 275000,
    booksItc: 310000,
    matchedItc: 260000,
    mismatchedItc: 35000,
    missingInBooks: 15000,
    missingIn2A: 35000,
    status: 'Pending',
  ),
];

// ---------------------------------------------------------------------------
// ITC Reconciliation providers
// ---------------------------------------------------------------------------

/// All ITC reconciliation records.
final allItcReconciliationsProvider = Provider<List<ItcReconciliation>>(
  (_) => List.unmodifiable(_mockItcReconciliations),
);

/// ITC reconciliation record for a specific client.
final itcReconForClientProvider = Provider.family<ItcReconciliation?, String>((
  ref,
  clientId,
) {
  final recs = ref.watch(allItcReconciliationsProvider);
  try {
    return recs.firstWhere((r) => r.clientId == clientId);
  } catch (_) {
    return null;
  }
});

/// Aggregate ITC reconciliation summary across all clients.
final itcReconSummaryProvider = Provider<ItcReconSummary>((ref) {
  final recs = ref.watch(allItcReconciliationsProvider);
  final totalMismatch = recs.fold(0.0, (sum, r) => sum + r.mismatchedItc);
  final reconciled = recs.where((r) => r.status == 'Reconciled').length;
  final escalated = recs.where((r) => r.status == 'Escalated').length;
  return ItcReconSummary(
    totalMismatch: totalMismatch,
    reconciled: reconciled,
    escalated: escalated,
    total: recs.length,
  );
});

/// Immutable summary of ITC reconciliation across all clients.
class ItcReconSummary {
  const ItcReconSummary({
    required this.totalMismatch,
    required this.reconciled,
    required this.escalated,
    required this.total,
  });

  final double totalMismatch;
  final int reconciled;
  final int escalated;
  final int total;
}

// ---------------------------------------------------------------------------
// Late fees calculator
// ---------------------------------------------------------------------------

/// Stateless utility for computing GST late fees and interest.
class LateFeesCalculator {
  LateFeesCalculator._();

  /// GSTR-3B late fee: ₹50/day (₹25 CGST + ₹25 SGST), max ₹10,000.
  /// For nil returns: ₹20/day (₹10 CGST + ₹10 SGST), max ₹500.
  /// Other return types follow the same ₹50/day rule.
  static double calculateLateFee({
    required int daysLate,
    required bool isNilReturn,
    required GstReturnType returnType,
  }) {
    if (daysLate <= 0) {
      return 0;
    }
    if (isNilReturn) {
      return (daysLate * 20).clamp(0, 500).toDouble();
    }
    return (daysLate * 50).clamp(0, 10000).toDouble();
  }

  /// Interest on late tax payment: 18% per annum on outstanding tax due.
  static double calculateInterest({
    required double taxDue,
    required int daysLate,
  }) {
    if (daysLate <= 0 || taxDue <= 0) {
      return 0;
    }
    return taxDue * 0.18 / 365 * daysLate;
  }
}
