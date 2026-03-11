/// Classification of MSME enterprises under the MSMED Act.
enum MsmeClassification {
  micro('Micro'),
  small('Small'),
  medium('Medium');

  const MsmeClassification(this.label);
  final String label;
}

/// Immutable model representing an MSME-registered vendor.
class MsmeVendor {
  const MsmeVendor({
    required this.id,
    required this.clientId,
    required this.vendorName,
    required this.msmeRegistrationNumber,
    required this.classification,
    required this.registeredDate,
    required this.isVerified,
    required this.outstandingAmount,
    this.oldestInvoiceDate,
    required this.daysPastDue,
    required this.section43BhAtRisk,
  });

  final String id;
  final String clientId;
  final String vendorName;
  final String msmeRegistrationNumber;
  final MsmeClassification classification;
  final DateTime registeredDate;
  final bool isVerified;
  final double outstandingAmount;
  final DateTime? oldestInvoiceDate;
  final int daysPastDue;
  final bool section43BhAtRisk;

  /// Returns the initials (first letter of first two words).
  String get initials {
    final parts = vendorName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  MsmeVendor copyWith({
    String? id,
    String? clientId,
    String? vendorName,
    String? msmeRegistrationNumber,
    MsmeClassification? classification,
    DateTime? registeredDate,
    bool? isVerified,
    double? outstandingAmount,
    DateTime? oldestInvoiceDate,
    int? daysPastDue,
    bool? section43BhAtRisk,
  }) {
    return MsmeVendor(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      vendorName: vendorName ?? this.vendorName,
      msmeRegistrationNumber:
          msmeRegistrationNumber ?? this.msmeRegistrationNumber,
      classification: classification ?? this.classification,
      registeredDate: registeredDate ?? this.registeredDate,
      isVerified: isVerified ?? this.isVerified,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      oldestInvoiceDate: oldestInvoiceDate ?? this.oldestInvoiceDate,
      daysPastDue: daysPastDue ?? this.daysPastDue,
      section43BhAtRisk: section43BhAtRisk ?? this.section43BhAtRisk,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MsmeVendor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
