import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';

/// Lightweight search result returned by MCA company search.
///
/// Carries only summary fields to keep list rendering efficient.
/// Use [McaApiService.getCompanyDetails] to fetch the full record.
class CompanySearchResult {
  const CompanySearchResult({
    required this.cin,
    required this.name,
    required this.status,
    required this.incorporationDate,
    required this.roc,
  });

  /// 21-character Corporate Identification Number.
  final String cin;

  final String name;

  final McaCompanyStatus status;

  final DateTime incorporationDate;

  /// Registrar of Companies office (e.g. "RoC-Mumbai").
  final String roc;

  CompanySearchResult copyWith({
    String? cin,
    String? name,
    McaCompanyStatus? status,
    DateTime? incorporationDate,
    String? roc,
  }) {
    return CompanySearchResult(
      cin: cin ?? this.cin,
      name: name ?? this.name,
      status: status ?? this.status,
      incorporationDate: incorporationDate ?? this.incorporationDate,
      roc: roc ?? this.roc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanySearchResult &&
          runtimeType == other.runtimeType &&
          cin == other.cin &&
          name == other.name &&
          status == other.status &&
          incorporationDate == other.incorporationDate &&
          roc == other.roc;

  @override
  int get hashCode => Object.hash(cin, name, status, incorporationDate, roc);
}
