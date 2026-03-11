import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

/// Immutable model representing a client's ITR filing record.
class ItrClient {
  const ItrClient({
    required this.id,
    required this.name,
    required this.pan,
    required this.aadhaar,
    required this.email,
    required this.phone,
    required this.itrType,
    required this.assessmentYear,
    required this.filingStatus,
    required this.totalIncome,
    required this.taxPayable,
    required this.refundDue,
    this.filedDate,
    this.acknowledgementNumber,
  });

  final String id;
  final String name;
  final String pan;
  final String aadhaar;
  final String email;
  final String phone;
  final ItrType itrType;
  final String assessmentYear;
  final FilingStatus filingStatus;
  final double totalIncome;
  final double taxPayable;
  final double refundDue;
  final DateTime? filedDate;
  final String? acknowledgementNumber;

  /// Returns a masked PAN like "XXXXX1234X".
  String get maskedPan {
    if (pan.length != 10) return pan;
    return 'XXXXX${pan.substring(5)}';
  }

  /// Returns the initials (first letter of first two words).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  ItrClient copyWith({
    String? id,
    String? name,
    String? pan,
    String? aadhaar,
    String? email,
    String? phone,
    ItrType? itrType,
    String? assessmentYear,
    FilingStatus? filingStatus,
    double? totalIncome,
    double? taxPayable,
    double? refundDue,
    DateTime? filedDate,
    String? acknowledgementNumber,
  }) {
    return ItrClient(
      id: id ?? this.id,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      aadhaar: aadhaar ?? this.aadhaar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      itrType: itrType ?? this.itrType,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      filingStatus: filingStatus ?? this.filingStatus,
      totalIncome: totalIncome ?? this.totalIncome,
      taxPayable: taxPayable ?? this.taxPayable,
      refundDue: refundDue ?? this.refundDue,
      filedDate: filedDate ?? this.filedDate,
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItrClient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
