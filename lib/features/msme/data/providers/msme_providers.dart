import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/msme/domain/models/msme_payment.dart';
import 'package:ca_app/features/msme/domain/models/msme_vendor.dart';

// ---------------------------------------------------------------------------
// MsmePaymentCalculator — Section 43B(h) business logic
// ---------------------------------------------------------------------------

/// Stateless calculator for MSME 45-day payment rule enforcement.
///
/// Section 43B(h): Payment to MSME suppliers must be made within 45 days
/// (or as per agreed terms, max 45 days). Unpaid amounts beyond the limit
/// are DISALLOWED in the year of accrual; allowed only in the year of actual
/// payment.
class MsmePaymentCalculator {
  MsmePaymentCalculator._();

  /// Determines if a payment is overdue under MSME rules.
  static bool isOverdue(int daysSinceInvoice, {int agreedDays = 45}) {
    return daysSinceInvoice > agreedDays.clamp(0, 45);
  }

  /// Computes disallowable amount under 43B(h).
  ///
  /// If outstanding beyond the effective days at year end (March 31), the
  /// full outstanding amount is disallowed.
  static double disallowableAmount43Bh({
    required double outstandingAmount,
    required int daysOutstanding,
    required int agreedTermDays,
  }) {
    final effectiveDays = agreedTermDays.clamp(0, 45);
    if (daysOutstanding > effectiveDays) {
      return outstandingAmount;
    }
    return 0;
  }

  /// Interest on delayed payment to MSME = 3× bank rate (RBI).
  ///
  /// Current bank rate: 6.25% → delayed payment interest = 18.75% p.a.
  static double delayedPaymentInterest({
    required double amount,
    required int daysDelayed,
    required double bankRatePercent,
  }) {
    if (daysDelayed <= 0) {
      return 0;
    }
    final rate = bankRatePercent * 3 / 100;
    return amount * rate * daysDelayed / 365;
  }

  /// Form MSME-1 due dates.
  ///
  /// For payments due but unpaid beyond 45 days:
  /// - Half year ending Sep 30: due Oct 31
  /// - Half year ending Mar 31: due Apr 30
  static String formMsme1DueDate({required bool isMarchHalf}) {
    return isMarchHalf ? '30 Apr' : '31 Oct';
  }
}

// ---------------------------------------------------------------------------
// MsmeSupplierPayment model
// ---------------------------------------------------------------------------

/// Immutable model representing a supplier payment record for 43B(h) tracking.
class MsmeSupplierPayment {
  const MsmeSupplierPayment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.supplierName,
    required this.supplierUdyam,
    required this.supplierCategory,
    required this.invoiceDate,
    required this.invoiceAmount,
    required this.daysOutstanding,
    required this.agreedTermDays,
    required this.isPaid,
    this.paidDate,
    required this.financialYear,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String supplierName;
  final String supplierUdyam;
  final MsmeClassification supplierCategory;
  final String invoiceDate;
  final double invoiceAmount;
  final int daysOutstanding;
  final int agreedTermDays;
  final bool isPaid;
  final String? paidDate;
  final String financialYear;

  bool get isOverdue => MsmePaymentCalculator.isOverdue(
    daysOutstanding,
    agreedDays: agreedTermDays,
  );

  double get disallowableAmount => MsmePaymentCalculator.disallowableAmount43Bh(
    outstandingAmount: invoiceAmount,
    daysOutstanding: daysOutstanding,
    agreedTermDays: agreedTermDays,
  );

  double get interestLiability => MsmePaymentCalculator.delayedPaymentInterest(
    amount: invoiceAmount,
    daysDelayed: (daysOutstanding - agreedTermDays).clamp(0, 365),
    bankRatePercent: 6.25,
  );

  MsmeSupplierPayment copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? supplierName,
    String? supplierUdyam,
    MsmeClassification? supplierCategory,
    String? invoiceDate,
    double? invoiceAmount,
    int? daysOutstanding,
    int? agreedTermDays,
    bool? isPaid,
    String? paidDate,
    String? financialYear,
  }) {
    return MsmeSupplierPayment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      supplierName: supplierName ?? this.supplierName,
      supplierUdyam: supplierUdyam ?? this.supplierUdyam,
      supplierCategory: supplierCategory ?? this.supplierCategory,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      daysOutstanding: daysOutstanding ?? this.daysOutstanding,
      agreedTermDays: agreedTermDays ?? this.agreedTermDays,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      financialYear: financialYear ?? this.financialYear,
    );
  }
}

// ---------------------------------------------------------------------------
// Msme43BhSummary value object
// ---------------------------------------------------------------------------

/// Aggregated 43B(h) impact metrics.
class Msme43BhSummary {
  const Msme43BhSummary({
    required this.totalOutstanding,
    required this.totalDisallowable,
    required this.totalInterest,
    required this.overdueCount,
  });

  final double totalOutstanding;
  final double totalDisallowable;
  final double totalInterest;
  final int overdueCount;
}

// ---------------------------------------------------------------------------
// Supplier payment providers
// ---------------------------------------------------------------------------

final allMsmePaymentsProvider = Provider<List<MsmeSupplierPayment>>(
  (ref) => _mockMsmePayments,
);

final msme43BhSummaryProvider = Provider<Msme43BhSummary>((ref) {
  final payments = ref.watch(allMsmePaymentsProvider);
  final totalOutstanding = payments
      .where((p) => !p.isPaid)
      .fold(0.0, (s, p) => s + p.invoiceAmount);
  final totalDisallowable = payments.fold(
    0.0,
    (s, p) => s + p.disallowableAmount,
  );
  final totalInterest = payments.fold(0.0, (s, p) => s + p.interestLiability);
  final overdueCount = payments.where((p) => p.isOverdue && !p.isPaid).length;
  return Msme43BhSummary(
    totalOutstanding: totalOutstanding,
    totalDisallowable: totalDisallowable,
    totalInterest: totalInterest,
    overdueCount: overdueCount,
  );
});

/// Returns supplier payments filtered to a specific client.
final msmePaymentsByClientProvider =
    Provider.family<List<MsmeSupplierPayment>, String>((ref, clientId) {
      final payments = ref.watch(allMsmePaymentsProvider);
      return payments.where((p) => p.clientId == clientId).toList();
    });

// ---------------------------------------------------------------------------
// Mock supplier payment data — 12 payments across 4 clients
// ---------------------------------------------------------------------------

final _mockMsmePayments = <MsmeSupplierPayment>[
  // Client c1 — Arjun Enterprises
  MsmeSupplierPayment(
    id: 'sp1',
    clientId: 'c1',
    clientName: 'Arjun Enterprises Pvt Ltd',
    supplierName: 'Bharat Precision Tools Pvt Ltd',
    supplierUdyam: 'UDYAM-MH-01-0012345',
    supplierCategory: MsmeClassification.micro,
    invoiceDate: '10 Nov 2025',
    invoiceAmount: 245000,
    daysOutstanding: 121,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  MsmeSupplierPayment(
    id: 'sp2',
    clientId: 'c1',
    clientName: 'Arjun Enterprises Pvt Ltd',
    supplierName: 'Sharma & Sons Engineering Works',
    supplierUdyam: 'UDYAM-RJ-02-0098765',
    supplierCategory: MsmeClassification.small,
    invoiceDate: '05 Dec 2025',
    invoiceAmount: 580000,
    daysOutstanding: 96,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  MsmeSupplierPayment(
    id: 'sp3',
    clientId: 'c1',
    clientName: 'Arjun Enterprises Pvt Ltd',
    supplierName: 'Sharma & Sons Engineering Works',
    supplierUdyam: 'UDYAM-RJ-02-0098765',
    supplierCategory: MsmeClassification.small,
    invoiceDate: '05 Oct 2025',
    invoiceAmount: 310000,
    daysOutstanding: 66,
    agreedTermDays: 45,
    isPaid: true,
    paidDate: '10 Dec 2025',
    financialYear: '2025-26',
  ),
  // Client c2 — Sunrise Industries
  MsmeSupplierPayment(
    id: 'sp4',
    clientId: 'c2',
    clientName: 'Sunrise Industries Ltd',
    supplierName: 'Gurukrupa Chemicals',
    supplierUdyam: 'UDYAM-GJ-03-0045678',
    supplierCategory: MsmeClassification.medium,
    invoiceDate: '15 Jan 2026',
    invoiceAmount: 120000,
    daysOutstanding: 55,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  MsmeSupplierPayment(
    id: 'sp5',
    clientId: 'c2',
    clientName: 'Sunrise Industries Ltd',
    supplierName: 'Patel Textile Industries',
    supplierUdyam: 'UDYAM-GJ-04-0067890',
    supplierCategory: MsmeClassification.small,
    invoiceDate: '25 Oct 2025',
    invoiceAmount: 375000,
    daysOutstanding: 137,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  MsmeSupplierPayment(
    id: 'sp6',
    clientId: 'c2',
    clientName: 'Sunrise Industries Ltd',
    supplierName: 'Patel Textile Industries',
    supplierUdyam: 'UDYAM-GJ-04-0067890',
    supplierCategory: MsmeClassification.small,
    invoiceDate: '15 Aug 2025',
    invoiceAmount: 200000,
    daysOutstanding: 76,
    agreedTermDays: 45,
    isPaid: true,
    paidDate: '30 Oct 2025',
    financialYear: '2025-26',
  ),
  // Client c3 — Deccan Traders
  MsmeSupplierPayment(
    id: 'sp7',
    clientId: 'c3',
    clientName: 'Deccan Traders Co',
    supplierName: 'Lakshmi Auto Components',
    supplierUdyam: 'UDYAM-TN-05-0023456',
    supplierCategory: MsmeClassification.micro,
    invoiceDate: '28 Jan 2026',
    invoiceAmount: 89000,
    daysOutstanding: 42,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  MsmeSupplierPayment(
    id: 'sp8',
    clientId: 'c3',
    clientName: 'Deccan Traders Co',
    supplierName: 'Deccan Rubber Products',
    supplierUdyam: 'UDYAM-KA-06-0034567',
    supplierCategory: MsmeClassification.medium,
    invoiceDate: '15 Nov 2025',
    invoiceAmount: 142000,
    daysOutstanding: 43,
    agreedTermDays: 45,
    isPaid: true,
    paidDate: '28 Dec 2025',
    financialYear: '2025-26',
  ),
  // Client c4 — Northern Metals
  MsmeSupplierPayment(
    id: 'sp9',
    clientId: 'c4',
    clientName: 'Northern Metals Pvt Ltd',
    supplierName: 'Hindustan Fasteners Ltd',
    supplierUdyam: 'UDYAM-PB-07-0056789',
    supplierCategory: MsmeClassification.small,
    invoiceDate: '20 Nov 2025',
    invoiceAmount: 450000,
    daysOutstanding: 111,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  MsmeSupplierPayment(
    id: 'sp10',
    clientId: 'c4',
    clientName: 'Northern Metals Pvt Ltd',
    supplierName: 'Narmada Packaging Solutions',
    supplierUdyam: 'UDYAM-MP-08-0078901',
    supplierCategory: MsmeClassification.micro,
    invoiceDate: '01 Feb 2026',
    invoiceAmount: 67000,
    daysOutstanding: 38,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  // Client c5 — Sagar Tech (overdue + paid)
  MsmeSupplierPayment(
    id: 'sp11',
    clientId: 'c5',
    clientName: 'Sagar Technologies',
    supplierName: 'Sagar IT Services',
    supplierUdyam: 'UDYAM-MH-09-0089012',
    supplierCategory: MsmeClassification.small,
    invoiceDate: '18 Dec 2025',
    invoiceAmount: 210000,
    daysOutstanding: 83,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
  MsmeSupplierPayment(
    id: 'sp12',
    clientId: 'c5',
    clientName: 'Sagar Technologies',
    supplierName: 'Jaipur Handicrafts Co-op',
    supplierUdyam: 'UDYAM-RJ-10-0090123',
    supplierCategory: MsmeClassification.micro,
    invoiceDate: '15 Feb 2026',
    invoiceAmount: 34000,
    daysOutstanding: 24,
    agreedTermDays: 45,
    isPaid: false,
    financialYear: '2025-26',
  ),
];

// ---------------------------------------------------------------------------
// Filter notifiers
// ---------------------------------------------------------------------------

/// Filter by MSME classification (null = show all).
final msmeClassificationFilterProvider =
    NotifierProvider<MsmeClassificationFilterNotifier, MsmeClassification?>(
      MsmeClassificationFilterNotifier.new,
    );

class MsmeClassificationFilterNotifier extends Notifier<MsmeClassification?> {
  @override
  MsmeClassification? build() => null;

  void update(MsmeClassification? value) => state = value;
}

/// Filter by payment status (null = show all).
final msmePaymentStatusFilterProvider =
    NotifierProvider<MsmePaymentStatusFilterNotifier, MsmePaymentStatus?>(
      MsmePaymentStatusFilterNotifier.new,
    );

class MsmePaymentStatusFilterNotifier extends Notifier<MsmePaymentStatus?> {
  @override
  MsmePaymentStatus? build() => null;

  void update(MsmePaymentStatus? value) => state = value;
}

/// Toggle to show only 43B(h) at-risk vendors.
final msme43BhOnlyProvider = NotifierProvider<Msme43BhOnlyNotifier, bool>(
  Msme43BhOnlyNotifier.new,
);

class Msme43BhOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void update(bool value) => state = value;
}

// ---------------------------------------------------------------------------
// Core data providers
// ---------------------------------------------------------------------------

final msmeVendorsProvider =
    NotifierProvider<MsmeVendorsNotifier, List<MsmeVendor>>(
      MsmeVendorsNotifier.new,
    );

class MsmeVendorsNotifier extends Notifier<List<MsmeVendor>> {
  @override
  List<MsmeVendor> build() => _mockVendors;

  void add(MsmeVendor vendor) {
    state = [...state, vendor];
  }

  void updateVendor(MsmeVendor updated) {
    state = [
      for (final v in state)
        if (v.id == updated.id) updated else v,
    ];
  }
}

final msmePaymentsProvider =
    NotifierProvider<MsmePaymentsNotifier, List<MsmePayment>>(
      MsmePaymentsNotifier.new,
    );

class MsmePaymentsNotifier extends Notifier<List<MsmePayment>> {
  @override
  List<MsmePayment> build() => _mockPayments;

  void add(MsmePayment payment) {
    state = [...state, payment];
  }

  void updatePayment(MsmePayment updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }
}

// ---------------------------------------------------------------------------
// Derived / filtered providers
// ---------------------------------------------------------------------------

final filteredMsmeVendorsProvider = Provider<List<MsmeVendor>>((ref) {
  final vendors = ref.watch(msmeVendorsProvider);
  final classification = ref.watch(msmeClassificationFilterProvider);
  final onlyAtRisk = ref.watch(msme43BhOnlyProvider);

  return vendors.where((v) {
    if (classification != null && v.classification != classification) {
      return false;
    }
    if (onlyAtRisk && !v.section43BhAtRisk) return false;
    return true;
  }).toList();
});

final filteredMsmePaymentsProvider = Provider<List<MsmePayment>>((ref) {
  final payments = ref.watch(msmePaymentsProvider);
  final statusFilter = ref.watch(msmePaymentStatusFilterProvider);

  return payments.where((p) {
    if (statusFilter != null && p.status != statusFilter) return false;
    return true;
  }).toList();
});

/// Vendors flagged for Section 43B(h) deduction risk.
final section43BhAlertsProvider = Provider<List<MsmeVendor>>((ref) {
  final vendors = ref.watch(msmeVendorsProvider);
  return vendors.where((v) => v.section43BhAtRisk).toList();
});

/// Summary metrics for the MSME dashboard.
final msmeSummaryProvider = Provider<MsmeSummary>((ref) {
  final vendors = ref.watch(msmeVendorsProvider);
  final payments = ref.watch(msmePaymentsProvider);

  final totalOutstanding = vendors.fold<double>(
    0,
    (sum, v) => sum + v.outstandingAmount,
  );
  final atRiskCount = vendors.where((v) => v.section43BhAtRisk).length;
  final overduePayments = payments
      .where((p) => p.status == MsmePaymentStatus.overdue)
      .length;
  final latePayments = payments
      .where((p) => p.status == MsmePaymentStatus.paidLate)
      .length;

  return MsmeSummary(
    totalVendors: vendors.length,
    totalOutstanding: totalOutstanding,
    atRiskDeductions: atRiskCount,
    overduePayments: overduePayments,
    latePayments: latePayments,
  );
});

/// Value object for MSME summary metrics.
class MsmeSummary {
  const MsmeSummary({
    required this.totalVendors,
    required this.totalOutstanding,
    required this.atRiskDeductions,
    required this.overduePayments,
    required this.latePayments,
  });

  final int totalVendors;
  final double totalOutstanding;
  final int atRiskDeductions;
  final int overduePayments;
  final int latePayments;
}

// ---------------------------------------------------------------------------
// Mock data - 10 vendors
// ---------------------------------------------------------------------------

final _mockVendors = <MsmeVendor>[
  MsmeVendor(
    id: 'mv1',
    clientId: 'c1',
    vendorName: 'Bharat Precision Tools Pvt Ltd',
    msmeRegistrationNumber: 'UDYAM-MH-01-0012345',
    classification: MsmeClassification.micro,
    registeredDate: DateTime(2022, 3, 15),
    isVerified: true,
    outstandingAmount: 245000,
    oldestInvoiceDate: DateTime(2025, 11, 10),
    daysPastDue: 62,
    section43BhAtRisk: true,
  ),
  MsmeVendor(
    id: 'mv2',
    clientId: 'c1',
    vendorName: 'Sharma & Sons Engineering Works',
    msmeRegistrationNumber: 'UDYAM-RJ-02-0098765',
    classification: MsmeClassification.small,
    registeredDate: DateTime(2021, 7, 20),
    isVerified: true,
    outstandingAmount: 580000,
    oldestInvoiceDate: DateTime(2025, 12, 5),
    daysPastDue: 50,
    section43BhAtRisk: true,
  ),
  MsmeVendor(
    id: 'mv3',
    clientId: 'c2',
    vendorName: 'Gurukrupa Chemicals',
    msmeRegistrationNumber: 'UDYAM-GJ-03-0045678',
    classification: MsmeClassification.medium,
    registeredDate: DateTime(2020, 1, 10),
    isVerified: true,
    outstandingAmount: 120000,
    oldestInvoiceDate: DateTime(2026, 1, 15),
    daysPastDue: 20,
    section43BhAtRisk: false,
  ),
  MsmeVendor(
    id: 'mv4',
    clientId: 'c2',
    vendorName: 'Patel Textile Industries',
    msmeRegistrationNumber: 'UDYAM-GJ-04-0067890',
    classification: MsmeClassification.small,
    registeredDate: DateTime(2023, 5, 8),
    isVerified: true,
    outstandingAmount: 375000,
    oldestInvoiceDate: DateTime(2025, 10, 25),
    daysPastDue: 78,
    section43BhAtRisk: true,
  ),
  MsmeVendor(
    id: 'mv5',
    clientId: 'c3',
    vendorName: 'Lakshmi Auto Components',
    msmeRegistrationNumber: 'UDYAM-TN-05-0023456',
    classification: MsmeClassification.micro,
    registeredDate: DateTime(2022, 9, 1),
    isVerified: false,
    outstandingAmount: 89000,
    oldestInvoiceDate: DateTime(2026, 1, 28),
    daysPastDue: 10,
    section43BhAtRisk: false,
  ),
  MsmeVendor(
    id: 'mv6',
    clientId: 'c3',
    vendorName: 'Deccan Rubber Products',
    msmeRegistrationNumber: 'UDYAM-KA-06-0034567',
    classification: MsmeClassification.medium,
    registeredDate: DateTime(2019, 11, 22),
    isVerified: true,
    outstandingAmount: 0,
    daysPastDue: 0,
    section43BhAtRisk: false,
  ),
  MsmeVendor(
    id: 'mv7',
    clientId: 'c4',
    vendorName: 'Hindustan Fasteners Ltd',
    msmeRegistrationNumber: 'UDYAM-PB-07-0056789',
    classification: MsmeClassification.small,
    registeredDate: DateTime(2021, 4, 14),
    isVerified: true,
    outstandingAmount: 450000,
    oldestInvoiceDate: DateTime(2025, 11, 20),
    daysPastDue: 55,
    section43BhAtRisk: true,
  ),
  MsmeVendor(
    id: 'mv8',
    clientId: 'c4',
    vendorName: 'Narmada Packaging Solutions',
    msmeRegistrationNumber: 'UDYAM-MP-08-0078901',
    classification: MsmeClassification.micro,
    registeredDate: DateTime(2023, 2, 5),
    isVerified: true,
    outstandingAmount: 67000,
    oldestInvoiceDate: DateTime(2026, 2, 1),
    daysPastDue: 5,
    section43BhAtRisk: false,
  ),
  MsmeVendor(
    id: 'mv9',
    clientId: 'c5',
    vendorName: 'Sagar IT Services',
    msmeRegistrationNumber: 'UDYAM-MH-09-0089012',
    classification: MsmeClassification.small,
    registeredDate: DateTime(2020, 8, 30),
    isVerified: true,
    outstandingAmount: 210000,
    oldestInvoiceDate: DateTime(2025, 12, 18),
    daysPastDue: 48,
    section43BhAtRisk: true,
  ),
  MsmeVendor(
    id: 'mv10',
    clientId: 'c5',
    vendorName: 'Jaipur Handicrafts Co-op',
    msmeRegistrationNumber: 'UDYAM-RJ-10-0090123',
    classification: MsmeClassification.micro,
    registeredDate: DateTime(2024, 1, 12),
    isVerified: false,
    outstandingAmount: 34000,
    oldestInvoiceDate: DateTime(2026, 2, 15),
    daysPastDue: 0,
    section43BhAtRisk: false,
  ),
];

// ---------------------------------------------------------------------------
// Mock data - 20 payments
// ---------------------------------------------------------------------------

final _mockPayments = <MsmePayment>[
  MsmePayment(
    id: 'mp1',
    clientId: 'c1',
    vendorId: 'mv1',
    vendorName: 'Bharat Precision Tools Pvt Ltd',
    invoiceNumber: 'BPT/2025/001',
    invoiceDate: DateTime(2025, 9, 10),
    invoiceAmount: 125000,
    dueDate: DateTime(2025, 10, 25),
    paymentDate: DateTime(2025, 10, 20),
    daysToPay: 40,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.paidOnTime,
  ),
  MsmePayment(
    id: 'mp2',
    clientId: 'c1',
    vendorId: 'mv1',
    vendorName: 'Bharat Precision Tools Pvt Ltd',
    invoiceNumber: 'BPT/2025/002',
    invoiceDate: DateTime(2025, 11, 10),
    invoiceAmount: 245000,
    dueDate: DateTime(2025, 12, 25),
    daysToPay: 120,
    isWithin45Days: false,
    penaltyInterest: 8820,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp3',
    clientId: 'c1',
    vendorId: 'mv2',
    vendorName: 'Sharma & Sons Engineering Works',
    invoiceNumber: 'SSE/2025/045',
    invoiceDate: DateTime(2025, 10, 5),
    invoiceAmount: 310000,
    dueDate: DateTime(2025, 11, 19),
    paymentDate: DateTime(2025, 12, 10),
    daysToPay: 66,
    isWithin45Days: false,
    penaltyInterest: 5332,
    status: MsmePaymentStatus.paidLate,
  ),
  MsmePayment(
    id: 'mp4',
    clientId: 'c1',
    vendorId: 'mv2',
    vendorName: 'Sharma & Sons Engineering Works',
    invoiceNumber: 'SSE/2025/052',
    invoiceDate: DateTime(2025, 12, 5),
    invoiceAmount: 580000,
    dueDate: DateTime(2026, 1, 19),
    daysToPay: 95,
    isWithin45Days: false,
    penaltyInterest: 16530,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp5',
    clientId: 'c2',
    vendorId: 'mv3',
    vendorName: 'Gurukrupa Chemicals',
    invoiceNumber: 'GC/2026/010',
    invoiceDate: DateTime(2026, 1, 15),
    invoiceAmount: 120000,
    dueDate: DateTime(2026, 3, 1),
    daysToPay: 20,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp6',
    clientId: 'c2',
    vendorId: 'mv3',
    vendorName: 'Gurukrupa Chemicals',
    invoiceNumber: 'GC/2025/098',
    invoiceDate: DateTime(2025, 11, 1),
    invoiceAmount: 85000,
    dueDate: DateTime(2025, 12, 16),
    paymentDate: DateTime(2025, 12, 10),
    daysToPay: 39,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.paidOnTime,
  ),
  MsmePayment(
    id: 'mp7',
    clientId: 'c2',
    vendorId: 'mv4',
    vendorName: 'Patel Textile Industries',
    invoiceNumber: 'PTI/2025/078',
    invoiceDate: DateTime(2025, 10, 25),
    invoiceAmount: 375000,
    dueDate: DateTime(2025, 12, 9),
    daysToPay: 136,
    isWithin45Days: false,
    penaltyInterest: 15300,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp8',
    clientId: 'c2',
    vendorId: 'mv4',
    vendorName: 'Patel Textile Industries',
    invoiceNumber: 'PTI/2025/065',
    invoiceDate: DateTime(2025, 8, 15),
    invoiceAmount: 200000,
    dueDate: DateTime(2025, 9, 29),
    paymentDate: DateTime(2025, 10, 30),
    daysToPay: 76,
    isWithin45Days: false,
    penaltyInterest: 4100,
    status: MsmePaymentStatus.paidLate,
  ),
  MsmePayment(
    id: 'mp9',
    clientId: 'c3',
    vendorId: 'mv5',
    vendorName: 'Lakshmi Auto Components',
    invoiceNumber: 'LAC/2026/003',
    invoiceDate: DateTime(2026, 1, 28),
    invoiceAmount: 89000,
    dueDate: DateTime(2026, 3, 14),
    daysToPay: 10,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp10',
    clientId: 'c3',
    vendorId: 'mv5',
    vendorName: 'Lakshmi Auto Components',
    invoiceNumber: 'LAC/2025/089',
    invoiceDate: DateTime(2025, 12, 10),
    invoiceAmount: 56000,
    dueDate: DateTime(2026, 1, 24),
    paymentDate: DateTime(2026, 1, 20),
    daysToPay: 41,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.paidOnTime,
  ),
  MsmePayment(
    id: 'mp11',
    clientId: 'c3',
    vendorId: 'mv6',
    vendorName: 'Deccan Rubber Products',
    invoiceNumber: 'DRP/2025/112',
    invoiceDate: DateTime(2025, 11, 15),
    invoiceAmount: 142000,
    dueDate: DateTime(2025, 12, 30),
    paymentDate: DateTime(2025, 12, 28),
    daysToPay: 43,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.paidOnTime,
  ),
  MsmePayment(
    id: 'mp12',
    clientId: 'c4',
    vendorId: 'mv7',
    vendorName: 'Hindustan Fasteners Ltd',
    invoiceNumber: 'HFL/2025/034',
    invoiceDate: DateTime(2025, 11, 20),
    invoiceAmount: 450000,
    dueDate: DateTime(2026, 1, 4),
    daysToPay: 110,
    isWithin45Days: false,
    penaltyInterest: 14850,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp13',
    clientId: 'c4',
    vendorId: 'mv7',
    vendorName: 'Hindustan Fasteners Ltd',
    invoiceNumber: 'HFL/2025/028',
    invoiceDate: DateTime(2025, 9, 5),
    invoiceAmount: 280000,
    dueDate: DateTime(2025, 10, 20),
    paymentDate: DateTime(2025, 10, 18),
    daysToPay: 43,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.paidOnTime,
  ),
  MsmePayment(
    id: 'mp14',
    clientId: 'c4',
    vendorId: 'mv8',
    vendorName: 'Narmada Packaging Solutions',
    invoiceNumber: 'NPS/2026/005',
    invoiceDate: DateTime(2026, 2, 1),
    invoiceAmount: 67000,
    dueDate: DateTime(2026, 3, 18),
    daysToPay: 5,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp15',
    clientId: 'c4',
    vendorId: 'mv8',
    vendorName: 'Narmada Packaging Solutions',
    invoiceNumber: 'NPS/2025/042',
    invoiceDate: DateTime(2025, 12, 15),
    invoiceAmount: 43000,
    dueDate: DateTime(2026, 1, 29),
    paymentDate: DateTime(2026, 1, 25),
    daysToPay: 41,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.paidOnTime,
  ),
  MsmePayment(
    id: 'mp16',
    clientId: 'c5',
    vendorId: 'mv9',
    vendorName: 'Sagar IT Services',
    invoiceNumber: 'SIS/2025/067',
    invoiceDate: DateTime(2025, 12, 18),
    invoiceAmount: 210000,
    dueDate: DateTime(2026, 2, 1),
    daysToPay: 82,
    isWithin45Days: false,
    penaltyInterest: 5145,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp17',
    clientId: 'c5',
    vendorId: 'mv9',
    vendorName: 'Sagar IT Services',
    invoiceNumber: 'SIS/2025/055',
    invoiceDate: DateTime(2025, 10, 1),
    invoiceAmount: 175000,
    dueDate: DateTime(2025, 11, 15),
    paymentDate: DateTime(2025, 12, 5),
    daysToPay: 65,
    isWithin45Days: false,
    penaltyInterest: 2917,
    status: MsmePaymentStatus.paidLate,
  ),
  MsmePayment(
    id: 'mp18',
    clientId: 'c5',
    vendorId: 'mv10',
    vendorName: 'Jaipur Handicrafts Co-op',
    invoiceNumber: 'JHC/2026/002',
    invoiceDate: DateTime(2026, 2, 15),
    invoiceAmount: 34000,
    dueDate: DateTime(2026, 4, 1),
    daysToPay: 0,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.overdue,
  ),
  MsmePayment(
    id: 'mp19',
    clientId: 'c1',
    vendorId: 'mv2',
    vendorName: 'Sharma & Sons Engineering Works',
    invoiceNumber: 'SSE/2025/040',
    invoiceDate: DateTime(2025, 8, 20),
    invoiceAmount: 150000,
    dueDate: DateTime(2025, 10, 4),
    paymentDate: DateTime(2025, 10, 2),
    daysToPay: 43,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.paidOnTime,
  ),
  MsmePayment(
    id: 'mp20',
    clientId: 'c2',
    vendorId: 'mv4',
    vendorName: 'Patel Textile Industries',
    invoiceNumber: 'PTI/2025/058',
    invoiceDate: DateTime(2025, 7, 10),
    invoiceAmount: 95000,
    dueDate: DateTime(2025, 8, 24),
    paymentDate: DateTime(2025, 8, 24),
    daysToPay: 45,
    isWithin45Days: true,
    penaltyInterest: 0,
    status: MsmePaymentStatus.disputed,
  ),
];
