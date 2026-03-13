import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/form12bb_declaration.dart';

// ---------------------------------------------------------------------------
// Validation constants
// ---------------------------------------------------------------------------

/// PAN format: 5 uppercase letters, 4 digits, 1 uppercase letter.
final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

/// Section-wise maximum limits in paise.
class Form12bbLimits {
  Form12bbLimits._();

  /// Section 80C max: Rs 1,50,000 = 15_000_000 paise.
  static const int section80C = 15000000;

  /// Section 80CCD(1B) NPS max: Rs 50,000 = 5_000_000 paise.
  static const int section80CCD1B = 5000000;

  /// Section 80TTA savings interest max: Rs 10,000 = 1_000_000 paise.
  static const int section80TTA = 1000000;

  /// Section 24(b) home loan interest max: Rs 2,00,000 = 20_000_000 paise.
  static const int homeLoanInterest = 20000000;

  /// Section 80D self max: Rs 25,000 = 2_500_000 paise.
  static const int section80DSelf = 2500000;

  /// Section 80D self (senior citizen) max: Rs 50,000 = 5_000_000 paise.
  static const int section80DSelfSenior = 5000000;

  /// Landlord PAN required threshold: Rs 1,00,000 = 10_000_000 paise.
  static const int landlordPanThreshold = 10000000;
}

// ---------------------------------------------------------------------------
// Validation helpers
// ---------------------------------------------------------------------------

/// Returns validation errors for the given declaration, or empty list if valid.
List<String> validateForm12bb(Form12bbDeclaration declaration) {
  final errors = <String>[];

  // Landlord PAN required if annual rent > Rs 1,00,000
  if (declaration.annualRentPaid > Form12bbLimits.landlordPanThreshold) {
    if (declaration.landlordPan == null || declaration.landlordPan!.isEmpty) {
      errors.add('Landlord PAN is required when rent exceeds ₹1,00,000/year');
    } else if (!panRegex.hasMatch(declaration.landlordPan!)) {
      errors.add('Invalid landlord PAN format');
    }
  }

  // Lender PAN validation
  if (declaration.homeLoanInterest > 0 &&
      declaration.lenderPan != null &&
      declaration.lenderPan!.isNotEmpty &&
      !panRegex.hasMatch(declaration.lenderPan!)) {
    errors.add('Invalid lender PAN format');
  }

  // Section limits
  if (declaration.section80C > Form12bbLimits.section80C) {
    errors.add('Section 80C exceeds maximum limit of ₹1,50,000');
  }
  if (declaration.section80CCD1B > Form12bbLimits.section80CCD1B) {
    errors.add('Section 80CCD(1B) exceeds maximum limit of ₹50,000');
  }
  if (declaration.section80TTA > Form12bbLimits.section80TTA) {
    errors.add('Section 80TTA exceeds maximum limit of ₹10,000');
  }
  if (declaration.homeLoanInterest > Form12bbLimits.homeLoanInterest) {
    errors.add('Home loan interest exceeds maximum limit of ₹2,00,000');
  }

  return List.unmodifiable(errors);
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final List<Form12bbDeclaration> _mockDeclarations = [
  Form12bbDeclaration(
    declarationId: 'f12bb-001',
    employeeId: 'emp-001',
    financialYear: 2025,
    annualRentPaid: 18000000, // Rs 1,80,000
    landlordName: 'Ramesh Patel',
    landlordPan: 'ABCPP1234A',
    landlordAddress: '302 Sakar Apt, Ahmedabad',
    ltaClaimedAmount: 3500000, // Rs 35,000
    section80C: 15000000, // Rs 1,50,000 (maxed)
    section80CCD1B: 5000000, // Rs 50,000 (maxed)
    section80D: 2500000, // Rs 25,000
    section80E: 0,
    section80G: 500000, // Rs 5,000
    section80TTA: 1000000, // Rs 10,000
    homeLoanInterest: 18000000, // Rs 1,80,000
    lenderName: 'State Bank of India',
    lenderPan: 'AABCS1234A',
    submittedAt: DateTime(2025, 6, 15),
    isVerified: true,
  ),
  Form12bbDeclaration(
    declarationId: 'f12bb-002',
    employeeId: 'emp-003',
    financialYear: 2025,
    annualRentPaid: 7200000, // Rs 72,000
    landlordName: 'Suresh Iyer',
    ltaClaimedAmount: 2000000, // Rs 20,000
    section80C: 12000000, // Rs 1,20,000
    section80CCD1B: 3000000, // Rs 30,000
    section80D: 4500000, // Rs 45,000 (self + parents)
    section80E: 6000000, // Rs 60,000
    section80G: 200000, // Rs 2,000
    section80TTA: 800000, // Rs 8,000
    homeLoanInterest: 0,
    submittedAt: DateTime(2025, 7, 1),
  ),
  Form12bbDeclaration(
    declarationId: 'f12bb-003',
    employeeId: 'emp-005',
    financialYear: 2025,
    annualRentPaid: 0,
    ltaClaimedAmount: 0,
    section80C: 8000000, // Rs 80,000
    section80CCD1B: 0,
    section80D: 2500000, // Rs 25,000
    section80E: 0,
    section80G: 1000000, // Rs 10,000
    section80TTA: 500000, // Rs 5,000
    homeLoanInterest: 20000000, // Rs 2,00,000 (maxed)
    lenderName: 'HDFC Bank',
    lenderPan: 'AAACH1234A',
    submittedAt: DateTime(2025, 6, 20),
    isVerified: true,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All Form 12BB declarations.
final form12bbListProvider =
    NotifierProvider<Form12bbListNotifier, List<Form12bbDeclaration>>(
      Form12bbListNotifier.new,
    );

class Form12bbListNotifier extends Notifier<List<Form12bbDeclaration>> {
  @override
  List<Form12bbDeclaration> build() => List.unmodifiable(_mockDeclarations);

  void add(Form12bbDeclaration declaration) {
    state = List.unmodifiable([...state, declaration]);
  }

  void update(Form12bbDeclaration updated) {
    state = List.unmodifiable([
      for (final d in state)
        if (d.declarationId == updated.declarationId) updated else d,
    ]);
  }
}

/// Empty default declaration for the form editor.
Form12bbDeclaration _emptyDeclaration() => Form12bbDeclaration(
  declarationId: '',
  employeeId: '',
  financialYear: 2025,
  submittedAt: DateTime.now(),
);

/// The declaration currently being edited.
final activeForm12bbProvider =
    NotifierProvider<ActiveForm12bbNotifier, Form12bbDeclaration>(
      ActiveForm12bbNotifier.new,
    );

class ActiveForm12bbNotifier extends Notifier<Form12bbDeclaration> {
  @override
  Form12bbDeclaration build() => _emptyDeclaration();

  void load(Form12bbDeclaration declaration) => state = declaration;

  void reset() => state = _emptyDeclaration();

  void updateHra({
    int? annualRentPaid,
    String? landlordName,
    String? landlordPan,
    String? landlordAddress,
  }) {
    state = state.copyWith(
      annualRentPaid: annualRentPaid ?? state.annualRentPaid,
      landlordName: landlordName ?? state.landlordName,
      landlordPan: landlordPan ?? state.landlordPan,
      landlordAddress: landlordAddress ?? state.landlordAddress,
    );
  }

  void updateLta({required int ltaClaimedAmount}) {
    state = state.copyWith(ltaClaimedAmount: ltaClaimedAmount);
  }

  void updateChapterVIA({
    int? section80C,
    int? section80CCD1B,
    int? section80D,
    int? section80E,
    int? section80G,
    int? section80TTA,
  }) {
    state = state.copyWith(
      section80C: section80C ?? state.section80C,
      section80CCD1B: section80CCD1B ?? state.section80CCD1B,
      section80D: section80D ?? state.section80D,
      section80E: section80E ?? state.section80E,
      section80G: section80G ?? state.section80G,
      section80TTA: section80TTA ?? state.section80TTA,
    );
  }

  void updateHomeLoan({
    int? homeLoanInterest,
    String? lenderName,
    String? lenderPan,
  }) {
    state = state.copyWith(
      homeLoanInterest: homeLoanInterest ?? state.homeLoanInterest,
      lenderName: lenderName ?? state.lenderName,
      lenderPan: lenderPan ?? state.lenderPan,
    );
  }

  void setEmployee(String employeeId) {
    state = state.copyWith(employeeId: employeeId);
  }
}

/// Derived provider: total declared deductions in paise.
final form12bbTotalDeductionsProvider = Provider<int>((ref) {
  final declaration = ref.watch(activeForm12bbProvider);
  return declaration.totalDeductions;
});
