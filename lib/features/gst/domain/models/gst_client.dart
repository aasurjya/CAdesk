/// GST registration types as defined by CBIC.
enum GstRegistrationType {
  regular(label: 'Regular'),
  composition(label: 'Composition'),
  unregistered(label: 'Unregistered'),
  casual(label: 'Casual'),
  sez(label: 'SEZ');

  const GstRegistrationType({required this.label});

  final String label;
}

/// Immutable model representing a GST-registered client.
class GstClient {
  const GstClient({
    required this.id,
    required this.businessName,
    required this.gstin,
    required this.pan,
    required this.registrationType,
    required this.state,
    required this.stateCode,
    this.tradeName,
    this.returnsPending = const [],
    this.lastFiledDate,
    this.complianceScore = 0,
  })  : assert(gstin.length == 15, 'GSTIN must be exactly 15 characters'),
        assert(
          complianceScore >= 0 && complianceScore <= 100,
          'Compliance score must be between 0 and 100',
        );

  final String id;
  final String businessName;
  final String? tradeName;

  /// 15-character GSTIN (e.g. 27AABCU9603R1ZM).
  final String gstin;
  final String pan;
  final GstRegistrationType registrationType;
  final String state;
  final String stateCode;

  /// Return types that are currently pending (e.g. ['GSTR-1', 'GSTR-3B']).
  final List<String> returnsPending;
  final DateTime? lastFiledDate;

  /// 0-100 compliance health score.
  final int complianceScore;

  GstClient copyWith({
    String? id,
    String? businessName,
    String? tradeName,
    String? gstin,
    String? pan,
    GstRegistrationType? registrationType,
    String? state,
    String? stateCode,
    List<String>? returnsPending,
    DateTime? lastFiledDate,
    int? complianceScore,
  }) {
    return GstClient(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      tradeName: tradeName ?? this.tradeName,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      registrationType: registrationType ?? this.registrationType,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      returnsPending: returnsPending ?? this.returnsPending,
      lastFiledDate: lastFiledDate ?? this.lastFiledDate,
      complianceScore: complianceScore ?? this.complianceScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstClient && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
