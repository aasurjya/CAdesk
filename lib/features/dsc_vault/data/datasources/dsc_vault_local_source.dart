import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';

/// Local (SQLite via Drift) data source for DSC vault.
///
/// Note: full DAO wiring is deferred until the dsc_vault tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class DscVaultLocalSource {
  const DscVaultLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertCertificate(DscCertificate cert) async => cert.id;

  Future<List<DscCertificate>> getAllCertificates() async => const [];

  Future<bool> updateCertificate(DscCertificate cert) async => false;

  Future<bool> deleteCertificate(String id) async => false;

  Future<String> insertCredential(PortalCredential cred) async => cred.id;

  Future<List<PortalCredential>> getAllCredentials() async => const [];

  Future<bool> updateCredential(PortalCredential cred) async => false;

  Future<bool> deleteCredential(String id) async => false;
}
