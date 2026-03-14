import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';

/// Local (SQLite via Drift) data source for e-verification.
///
/// Note: full DAO wiring is deferred until the e_verification tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class EVerificationLocalSource {
  const EVerificationLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertVerificationRequest(VerificationRequest req) async =>
      req.id;

  Future<List<VerificationRequest>> getAllVerificationRequests() async =>
      const [];

  Future<bool> updateVerificationRequest(VerificationRequest req) async =>
      false;

  Future<bool> deleteVerificationRequest(String id) async => false;

  Future<String> insertSigningRequest(SigningRequest req) async =>
      req.requestId;

  Future<List<SigningRequest>> getAllSigningRequests() async => const [];

  Future<bool> updateSigningRequest(SigningRequest req) async => false;

  Future<bool> deleteSigningRequest(String requestId) async => false;
}
