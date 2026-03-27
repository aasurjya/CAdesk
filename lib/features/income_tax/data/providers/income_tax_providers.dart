import 'dart:math' show min;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

// ---------------------------------------------------------------------------
// Filter state providers
// ---------------------------------------------------------------------------

/// Currently selected ITR type filter (null = show all).
final itrTypeFilterProvider = NotifierProvider<ItrTypeFilterNotifier, ItrType?>(
  ItrTypeFilterNotifier.new,
);

class ItrTypeFilterNotifier extends Notifier<ItrType?> {
  @override
  ItrType? build() => null;

  void update(ItrType? value) => state = value;
}

/// Search query entered by the user.
final itrSearchQueryProvider = NotifierProvider<ItrSearchQueryNotifier, String>(
  ItrSearchQueryNotifier.new,
);

class ItrSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Currently selected assessment year.
final assessmentYearProvider = NotifierProvider<AssessmentYearNotifier, String>(
  AssessmentYearNotifier.new,
);

class AssessmentYearNotifier extends Notifier<String> {
  @override
  String build() => 'AY 2026-27';

  void update(String value) => state = value;
}

// ---------------------------------------------------------------------------
// Core data provider
// ---------------------------------------------------------------------------

final itrClientsProvider =
    NotifierProvider<ItrClientsNotifier, List<ItrClient>>(
      ItrClientsNotifier.new,
    );

class ItrClientsNotifier extends Notifier<List<ItrClient>> {
  @override
  List<ItrClient> build() => _mockClients;

  void add(ItrClient client) {
    state = [...state, client];
  }

  void updateClient(ItrClient updated) {
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
  }

  void remove(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

// ---------------------------------------------------------------------------
// Derived / filtered providers
// ---------------------------------------------------------------------------

final filteredClientsProvider = Provider<List<ItrClient>>((ref) {
  final clients = ref.watch(itrClientsProvider);
  final typeFilter = ref.watch(itrTypeFilterProvider);
  final query = ref.watch(itrSearchQueryProvider).toLowerCase().trim();
  final ay = ref.watch(assessmentYearProvider);

  return clients.where((c) {
    if (c.assessmentYear != ay) return false;
    if (typeFilter != null && c.itrType != typeFilter) return false;
    if (query.isNotEmpty) {
      final haystack = '${c.name} ${c.pan} ${c.maskedPan}'.toLowerCase();
      if (!haystack.contains(query)) return false;
    }
    return true;
  }).toList();
});

/// Summary counts for the dashboard cards.
final itrSummaryProvider = Provider<ItrSummary>((ref) {
  final clients = ref.watch(filteredClientsProvider);

  final total = clients.length;
  final filed = clients
      .where(
        (c) =>
            c.filingStatus == FilingStatus.filed ||
            c.filingStatus == FilingStatus.verified ||
            c.filingStatus == FilingStatus.processed,
      )
      .length;
  final pending = clients
      .where(
        (c) =>
            c.filingStatus == FilingStatus.pending ||
            c.filingStatus == FilingStatus.inProgress,
      )
      .length;

  // Overdue: pending/inProgress and past the typical July 31 deadline.
  final now = DateTime.now();
  const deadlineMonth = 7;
  const deadlineDay = 31;
  final deadline = DateTime(now.year, deadlineMonth, deadlineDay);
  final overdue = clients
      .where(
        (c) =>
            (c.filingStatus == FilingStatus.pending ||
                c.filingStatus == FilingStatus.inProgress) &&
            now.isAfter(deadline),
      )
      .length;

  return ItrSummary(
    total: total,
    filed: filed,
    pending: pending,
    overdue: overdue,
  );
});

/// Value object holding summary counts.
class ItrSummary {
  const ItrSummary({
    required this.total,
    required this.filed,
    required this.pending,
    required this.overdue,
  });

  final int total;
  final int filed;
  final int pending;
  final int overdue;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockClients = <ItrClient>[
  ItrClient(
    id: '1',
    name: 'Rajesh Kumar Sharma',
    pan: 'ABCPS1234K',
    aadhaar: '9876 5432 1098',
    email: 'rajesh.sharma@email.com',
    phone: '+91 98765 43210',
    itrType: ItrType.itr1,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.filed,
    totalIncome: 850000,
    taxPayable: 32500,
    refundDue: 0,
    filedDate: DateTime(2025, 7, 15),
    acknowledgementNumber: 'ACK2025071500001',
  ),
  ItrClient(
    id: '2',
    name: 'Priya Nair',
    pan: 'BKNPN5678L',
    aadhaar: '8765 4321 0987',
    email: 'priya.nair@email.com',
    phone: '+91 87654 32109',
    itrType: ItrType.itr2,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.verified,
    totalIncome: 2450000,
    taxPayable: 375000,
    refundDue: 12000,
    filedDate: DateTime(2025, 7, 20),
    acknowledgementNumber: 'ACK2025072000002',
  ),
  const ItrClient(
    id: '3',
    name: 'Amit Patel',
    pan: 'CFGPP9012M',
    aadhaar: '7654 3210 9876',
    email: 'amit.patel@email.com',
    phone: '+91 76543 21098',
    itrType: ItrType.itr3,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.pending,
    totalIncome: 4200000,
    taxPayable: 825000,
    refundDue: 0,
  ),
  ItrClient(
    id: '4',
    name: 'Sunita Deshmukh',
    pan: 'DHMPD3456N',
    aadhaar: '6543 2109 8765',
    email: 'sunita.d@email.com',
    phone: '+91 65432 10987',
    itrType: ItrType.itr4,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.processed,
    totalIncome: 1200000,
    taxPayable: 117000,
    refundDue: 5400,
    filedDate: DateTime(2025, 6, 28),
    acknowledgementNumber: 'ACK2025062800004',
  ),
  const ItrClient(
    id: '5',
    name: 'Vikram Singh Rathore',
    pan: 'EKRPV7890P',
    aadhaar: '5432 1098 7654',
    email: 'vikram.rathore@email.com',
    phone: '+91 54321 09876',
    itrType: ItrType.itr1,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.inProgress,
    totalIncome: 720000,
    taxPayable: 22100,
    refundDue: 0,
  ),
  ItrClient(
    id: '6',
    name: 'Meera Joshi',
    pan: 'FLJPM2345Q',
    aadhaar: '4321 0987 6543',
    email: 'meera.joshi@email.com',
    phone: '+91 43210 98765',
    itrType: ItrType.itr2,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.filed,
    totalIncome: 3100000,
    taxPayable: 520000,
    refundDue: 18500,
    filedDate: DateTime(2025, 7, 25),
    acknowledgementNumber: 'ACK2025072500006',
  ),
  ItrClient(
    id: '7',
    name: 'Arjun Mehta',
    pan: 'GNTPA6789R',
    aadhaar: '3210 9876 5432',
    email: 'arjun.mehta@email.com',
    phone: '+91 32109 87654',
    itrType: ItrType.itr3,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.defective,
    totalIncome: 5600000,
    taxPayable: 1175000,
    refundDue: 0,
    filedDate: DateTime(2025, 7, 10),
    acknowledgementNumber: 'ACK2025071000007',
  ),
  const ItrClient(
    id: '8',
    name: 'Deepika Iyer',
    pan: 'HQIPD1234S',
    aadhaar: '2109 8765 4321',
    email: 'deepika.iyer@email.com',
    phone: '+91 21098 76543',
    itrType: ItrType.itr1,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.pending,
    totalIncome: 680000,
    taxPayable: 18200,
    refundDue: 0,
  ),
  ItrClient(
    id: '9',
    name: 'Karan Malhotra',
    pan: 'JRKPK5678T',
    aadhaar: '1098 7654 3210',
    email: 'karan.malhotra@email.com',
    phone: '+91 10987 65432',
    itrType: ItrType.itr4,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.filed,
    totalIncome: 1550000,
    taxPayable: 167000,
    refundDue: 8200,
    filedDate: DateTime(2025, 7, 30),
    acknowledgementNumber: 'ACK2025073000009',
  ),
  ItrClient(
    id: '10',
    name: 'Neha Gupta',
    pan: 'KLGPN9012U',
    aadhaar: '0987 6543 2109',
    email: 'neha.gupta@email.com',
    phone: '+91 09876 54321',
    itrType: ItrType.itr1,
    assessmentYear: 'AY 2026-27',
    filingStatus: FilingStatus.verified,
    totalIncome: 950000,
    taxPayable: 52500,
    refundDue: 3200,
    filedDate: DateTime(2025, 7, 18),
    acknowledgementNumber: 'ACK2025071800010',
  ),
];

// ---------------------------------------------------------------------------
// Tax regime comparison model
// ---------------------------------------------------------------------------

/// Old vs New regime tax computation for a given income.
class TaxRegimeComparison {
  const TaxRegimeComparison({
    required this.grossIncome,
    required this.oldRegimeTax,
    required this.newRegimeTax,
    required this.oldRegimeDeductions,
    required this.newRegimeDeductions,
    required this.savings,
    required this.recommendedRegime,
  });

  final double grossIncome;

  /// Tax liability under the old regime.
  final double oldRegimeTax;

  /// Tax liability under the new regime.
  final double newRegimeTax;

  /// Total deductions available under old regime (80C + 80D + HRA + standard).
  final double oldRegimeDeductions;

  /// Standard deduction available under new regime.
  final double newRegimeDeductions;

  /// Absolute difference between old and new regime tax.
  final double savings;

  /// Either 'Old' or 'New' — whichever results in lower tax.
  final String recommendedRegime;

  TaxRegimeComparison copyWith({
    double? grossIncome,
    double? oldRegimeTax,
    double? newRegimeTax,
    double? oldRegimeDeductions,
    double? newRegimeDeductions,
    double? savings,
    String? recommendedRegime,
  }) {
    return TaxRegimeComparison(
      grossIncome: grossIncome ?? this.grossIncome,
      oldRegimeTax: oldRegimeTax ?? this.oldRegimeTax,
      newRegimeTax: newRegimeTax ?? this.newRegimeTax,
      oldRegimeDeductions: oldRegimeDeductions ?? this.oldRegimeDeductions,
      newRegimeDeductions: newRegimeDeductions ?? this.newRegimeDeductions,
      savings: savings ?? this.savings,
      recommendedRegime: recommendedRegime ?? this.recommendedRegime,
    );
  }
}

// ---------------------------------------------------------------------------
// Tax computation service
// ---------------------------------------------------------------------------

/// Stateless service that computes income tax under old and new regimes
/// for FY 2025-26 / AY 2026-27.
class TaxComputationService {
  TaxComputationService._();

  /// New regime tax slabs FY 2025-26 (Finance Act 2025):
  /// 0–4L: Nil, 4L–8L: 5%, 8L–12L: 10%, 12L–16L: 15%,
  /// 16L–20L: 20%, 20L–24L: 25%, >24L: 30%
  /// Standard deduction: ₹75,000
  static double computeNewRegimeTax(double grossIncome) {
    final income = grossIncome - 75000; // standard deduction
    if (income <= 0) {
      return 0;
    }
    double tax = 0;
    if (income > 2400000) {
      tax += (income - 2400000) * 0.30;
    }
    if (income > 2000000) {
      tax += (min(income, 2400000) - 2000000) * 0.25;
    }
    if (income > 1600000) {
      tax += (min(income, 2000000) - 1600000) * 0.20;
    }
    if (income > 1200000) {
      tax += (min(income, 1600000) - 1200000) * 0.15;
    }
    if (income > 800000) {
      tax += (min(income, 1200000) - 800000) * 0.10;
    }
    if (income > 400000) {
      tax += (min(income, 800000) - 400000) * 0.05;
    }
    // Add 4% health & education cess
    return tax * 1.04;
  }

  /// Old regime tax slabs:
  /// 0–2.5L: Nil, 2.5L–5L: 5%, 5L–10L: 20%, >10L: 30%
  /// Assumed deductions: 80C=1.5L, 80D=25K, HRA=1.5L, standard=50K (total 3.75L)
  static double computeOldRegimeTax(double grossIncome) {
    const deductions = 150000.0 + 25000.0 + 150000.0 + 50000.0; // 3.75L
    final income = (grossIncome - deductions).clamp(0.0, double.infinity);
    double tax = 0;
    if (income > 1000000) {
      tax += (income - 1000000) * 0.30;
    }
    if (income > 500000) {
      tax += (min(income, 1000000) - 500000) * 0.20;
    }
    if (income > 250000) {
      tax += (min(income, 500000) - 250000) * 0.05;
    }
    // Add 4% health & education cess
    return tax * 1.04;
  }

  /// Compares old vs new regime for a given gross income and returns a
  /// [TaxRegimeComparison] with a recommendation.
  static TaxRegimeComparison compare(double grossIncome) {
    final oldTax = computeOldRegimeTax(grossIncome);
    final newTax = computeNewRegimeTax(grossIncome);
    return TaxRegimeComparison(
      grossIncome: grossIncome,
      oldRegimeTax: oldTax,
      newRegimeTax: newTax,
      oldRegimeDeductions: 375000,
      newRegimeDeductions: 75000,
      savings: (oldTax - newTax).abs(),
      recommendedRegime: newTax <= oldTax ? 'New' : 'Old',
    );
  }
}
