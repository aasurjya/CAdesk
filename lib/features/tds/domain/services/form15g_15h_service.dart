import 'package:ca_app/features/tds/domain/models/form15g.dart';
import 'package:ca_app/features/tds/domain/models/form15h.dart';
import 'package:flutter/foundation.dart';

/// Identifies which declaration form type is being generated.
enum DeclarationFormType { form15G, form15H }

/// Immutable register holding all Form 15G and 15H declarations for a deductor.
@immutable
class Form15g15hRegister {
  const Form15g15hRegister({required this.forms15g, required this.forms15h});

  /// All Form 15G declarations on record.
  final List<Form15G> forms15g;

  /// All Form 15H declarations on record.
  final List<Form15H> forms15h;

  // ---------------------------------------------------------------------------
  // Computed
  // ---------------------------------------------------------------------------

  /// Sum of all declared amounts across Form 15G and 15H.
  double get totalAggregateDeclared {
    final g = forms15g.fold(0.0, (sum, f) => sum + f.aggregateDeclaredAmount);
    final h = forms15h.fold(0.0, (sum, f) => sum + f.aggregateDeclaredAmount);
    return g + h;
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Form15g15hRegister copyWith({
    List<Form15G>? forms15g,
    List<Form15H>? forms15h,
  }) {
    return Form15g15hRegister(
      forms15g: forms15g ?? this.forms15g,
      forms15h: forms15h ?? this.forms15h,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form15g15hRegister &&
          runtimeType == other.runtimeType &&
          _listEquals(forms15g, other.forms15g) &&
          _listEquals(forms15h, other.forms15h);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(forms15g), Object.hashAll(forms15h));

  @override
  String toString() =>
      'Form15g15hRegister(15g: ${forms15g.length}, '
      '15h: ${forms15h.length})';
}

/// Static service for Form 15G/15H register management.
///
/// All methods are pure and return new immutable instances (no mutation).
class Form15g15hService {
  Form15g15hService._();

  // ---------------------------------------------------------------------------
  // Register mutations (return new registers)
  // ---------------------------------------------------------------------------

  /// Returns a new register with [form] added to the Form 15G list.
  static Form15g15hRegister registerForm15G({
    required Form15g15hRegister register,
    required Form15G form,
  }) {
    return register.copyWith(forms15g: [...register.forms15g, form]);
  }

  /// Returns a new register with [form] added to the Form 15H list.
  static Form15g15hRegister registerForm15H({
    required Form15g15hRegister register,
    required Form15H form,
  }) {
    return register.copyWith(forms15h: [...register.forms15h, form]);
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Returns true when a valid (non-expired) declaration exists for the given
  /// PAN, deductor TAN, and TDS section as of [asOf].
  static bool hasValidDeclaration({
    required Form15g15hRegister register,
    required String pan,
    required String deductorTan,
    required String sectionCode,
    required DateTime asOf,
  }) {
    final has15g = register.forms15g.any(
      (f) =>
          f.pan == pan &&
          f.deductorTan == deductorTan &&
          f.sectionCode == sectionCode &&
          !f.isExpiredAt(asOf),
    );
    if (has15g) return true;

    return register.forms15h.any(
      (f) =>
          f.pan == pan &&
          f.deductorTan == deductorTan &&
          f.sectionCode == sectionCode &&
          !f.isExpiredAt(asOf),
    );
  }

  /// Returns a new register containing only declarations valid as of [asOf].
  static Form15g15hRegister activeDeclarations({
    required Form15g15hRegister register,
    required DateTime asOf,
  }) {
    return Form15g15hRegister(
      forms15g: register.forms15g.where((f) => !f.isExpiredAt(asOf)).toList(),
      forms15h: register.forms15h.where((f) => !f.isExpiredAt(asOf)).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Numbering
  // ---------------------------------------------------------------------------

  /// Generates a sequential form number.
  ///
  /// Format: F15G/YYYY-YY/NNN or F15H/YYYY-YY/NNN
  static String generateFormNumber({
    required DeclarationFormType formType,
    required String financialYear,
    required int sequenceNumber,
  }) {
    final prefix = formType == DeclarationFormType.form15G ? 'F15G' : 'F15H';
    final seq = sequenceNumber.toString().padLeft(3, '0');
    return '$prefix/$financialYear/$seq';
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
